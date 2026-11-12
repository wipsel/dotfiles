-- What the keys and :Review subcommands do.
local agent = require("review.agent")
local diff = require("review.diff")
local git = require("review.git")
local gitlab = require("review.gitlab")
local input = require("review.input")
local message = require("review.message")
local notes = require("review.notes")
local pickers = require("review.pickers")
local session = require("review.session")
local util = require("review.util")
local view = require("review.view")

local M = {}

-- Unchanged lines around a change that a question about it includes.
local ASK_CONTEXT = 3

local last_deleted = nil

--- The repo path of the file in the current buffer (review buffer or real
--- file), or nil.
function M.current_path()
    local buf = vim.api.nvim_get_current_buf()
    local state = view.state(buf)
    if state then
        return state.path
    end
    return notes.real_path(buf)
end

-- Runs `fn(session)` with the review of the current context, reading the repo
-- first if needed.
local function with_session(fn)
    local current = session.current
    if current and current.repo then
        fn(current)
        return
    end
    local name = vim.api.nvim_buf_get_name(0)
    local cwd = vim.fn.getcwd()
    if
        vim.bo.buftype == ""
        and name ~= ""
        and vim.fn.filereadable(name) == 1
    then
        cwd = vim.fn.fnamemodify(name, ":h")
    end
    session.ensure(cwd, fn)
end

local function ask_text(options)
    return util.await(function(callback)
        input.open(options, callback)
    end)
end

local function range_label(rows)
    local first, last = rows[1], rows[#rows]
    if first.number == last.number then
        return tostring(last.number)
    end
    return ("%d–%d"):format(first.number, last.number)
end

-- The lines a key acts on: the visual selection, or the cursor line.
local function picked_lines(visual)
    local cursor = vim.fn.line(".")
    if not visual then
        return cursor, cursor
    end
    local other = vim.fn.line("v")
    vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
    return math.min(cursor, other), math.max(cursor, other)
end

-- Rows for lines of a real file's buffer: the diff's own row where the line is
-- the one the diff has there, else an unchanged row with just its number.
local function real_rows(current, buf, path, first, last)
    local by_number = {}
    local detail = current:detail(path)
    for _, row in ipairs(detail and detail.rows or {}) do
        if row.kind ~= "-" then
            by_number[row.number] = row
        end
    end
    local rows = {}
    for index, text in
        ipairs(vim.api.nvim_buf_get_lines(buf, first - 1, last, false))
    do
        local number = first + index - 1
        local row = by_number[number]
        if row and row.text == text then
            table.insert(rows, row)
        else
            table.insert(rows, { kind = " ", number = number, text = text })
        end
    end
    return rows
end

--- { path, rows } for lines `first`..`last` of `buf`, or nil and why not.
local function rows_of(current, buf, first, last)
    local state = view.state(buf)
    if state then
        if state.empty then
            return nil, "No lines to pick here"
        end
        return {
            path = state.path,
            rows = vim.list_slice(state.rows, first, last),
        }
    end
    local path = notes.real_path(buf)
    if not path then
        return nil, "This buffer isn't a file of the reviewed repo"
    end
    return { path = path, rows = real_rows(current, buf, path, first, last) }
end

function M.comment(visual)
    local buf = vim.api.nvim_get_current_buf()
    local first, last = picked_lines(visual)
    with_session(function(current)
        local picked, why = rows_of(current, buf, first, last)
        if not picked then
            util.warn(why)
            return
        end
        local rows = picked.rows
        input.open({
            title = ("Comment on %s:%s"):format(picked.path, range_label(rows)),
        }, function(text)
            if not text then
                return
            end
            local file = current.by_path[picked.path]
            table.insert(current.state.comments, {
                id = util.new_id(),
                path = picked.path,
                old_path = file and file.old_path or picked.path,
                from = diff.anchor_of(rows[1]),
                to = diff.anchor_of(rows[#rows]),
                quote = vim.tbl_map(diff.quote_row, rows),
                text = text,
                created = util.now(),
                state = "draft",
            })
            current:save()
            notes.refresh()
        end)
    end)
end

-- The note of `kinds` under the cursor (a thread window's own thread first);
-- with several, asks.
local function note_at_cursor(kinds, on_note)
    local current = session.current
    if not current then
        util.warn("No review open: run :Review first")
        return
    end
    local thread_id = vim.b.review_thread
    if thread_id and vim.tbl_contains(kinds, "thread") then
        on_note(current, { kind = "thread", id = thread_id })
        return
    end
    local found = vim.tbl_filter(function(item)
        return vim.tbl_contains(kinds, item.kind)
    end, notes.at(vim.api.nvim_get_current_buf(), vim.fn.line(".")))
    if #found == 0 then
        util.warn(("No %s on this line"):format(table.concat(kinds, " or ")))
        return
    end
    if #found == 1 then
        on_note(current, found[1])
        return
    end
    vim.ui.select(found, {
        prompt = "Which one?",
        format_item = function(item)
            if item.kind == "comment" then
                local comment = current:find_comment(item.id)
                return "Comment: "
                    .. (comment and comment.text:gsub("\n", " ") or item.id)
            end
            local thread = current:find_thread(item.id)
            return "Thread: "
                .. (
                    thread
                        and (thread.notes[1].author .. ": " .. thread.notes[1].body:gsub(
                            "\n",
                            " "
                        ))
                    or item.id
                )
        end,
    }, function(item)
        if item then
            on_note(current, item)
        end
    end)
end

function M.edit()
    note_at_cursor({ "comment" }, function(current, item)
        local comment = current:find_comment(item.id)
        if not comment then
            return
        end
        input.open(
            { title = "Edit comment on " .. comment.path, text = comment.text },
            function(text)
                if not text then
                    return
                end
                comment.text = text
                if comment.state ~= "draft" then
                    comment.state, comment.at = "draft", util.now()
                end
                current:save()
                notes.refresh()
            end
        )
    end)
end

function M.delete()
    note_at_cursor({ "comment" }, function(current, item)
        local comment, index = current:find_comment(item.id)
        if not comment then
            return
        end
        table.remove(current.state.comments, index)
        last_deleted = comment
        current:save()
        notes.refresh()
        util.notify("Comment deleted (<leader>ru undoes)")
    end)
end

function M.undo_delete()
    local current = session.current
    if not current or not last_deleted then
        util.notify("Nothing to bring back")
        return
    end
    table.insert(current.state.comments, last_deleted)
    last_deleted = nil
    current:save()
    notes.refresh()
end

function M.expand()
    note_at_cursor({ "comment", "thread" }, function(_, item)
        notes.toggle_expanded(item.id)
        notes.refresh()
    end)
end

local function included_threads(current)
    return vim.tbl_filter(function(thread)
        return current:included(thread.id)
    end, current:threads())
end

local function drafts_of(current)
    return vim.tbl_filter(function(comment)
        return comment.state == "draft"
    end, current:comments())
end

function M.send()
    with_session(function(current)
        local drafts, threads = drafts_of(current), included_threads(current)
        if #drafts == 0 and #threads == 0 then
            util.warn("Nothing to send: no draft comments or added threads")
            return
        end
        util.async(function()
            local address, why = agent.address()
            if not address then
                util.error(why)
                return
            end
            local counted = {}
            if #drafts > 0 then
                table.insert(counted, util.plural(#drafts, "comment"))
            end
            if #threads > 0 then
                table.insert(counted, util.plural(#threads, "thread"))
            end
            local what = table.concat(counted, " + ")
            local note = ask_text({
                title = ("Send %s to %s · optional note"):format(
                    what,
                    address
                ),
                allow_empty = true,
            })
            if note == nil then
                return
            end
            local text = message.review(
                current:where(),
                current:scope_words(),
                drafts,
                threads,
                current.mr,
                note
            )
            local snapshot, snapshot_error = util.await(function(callback)
                git.snapshot(current.repo, callback)
            end)
            local result = util.run_async(
                { "hc", "send", address, text },
                { timeout = 120000 }
            )
            if result.code ~= 0 then
                util.error(
                    "Sending failed: " .. util.failure(result, "hc send failed")
                )
                return
            end
            local now = util.now()
            for _, comment in ipairs(drafts) do
                comment.state, comment.at = "sent", now
            end
            current.state.included = {}
            current:save()
            notes.refresh()
            if snapshot then
                util.notify(("Sent %s to %s"):format(what, address))
                current:refresh()
            else
                util.warn(
                    ("Sent %s to %s, but the snapshot failed: %s"):format(
                        what,
                        address,
                        snapshot_error
                    )
                )
            end
        end)
    end)
end

-- The rows a question is about: the selection, else the change around the
-- cursor with some unchanged lines either side, else the cursor line with the
-- same.
local function question_rows(current, buf, visual)
    local first, last = picked_lines(visual)
    local state = view.state(buf)
    if not visual and state and not state.empty then
        local rows = state.rows
        if rows[first].kind ~= " " then
            while first > 1 and rows[first - 1].kind ~= " " do
                first = first - 1
            end
            while last < #rows and rows[last + 1].kind ~= " " do
                last = last + 1
            end
        end
        first, last =
            math.max(1, first - ASK_CONTEXT),
            math.min(#rows, last + ASK_CONTEXT)
    elseif not visual then
        local count = vim.api.nvim_buf_line_count(buf)
        first, last =
            math.max(1, first - ASK_CONTEXT),
            math.min(count, last + ASK_CONTEXT)
    end
    return rows_of(current, buf, first, last)
end

function M.ask(visual)
    local buf = vim.api.nvim_get_current_buf()
    with_session(function(current)
        local picked, why = question_rows(current, buf, visual)
        if not picked then
            util.warn(why)
            return
        end
        util.async(function()
            local address, address_error = agent.address()
            if not address then
                util.error(address_error)
                return
            end
            local question = ask_text({
                title = ("Ask %s about %s:%s"):format(
                    address,
                    picked.path,
                    range_label(picked.rows)
                ),
            })
            if not question then
                return
            end
            local text = message.ask(
                current:where(),
                current:scope_words(),
                picked.path,
                picked.rows,
                question
            )
            local result = util.run_async(
                { "hc", "send", address, text },
                { timeout = 120000 }
            )
            if result.code ~= 0 then
                util.error(
                    "Asking failed: " .. util.failure(result, "hc send failed")
                )
                return
            end
            util.notify("Asked " .. address)
        end)
    end)
end

local function require_mr(current)
    if current.mr then
        return current.mr
    end
    if current.mr_loading then
        util.warn("Still loading the merge request")
    elseif current.mr_error then
        util.error("GitLab: " .. current.mr_error)
    else
        util.warn("No open merge request for this branch")
    end
end

-- Where GitLab should show a comment, or nil for a general note: only when the
-- local HEAD is the MR's head and the file has no uncommitted changes (else the
-- line numbers may not be GitLab's), and lines other than added ones only when
-- the merge-base is the MR's base too.
local function position_of(current, mr, comment)
    local repo, refs = current.repo, mr.refs
    if
        not refs
        or refs.head_sha ~= repo.head
        or repo.dirty[comment.path]
        or not comment.to
    then
        return nil
    end
    local position = {
        position_type = "text",
        base_sha = refs.base_sha,
        start_sha = refs.start_sha,
        head_sha = refs.head_sha,
        new_path = comment.path,
        old_path = comment.old_path or comment.path,
    }
    local to = comment.to
    if to.kind == "+" then
        position.new_line = to.number
        return position
    end
    if refs.base_sha ~= repo.merge_base then
        return nil
    end
    if to.kind == "-" then
        position.old_line = to.number
    elseif to.old then
        position.new_line, position.old_line = to.number, to.old
    else
        return nil
    end
    return position
end

M.position_of = position_of

function M.post()
    with_session(function(current)
        local mr = require_mr(current)
        if not mr then
            return
        end
        local drafts = drafts_of(current)
        util.async(function()
            local warning = mr.refs
                    and mr.refs.head_sha ~= current.repo.head
                    and " · local HEAD isn't the MR head: comments go in as general notes"
                or ""
            local summary = ask_text({
                title = ("Post %s as a review on !%d · optional summary%s"):format(
                    util.plural(#drafts, "comment"),
                    mr.iid,
                    warning
                ),
                allow_empty = true,
            })
            if summary == nil then
                return
            end
            if #drafts == 0 and summary == "" then
                util.warn("Nothing to post")
                return
            end
            util.notify(("Posting the review on !%d…"):format(mr.iid))
            local counts, err = gitlab.post_review(
                mr,
                drafts,
                summary,
                function(comment)
                    return position_of(current, mr, comment)
                end
            )
            if not counts then
                util.error("Posting failed: " .. err)
                return
            end
            local now = util.now()
            for _, comment in ipairs(drafts) do
                comment.state, comment.at = "posted", now
            end
            current:save()
            notes.refresh()
            local general = counts.general > 0
                    and (", %d as general notes"):format(counts.general)
                or ""
            util.notify(
                ("Posted on !%d: %d on their lines%s"):format(
                    mr.iid,
                    counts.positioned,
                    general
                )
            )
            current:load_mr()
        end)
    end)
end

function M.reply()
    note_at_cursor({ "thread" }, function(current, item)
        local thread, mr = current:find_thread(item.id), current.mr
        if not thread or not mr then
            return
        end
        util.async(function()
            local text = ask_text({
                title = ("Reply on GitLab to %s's thread"):format(
                    thread.notes[1].author
                ),
            })
            if not text then
                return
            end
            local ok, err = gitlab.reply(mr, thread, text)
            if not ok then
                util.error("Reply failed: " .. err)
                return
            end
            util.notify("Replied on !" .. mr.iid)
            current:load_mr()
        end)
    end)
end

function M.resolve()
    note_at_cursor({ "thread" }, function(current, item)
        local thread, mr = current:find_thread(item.id), current.mr
        if not thread or not mr then
            return
        end
        if not thread.resolvable then
            util.warn("This thread can't be resolved")
            return
        end
        util.async(function()
            local ok, err = gitlab.resolve(mr, thread, not thread.resolved)
            if not ok then
                util.error("Resolving failed: " .. err)
                return
            end
            util.notify(
                thread.resolved and "Thread reopened" or "Thread resolved"
            )
            current:load_mr()
        end)
    end)
end

function M.include()
    note_at_cursor({ "thread" }, function(current, item)
        local included = current.state.included
        if current:included(item.id) then
            current.state.included = vim.tbl_filter(function(id)
                return id ~= item.id
            end, included)
            util.notify("Thread left out of the next review")
        else
            table.insert(included, item.id)
            util.notify("Thread added to the next review (<leader>rs)")
        end
        current:save()
        notes.refresh()
    end)
end

function M.include_all()
    with_session(function(current)
        local count = 0
        for _, thread in ipairs(current:threads()) do
            if
                thread.resolvable
                and not thread.resolved
                and not current:included(thread.id)
            then
                table.insert(current.state.included, thread.id)
                count = count + 1
            end
        end
        current:save()
        notes.refresh()
        util.notify(
            ("Added %s to the next review"):format(
                util.plural(count, "unresolved thread")
            )
        )
    end)
end

function M.approve()
    with_session(function(current)
        local mr = require_mr(current)
        if not mr then
            return
        end
        if current.me and vim.tbl_contains(mr.approved_by, current.me) then
            util.notify(("You already approved !%d"):format(mr.iid))
            return
        end
        if
            vim.fn.confirm(
                ("Approve !%d %s?"):format(mr.iid, mr.title),
                "&Yes\n&No",
                2
            ) ~= 1
        then
            return
        end
        util.async(function()
            local ok, err = gitlab.approve(mr)
            if not ok then
                util.error("Approving failed: " .. err)
                return
            end
            util.notify(("Approved !%d"):format(mr.iid))
            current:load_mr()
        end)
    end)
end

function M.open_mr()
    with_session(function(current)
        local mr = require_mr(current)
        if mr then
            vim.ui.open(mr.url)
        end
    end)
end

local function float(lines, title, options)
    options = options or {}
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = "wipe"
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
    local width = math.min(vim.o.columns - 4, options.width or 100)
    local height = math.min(#lines, vim.o.lines - 6)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        row = math.floor((vim.o.lines - height) / 2) - 1,
        col = math.floor((vim.o.columns - width) / 2),
        width = width,
        height = math.max(height, 1),
        border = "rounded",
        style = "minimal",
        title = " " .. title .. " ",
        footer = options.footer and (" " .. options.footer .. " ") or nil,
        footer_pos = options.footer and "right" or nil,
    })
    vim.wo[win].wrap = true
    vim.wo[win].linebreak = true
    for _, key in ipairs({ "q", "<Esc>" }) do
        vim.keymap.set("n", key, function()
            vim.api.nvim_win_close(win, true)
        end, { buffer = buf, nowait = true, silent = true })
    end
    return buf, win
end

local function show_thread(current, thread)
    local line = thread.new_line or thread.old_line
    local where = thread.path
            and (thread.path .. (line and (":" .. line) or ""))
        or "the merge request"
    local state = thread.resolved and "resolved"
        or (thread.resolvable and "open" or "comment")
    local lines = {
        ("GitLab thread on %s · %s%s"):format(
            where,
            state,
            thread.outdated and " · outdated" or ""
        ),
    }
    for _, note in ipairs(thread.notes) do
        table.insert(lines, "")
        table.insert(
            lines,
            ("%s (%s):"):format(note.author, (note.at or ""):sub(1, 10))
        )
        vim.list_extend(lines, vim.split(note.body, "\n"))
    end
    local buf = float(lines, "Thread", {
        footer = "<leader>rt reply · <leader>rx resolve · <leader>ri add to review · q close",
    })
    vim.b[buf].review_thread = thread.id
    vim.api.nvim_buf_set_extmark(
        buf,
        vim.api.nvim_create_namespace("review.thread"),
        0,
        0,
        {
            line_hl_group = "ReviewThread",
        }
    )
end

function M.mr_summary()
    with_session(function(current)
        local mr = require_mr(current)
        if not mr then
            return
        end
        local open, general = 0, 0
        for _, thread in ipairs(mr.threads) do
            if thread.resolvable and not thread.resolved then
                open = open + 1
            end
            if not thread.path then
                general = general + 1
            end
        end
        local lines = {
            ("!%d %s%s"):format(mr.iid, mr.draft and "Draft: " or "", mr.title),
            "",
            ("Author      %s"):format(mr.author or "?"),
            ("Target      %s"):format(mr.target or "?"),
            ("Pipeline    %s"):format(mr.pipeline or "none"),
            ("Threads     %d open of %d (%d general)"):format(
                open,
                #mr.threads,
                general
            ),
            ("Approved by %s"):format(
                #mr.approved_by > 0 and table.concat(mr.approved_by, ", ")
                    or "nobody yet"
            ),
            ("Link        %s"):format(mr.url),
        }
        if mr.refs and mr.refs.head_sha ~= current.repo.head then
            table.insert(lines, "")
            table.insert(
                lines,
                "Local HEAD isn't the MR head: pull before posting comments on lines."
            )
        end
        float(
            lines,
            "Merge request",
            { footer = "<leader>ro open in browser · q close" }
        )
    end)
end

function M.toggle_viewed()
    with_session(function(current)
        local path = M.current_path()
        if not path then
            util.warn("Not a file of this review")
            return
        end
        local viewed = current.state.viewed
        viewed[path] = not viewed[path] or nil
        current:save()
        vim.cmd.redrawstatus({ bang = true })
        util.notify(
            (viewed[path] and "Marked %s viewed" or "Marked %s not viewed"):format(
                path
            )
        )
    end)
end

local function after_scope_change(current)
    current:refresh(function(ok)
        if not ok then
            return
        end
        if #current.files == 0 then
            util.notify("Nothing to review: " .. current:scope_words())
            return
        end
        M.files()
    end)
end

function M.scope()
    with_session(function(current)
        local repo = current.repo
        local choices = {
            {
                key = "branch",
                label = "Branch vs "
                    .. (repo.base or "?")
                    .. " · everything the branch adds, committed or not",
            },
            {
                key = "work",
                label = "Uncommitted · staged, unstaged and new files",
            },
            {
                key = "since",
                label = "Since last send · "
                    .. (
                        repo.snapshot
                            and "what changed after the last review went out"
                        or "nothing sent yet"
                    ),
            },
        }
        for _, commit in ipairs(repo.commits) do
            table.insert(choices, {
                key = "commit:" .. commit.sha,
                label = ("%s %s · %s"):format(
                    commit.short,
                    commit.subject,
                    commit.ago
                ),
            })
        end
        vim.ui.select(choices, {
            prompt = "Review what",
            format_item = function(choice)
                return (choice.key == current.scope and "● " or "  ")
                    .. choice.label
            end,
        }, function(choice)
            if choice then
                current.scope = choice.key
                after_scope_change(current)
            end
        end)
    end)
end

function M.base()
    with_session(function(current)
        local automatic = current.mr
                and ("MR target origin/" .. current.mr.target)
            or "origin/HEAD, develop, main or master"
        local choices = { { key = nil, label = "Automatic · " .. automatic } }
        for _, branch in ipairs(current.repo.branches) do
            table.insert(choices, { key = branch, label = branch })
        end
        vim.ui.select(choices, {
            prompt = "Compare the branch against",
            format_item = function(choice)
                return (choice.key == current.state.base and "● " or "  ")
                    .. choice.label
            end,
        }, function(choice)
            if choice then
                current.state.base = choice.key
                current:save()
                current.scope = "branch"
                after_scope_change(current)
            end
        end)
    end)
end

function M.refresh()
    with_session(function(current)
        current:refresh(function(ok)
            if ok then
                util.notify(
                    ("%s · %s"):format(
                        current:scope_label(),
                        util.plural(#current.files, "file")
                    )
                )
            end
        end)
        current:load_mr()
    end)
end

function M.files()
    with_session(function(current)
        pickers.files(current, function(path)
            view.open(path)
        end)
    end)
end

function M.notes()
    with_session(function(current)
        pickers.notes(current, function(entry)
            local path, target
            if entry.kind == "comment" then
                path = entry.item.path
                local detail = current:detail(path)
                local line = detail
                    and diff.find_row(detail.rows, entry.item.to)
                target = line and { line = line } or nil
            else
                local thread = entry.item
                if not thread.path or not current.by_path[thread.path] then
                    show_thread(current, thread)
                    return
                end
                path = thread.path
                target = thread.new_line and { new = thread.new_line } or nil
            end
            if current.by_path[path] then
                view.open(path, target)
            else
                vim.cmd.edit(
                    vim.fn.fnameescape(current.repo.top .. "/" .. path)
                )
                if entry.item.to then
                    pcall(
                        vim.api.nvim_win_set_cursor,
                        0,
                        { entry.item.to.number, 0 }
                    )
                end
            end
        end)
    end)
end

function M.grep()
    with_session(function(current)
        pickers.grep(current, function(path, line)
            if current.by_path[path] then
                view.open(path, { new = line })
            end
        end)
    end)
end

M.KEYS = {
    {
        "<leader>rc",
        "comment on the line, or the selected lines (also in file buffers)",
    },
    { "<leader>re", "edit the comment on this line" },
    { "<leader>rd", "delete the comment on this line" },
    { "<leader>ru", "bring the last deleted comment back" },
    {
        "<leader>rz",
        "show a sent comment or resolved thread whole, or fold it again",
    },
    { "<leader>rs", "send every draft (and added threads) to the agent" },
    {
        "<leader>ra",
        "ask the agent about the selection or the change here, now",
    },
    { "<leader>rf", "changed files" },
    { "<leader>rl", "comments and GitLab threads, across files" },
    { "<leader>r/", "grep the changed files" },
    { "<leader>rv", "mark this file viewed, or not" },
    {
        "<leader>rw",
        "what to review: branch, uncommitted, since last send, a commit",
    },
    { "<leader>rb", "the base branch to compare against" },
    { "<leader>rr", "read the repo and merge request again" },
    { "<leader>rm", "merge request summary" },
    { "<leader>rt", "reply to the GitLab thread on this line" },
    { "<leader>rx", "resolve or reopen the thread on this line" },
    {
        "<leader>ri",
        "add the thread on this line to the next agent review, or take it out",
    },
    { "<leader>rI", "add every unresolved thread to the next agent review" },
    { "<leader>rp", "post every draft as one GitLab review" },
    { "<leader>rA", "approve the merge request" },
    { "<leader>ro", "open the merge request in the browser" },
    { "<leader>rq", "close the review (wipes its buffers)" },
    { "<leader>r?", "these keys" },
    { "]c  [c", "next / previous change (review buffers)" },
    { "]f  [f", "next / previous changed file (review buffers)" },
    { "<CR>", "open the file at this line (review buffers)" },
    { "zo zc zR zM", "open / close the folded unchanged lines" },
}

function M.help()
    local lines = {}
    for _, key in ipairs(M.KEYS) do
        table.insert(lines, ("%-12s %s"):format(key[1], key[2]))
    end
    float(lines, "Review keys", { width = 90, footer = "q close" })
end

function M.close()
    require("review.gitsigns").restore()
    local current = session.current
    session.current = nil
    if current then
        current:dispose()
    end
    notes.clear()
end

--- :Review — reads the repo of the working directory and shows the first
--- changed file with the file picker over it.
function M.open()
    local current = session.current
    local cwd = vim.fn.getcwd()
    local function show(ready)
        if #ready.files == 0 then
            util.notify("Nothing to review: " .. ready:scope_words())
            return
        end
        if not view.is_review() then
            view.open(ready.files[1].path)
        end
        M.files()
    end
    if
        current
        and current.repo
        and vim.startswith(cwd .. "/", current.repo.top .. "/")
    then
        current:refresh(function(ok)
            if ok then
                show(current)
            end
        end)
        return
    end
    session.ensure(cwd, show)
end

-- Reads older than this are read again when a review buffer is entered.
local STALE_MS = 5000

local group = vim.api.nvim_create_augroup("review.actions", { clear = true })
vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "ReviewRefreshed",
    callback = function()
        view.refresh_all()
        notes.refresh()
        vim.cmd.redrawstatus({ bang = true })
    end,
})
vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "ReviewMergeRequest",
    callback = function()
        notes.refresh()
        vim.cmd.redrawstatus({ bang = true })
    end,
})
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, {
    group = group,
    callback = function()
        local current = session.current
        if
            current
            and view.is_review()
            and not current.loading
            and vim.uv.now() - current.loaded_at > STALE_MS
        then
            current:refresh()
        end
    end,
})

return M
