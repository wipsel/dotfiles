-- What goes to the agent: the review as one message, or a question about some
-- lines.
local diff = require("review.diff")
local util = require("review.util")

local M = {}

local function lines_label(comment)
    if comment.from.number == comment.to.number then
        return "line " .. comment.to.number
    end
    return ("lines %d-%d"):format(comment.from.number, comment.to.number)
end

--- The review message: every comment with its lines, then the GitLab threads
--- added to it. `where` names the checkout, `scope_words` what is being
--- reviewed.
function M.review(where, scope_words, comments, threads, mr, note)
    local sorted = vim.deepcopy(comments)
    table.sort(sorted, function(a, b)
        if a.path ~= b.path then
            return a.path < b.path
        end
        return a.to.number < b.to.number
    end)
    local parts = {}
    for _, comment in ipairs(sorted) do
        table.insert(
            parts,
            ("### %s, %s\n%s\n\nComment: %s"):format(
                comment.path,
                lines_label(comment),
                table.concat(comment.quote or {}, "\n"),
                comment.text
            )
        )
    end
    for _, thread in ipairs(threads) do
        local at = "the merge request"
        if thread.path then
            local line = thread.new_line or thread.old_line
            at = thread.path .. (line and (", line " .. line) or "")
        end
        local notes = vim.tbl_map(function(item)
            return item.author .. ": " .. item.body
        end, thread.notes)
        table.insert(
            parts,
            ("### GitLab thread on %s (%s)\n\n%s"):format(
                at,
                thread.url,
                table.concat(notes, "\n\n")
            )
        )
    end
    local counts = {}
    if #comments > 0 then
        table.insert(counts, util.plural(#comments, "comment"))
    end
    if #threads > 0 then
        table.insert(counts, util.plural(#threads, "GitLab thread"))
    end
    local from_mr = ""
    if #threads > 0 and mr then
        from_mr = (" The GitLab threads are from merge request !%d; treat them as review comments too, and reply on GitLab only if asked."):format(
            mr.iid
        )
    end
    local head = ('Code review of %s (%s): %s. Line numbers are new-file numbers; "-" lines are removed ones.%s'):format(
        where,
        scope_words,
        table.concat(counts, ", "),
        from_mr
    )
    local out = {}
    if note and vim.trim(note) ~= "" then
        table.insert(out, vim.trim(note))
    end
    table.insert(out, head)
    vim.list_extend(out, parts)
    return table.concat(out, "\n\n")
end

--- A question about some rows of a file, sent at once.
function M.ask(where, scope_words, path, rows, question)
    local quoted = vim.tbl_map(diff.quote_row, rows)
    return ("%s\n\nAbout %s in %s (%s):\n%s"):format(
        vim.trim(question),
        path,
        where,
        scope_words,
        table.concat(quoted, "\n")
    )
end

return M
