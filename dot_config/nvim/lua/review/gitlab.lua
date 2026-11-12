-- GitLab through `glab api`, where glab is logged in. All calls are coroutine
-- steps (util.async).
local util = require("review.util")

local M = {}

--- { host, project } from an origin URL (scp-like, ssh:// or https://), or nil.
function M.project_of(origin)
    origin = vim.trim(origin or "")
    local host, path = origin:match("^[%w._-]+@([^:/]+):(.+)$")
    if not host then
        local rest = origin:match("^%a[%w+.-]*://(.+)$")
        if rest then
            rest = rest:gsub("^[^@/]+@", "")
            host, path = rest:match("^([^:/]+):?%d*/(.+)$")
        end
    end
    if not host or not path then
        return nil
    end
    path = path:gsub("/$", ""):gsub("%.git$", "")
    return { host = host, project = path }
end

local function encode(text)
    return (
        text:gsub("[^%w._~-]", function(character)
            return ("%%%02X"):format(character:byte())
        end)
    )
end

--- Calls the API: returns the decoded response, or nil and an error.
function M.api(host, path, ...)
    local command = { "glab", "api", "--hostname", host, path, ... }
    local result = util.run_async(command, { timeout = 60000 })
    if result.code ~= 0 then
        return nil, util.failure(result, "glab api " .. path .. " failed")
    end
    if vim.trim(result.stdout) == "" then
        return vim.NIL
    end
    local ok, data = pcall(
        vim.json.decode,
        result.stdout,
        { luanil = { object = true, array = true } }
    )
    if not ok then
        return nil, "glab api " .. path .. ": unreadable response"
    end
    return data
end

local function mr_path(mr)
    return ("projects/%s/merge_requests/%d"):format(encode(mr.project), mr.iid)
end

function M.username(host)
    local user = M.api(host, "user")
    return type(user) == "table" and user.username or nil
end

local function threads_of(mr, discussions)
    local threads = {}
    for _, discussion in ipairs(discussions) do
        local notes = vim.tbl_filter(function(note)
            return not note.system
        end, discussion.notes or {})
        if #notes > 0 then
            local position = notes[1].position
            local resolvable, resolved = false, true
            for _, note in ipairs(notes) do
                if note.resolvable then
                    resolvable = true
                    resolved = resolved and note.resolved == true
                end
            end
            table.insert(threads, {
                id = tostring(discussion.id),
                notes = vim.tbl_map(function(note)
                    local author = note.author or {}
                    return {
                        author = author.username or author.name or "someone",
                        at = note.created_at,
                        body = vim.trim(note.body or ""),
                    }
                end, notes),
                resolvable = resolvable,
                resolved = resolvable and resolved,
                path = position and (position.new_path or position.old_path)
                    or nil,
                new_line = position and position.new_line or nil,
                old_line = position
                        and not position.new_line
                        and position.old_line
                    or nil,
                outdated = position ~= nil
                    and mr.refs ~= nil
                    and position.head_sha ~= nil
                    and position.head_sha ~= mr.refs.head_sha,
                url = ("%s#note_%s"):format(mr.url, notes[1].id),
            })
        end
    end
    return threads
end

local function all_discussions(mr)
    local all = {}
    for page = 1, 5 do
        local batch, err = M.api(
            mr.host,
            ("%s/discussions?per_page=100&page=%d"):format(mr_path(mr), page)
        )
        if not batch then
            return nil, err
        end
        vim.list_extend(all, batch)
        if #batch < 100 then
            break
        end
    end
    return all
end

--- The open MR of `branch` with its details, approvals and threads; false when
--- there is none; nil and an error when GitLab can't be asked.
function M.load_merge_request(project, branch)
    local list, err = M.api(
        project.host,
        ("projects/%s/merge_requests?source_branch=%s&state=opened&per_page=1"):format(
            encode(project.project),
            encode(branch)
        )
    )
    if not list then
        return nil, err
    end
    if type(list) ~= "table" or not list[1] then
        return false
    end
    local mr =
        { host = project.host, project = project.project, iid = list[1].iid }
    local detail, detail_err = M.api(mr.host, mr_path(mr))
    if not detail then
        return nil, detail_err
    end
    local approvals = M.api(mr.host, mr_path(mr) .. "/approvals")
    local pipeline = detail.head_pipeline or detail.pipeline
    mr.title = detail.title
    mr.url = detail.web_url
    mr.author = detail.author and detail.author.username or nil
    mr.target = detail.target_branch
    mr.refs = detail.diff_refs
    mr.pipeline = type(pipeline) == "table" and pipeline.status or nil
    mr.draft = detail.draft == true
    mr.approved_by = {}
    if type(approvals) == "table" then
        for _, approval in ipairs(approvals.approved_by or {}) do
            table.insert(
                mr.approved_by,
                approval.user and approval.user.username
            )
        end
    end
    local discussions, discussions_err = all_discussions(mr)
    if not discussions then
        return nil, discussions_err
    end
    mr.threads = threads_of(mr, discussions)
    return mr
end

function M.reply(mr, thread, text)
    return M.api(
        mr.host,
        ("%s/discussions/%s/notes"):format(mr_path(mr), thread.id),
        "--method",
        "POST",
        "--raw-field",
        "body=" .. text
    )
end

function M.resolve(mr, thread, resolved)
    return M.api(
        mr.host,
        ("%s/discussions/%s"):format(mr_path(mr), thread.id),
        "--method",
        "PUT",
        "--field",
        "resolved=" .. tostring(resolved)
    )
end

function M.approve(mr)
    return M.api(mr.host, mr_path(mr) .. "/approve", "--method", "POST")
end

local function lines_label(comment)
    if comment.from.number == comment.to.number then
        return "line " .. comment.to.number
    end
    return ("lines %d–%d"):format(comment.from.number, comment.to.number)
end

-- For a comment GitLab won't take on its line: the file, lines and quoted rows
-- in the note itself.
local function general_note(comment)
    local quote = vim.tbl_map(function(line)
        return line:sub(7, 7) .. line:sub(9)
    end, comment.quote or {})
    return ("**`%s`**, %s:\n\n```diff\n%s\n```\n\n%s"):format(
        comment.path,
        lines_label(comment),
        table.concat(quote, "\n"),
        comment.text
    )
end

--- Posts comments as one GitLab review: a draft note each (on its line where
--- `place(comment)` gives a position GitLab accepts, else a general note naming
--- the file and lines), the summary as one more, then publishes them together.
--- Returns { positioned, general } or nil and an error.
function M.post_review(mr, comments, summary, place)
    local counts = { positioned = 0, general = 0 }
    local path = mr_path(mr) .. "/draft_notes"
    for _, comment in ipairs(comments) do
        local position = place(comment)
        local posted = false
        if position then
            posted = M.api(
                mr.host,
                path,
                "--method",
                "POST",
                "--raw-field",
                "note=" .. comment.text,
                "--field",
                "position=" .. vim.json.encode(position)
            ) ~= nil
            if posted then
                counts.positioned = counts.positioned + 1
            end
        end
        if not posted then
            local ok, err = M.api(
                mr.host,
                path,
                "--method",
                "POST",
                "--raw-field",
                "note=" .. general_note(comment)
            )
            if not ok then
                return nil, err
            end
            counts.general = counts.general + 1
        end
    end
    if vim.trim(summary or "") ~= "" then
        local ok, err = M.api(
            mr.host,
            path,
            "--method",
            "POST",
            "--raw-field",
            "note=" .. vim.trim(summary)
        )
        if not ok then
            return nil, err
        end
    end
    local ok, err = M.api(mr.host, path .. "/bulk_publish", "--method", "POST")
    if not ok then
        return nil, err
    end
    return counts
end

return M
