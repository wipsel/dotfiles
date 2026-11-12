-- Comments and GitLab threads drawn as virtual lines under their last line, in
-- review buffers and in the real files' buffers. A note that can't be placed in
-- a review buffer (its line is gone, or the thread is outdated) goes above the
-- first line.
local diff = require("review.diff")
local util = require("review.util")
local view = require("review.view")

local M = {}

local namespace = vim.api.nvim_create_namespace("review.notes")
-- buffer → { { kind = "comment" | "thread", id, line, from } }
local placed = {}
-- Sent comments and resolved threads opened up to show whole.
local expanded = {}

local function session()
    return require("review.session").current
end

--- The repo path of a real file's buffer in the current review, or nil.
function M.real_path(buf)
    local current = session()
    if not current or not current.repo or vim.bo[buf].buftype ~= "" then
        return nil
    end
    local name = vim.api.nvim_buf_get_name(buf)
    local top = current.repo.top .. "/"
    if name:sub(1, #top) ~= top then
        return nil
    end
    return name:sub(#top + 1)
end

local function lines_label(comment)
    if comment.from.number == comment.to.number then
        return "line " .. comment.to.number
    end
    return ("lines %d–%d"):format(comment.from.number, comment.to.number)
end

local function text_width(buf)
    local win = vim.fn.win_findbuf(buf)[1]
    if win then
        local info = vim.fn.getwininfo(win)[1]
        return info.width - info.textoff - 3
    end
    return vim.o.columns - 20
end

local function first_line(text)
    return (text:match("^[^\n]*") or "")
end

-- The header with as much of `text` after it as fits in `width`.
local function with_preview(header, text, width, group)
    local used = 0
    for _, chunk in ipairs(header) do
        used = used + vim.fn.strdisplaywidth(chunk[1])
    end
    local room = width - used - 2
    if room > 3 then
        table.insert(header, { "  " .. util.truncate(text, room), group })
    end
    return header
end

local function comment_lines(comment, width, gone)
    local draft = comment.state == "draft"
    local bar = { "▎ ", draft and "ReviewDraft" or "ReviewSent" }
    local header = {
        bar,
        {
            draft and "✎ You" or "✓ You",
            draft and "ReviewDraft" or "ReviewSent",
        },
        {
            " · " .. (draft and "draft" or "sent") .. " · " .. lines_label(
                comment
            ),
            "ReviewSent",
        },
    }
    if gone then
        table.insert(header, { " · line gone", "ReviewTag" })
    end
    if not draft and not expanded[comment.id] then
        return {
            with_preview(header, first_line(comment.text), width, "ReviewSent"),
        }
    end
    local out = { header }
    for _, line in ipairs(util.wrap(comment.text, width - 2)) do
        table.insert(
            out,
            { bar, { line, draft and "ReviewDraftText" or "ReviewSent" } }
        )
    end
    return out
end

local function thread_lines(thread, width, where)
    local current = session()
    local collapsed = thread.resolved and not expanded[thread.id]
    local accent = collapsed and "ReviewResolved" or "ReviewThread"
    local bar = { "▎ ", accent }
    local state = thread.resolved and "resolved"
        or (thread.resolvable and "open" or "comment")
    local header = {
        bar,
        {
            (thread.resolved and "✓ " or "● ") .. thread.notes[1].author,
            accent,
        },
        { " · GitLab · " .. state, "ReviewSent" },
    }
    if where then
        table.insert(header, { " · " .. where, "ReviewSent" })
    end
    if thread.outdated then
        table.insert(header, { " · outdated", "ReviewTag" })
    end
    if current and current:included(thread.id) then
        table.insert(header, { " · in next review", "ReviewIncluded" })
    end
    if collapsed then
        return {
            with_preview(
                header,
                first_line(thread.notes[1].body),
                width,
                "ReviewResolved"
            ),
        }
    end
    local out = { header }
    for index, note in ipairs(thread.notes) do
        if index > 1 then
            table.insert(out, { bar, { note.author, accent } })
        end
        for _, line in ipairs(util.wrap(note.body, width - 4)) do
            table.insert(out, { bar, { "  " .. line, "ReviewThreadText" } })
        end
    end
    return out
end

-- Where a thread sits in a review buffer's rows: its new-file line among added
-- and unchanged rows, else its removed line. Outdated threads point into an
-- older version, so nowhere.
local function thread_row(rows, thread)
    if thread.outdated then
        return nil
    end
    for index, row in ipairs(rows) do
        if thread.new_line then
            if row.kind ~= "-" and row.number == thread.new_line then
                return index
            end
        elseif thread.old_line then
            if
                (row.kind == "-" and row.number == thread.old_line)
                or (row.kind == " " and row.old == thread.old_line)
            then
                return index
            end
        end
    end
end

-- Where an anchor sits in a real file's buffer: its new-file line if the text
-- there still matches, else the nearest line with the same text. Removed lines
-- aren't in the file.
local function real_line(buf, anchor)
    if not anchor or anchor.kind == "-" then
        return nil
    end
    local count = vim.api.nvim_buf_line_count(buf)
    local function text_at(line)
        return vim.api.nvim_buf_get_lines(buf, line - 1, line, false)[1]
    end
    if anchor.number <= count and text_at(anchor.number) == anchor.text then
        return anchor.number
    end
    for distance = 1, 200 do
        for _, line in ipairs({
            anchor.number - distance,
            anchor.number + distance,
        }) do
            if line >= 1 and line <= count and text_at(line) == anchor.text then
                return line
            end
        end
    end
end

--- Draws the notes of `buf` (a review buffer or a real file's buffer) again.
--- Returns the set of lines that carry a note, which folds keep open.
function M.decorate(buf, from_render)
    local current = session()
    vim.api.nvim_buf_clear_namespace(buf, namespace, 0, -1)
    placed[buf] = {}
    local anchored = {}
    if not current or not vim.api.nvim_buf_is_valid(buf) then
        return anchored
    end
    local state = view.state(buf)
    local path = state and state.path or M.real_path(buf)
    if not path then
        return anchored
    end
    local width = text_width(buf)
    local marks = {}
    local above = {}
    local function put(line, virtual_lines, item)
        if line then
            vim.api.nvim_buf_set_extmark(buf, namespace, line - 1, 0, {
                virt_lines = virtual_lines,
            })
            anchored[line] = true
            item.line = line
            table.insert(placed[buf], item)
        elseif state then
            vim.list_extend(above, virtual_lines)
            item.line = 1
            table.insert(placed[buf], item)
        end
    end
    local empty = state and state.empty
    for _, comment in ipairs(current:comments()) do
        if comment.path == path and comment.state ~= "posted" then
            local line, from
            if state and not empty then
                line = diff.find_row(state.rows, comment.to)
                from = diff.find_row(state.rows, comment.from) or line
            elseif not state then
                line = real_line(buf, comment.to)
                from = real_line(buf, comment.from) or line
            end
            put(line, comment_lines(comment, width, state and not line), {
                kind = "comment",
                id = comment.id,
                from = (from and line) and math.min(from, line) or nil,
            })
            if line then
                for marked = math.min(from, line), line do
                    marks[marked] = comment.state == "draft" and "ReviewDraft"
                        or "ReviewSent"
                end
            end
        end
    end
    for _, thread in ipairs(current:threads()) do
        if thread.path == path then
            local line
            if state and not empty then
                line = thread_row(state.rows, thread)
            elseif not state and not thread.outdated and thread.new_line then
                line = thread.new_line <= vim.api.nvim_buf_line_count(buf)
                        and thread.new_line
                    or nil
            end
            local where = nil
            if not line then
                local number = thread.new_line or thread.old_line
                where = number and ("line " .. number) or "file"
            end
            put(
                line,
                thread_lines(thread, width, where),
                { kind = "thread", id = thread.id }
            )
            if line then
                marks[line] = marks[line] or "ReviewThread"
            end
        end
    end
    if #above > 0 then
        vim.api.nvim_buf_set_extmark(buf, namespace, 0, 0, {
            virt_lines = above,
            virt_lines_above = true,
        })
    end
    if state then
        state.marks = marks
        if not from_render then
            for line in pairs(anchored) do
                if view.in_closed_fold(buf, line) then
                    view.refold(buf, anchored)
                    break
                end
            end
        end
    end
    return anchored
end

--- Draws the notes again everywhere: review buffers and loaded buffers of the
--- repo's files.
function M.refresh()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if
            vim.api.nvim_buf_is_loaded(buf)
            and (view.is_review(buf) or M.real_path(buf))
        then
            M.decorate(buf)
        end
    end
end

--- The notes at `line` of `buf`: those hanging under it first, then those whose
--- lines cover it.
function M.at(buf, line)
    local under, covering = {}, {}
    for _, item in ipairs(placed[buf] or {}) do
        if item.line == line then
            table.insert(under, item)
        elseif item.from and item.from <= line and line < item.line then
            table.insert(covering, item)
        end
    end
    return vim.list_extend(under, covering)
end

--- Takes every note off every buffer, for when the review closes.
function M.clear()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_clear_namespace(buf, namespace, 0, -1)
        end
    end
    placed = {}
end

function M.toggle_expanded(id)
    expanded[id] = not expanded[id] or nil
end

local group = vim.api.nvim_create_augroup("review.notes", { clear = true })
vim.api.nvim_create_autocmd("BufWinEnter", {
    group = group,
    callback = function(args)
        if
            session()
            and not view.is_review(args.buf)
            and M.real_path(args.buf)
        then
            M.decorate(args.buf)
        end
    end,
})
vim.api.nvim_create_autocmd({ "WinResized", "VimResized" }, {
    group = group,
    callback = function()
        if not session() then
            return
        end
        local seen = {}
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            local buf = vim.api.nvim_win_get_buf(win)
            if not seen[buf] and (view.is_review(buf) or M.real_path(buf)) then
                seen[buf] = true
                M.decorate(buf)
            end
        end
    end,
})

return M
