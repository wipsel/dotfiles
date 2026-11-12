-- Review buffers: one per changed file (`review://<path>`), made when first
-- opened. Each shows the whole new file with the removed lines put back where
-- they were removed, coloured by kind, with old/new line numbers and +/− signs
-- in its statuscolumn and the unchanged stretches folded.
local diff = require("review.diff")
local highlight = require("review.highlight")
local util = require("review.util")

local M = {}

local lines_namespace = vim.api.nvim_create_namespace("review.lines")
-- Unchanged lines kept open around each change, comment and thread.
local CONTEXT = 3
-- Shorter unchanged stretches aren't worth a fold.
local MIN_FOLD = 4
local PREFIX = "review://"

-- buffer → { path, rows, hunks, digits, folds, tick, marks, key, empty }
---@type table<integer, table>
local buffers = {}
-- window → buffer → the tick its folds were made for
---@type table<integer, table<integer, integer>>
local folded = {}

function M.state(buf)
    return buffers[buf or vim.api.nvim_get_current_buf()]
end

function M.is_review(buf)
    return buffers[buf or vim.api.nvim_get_current_buf()] ~= nil
end

local function session()
    return require("review.session").current
end

local function set_window_options(win)
    local function set(name, value)
        vim.api.nvim_set_option_value(
            name,
            value,
            { scope = "local", win = win }
        )
    end
    set("statuscolumn", "%!v:lua.require'review.view'.statuscolumn()")
    set("number", true)
    set("relativenumber", false)
    set("signcolumn", "no")
    set("foldcolumn", "0")
    set("foldmethod", "manual")
    set("foldenable", true)
    set("foldlevel", 0)
    set("foldtext", "v:lua.require'review.view'.foldtext()")
    set("fillchars", "fold: ")
    set("winbar", "%!v:lua.require'review.view'.winbar()")
    set("spell", false)
end

-- Where each unchanged stretch is folded: all but CONTEXT lines next to a
-- change or note.
local function fold_ranges(state, anchored)
    local keep = {}
    for line, row in ipairs(state.rows) do
        if row.kind ~= " " or anchored[line] then
            keep[line] = true
        end
    end
    local ranges, count = {}, #state.rows
    local line = 1
    while line <= count do
        if keep[line] then
            line = line + 1
        else
            local stretch_end = line
            while stretch_end + 1 <= count and not keep[stretch_end + 1] do
                stretch_end = stretch_end + 1
            end
            local from = line > 1 and line + CONTEXT or line
            local to = stretch_end < count and stretch_end - CONTEXT
                or stretch_end
            if to - from + 1 >= MIN_FOLD then
                table.insert(ranges, { from, to })
            end
            line = stretch_end + 1
        end
    end
    return ranges
end

local function apply_folds(win, buf)
    local state = buffers[buf]
    if not state or not vim.api.nvim_win_is_valid(win) then
        return
    end
    vim.api.nvim_win_call(win, function()
        vim.cmd("silent! normal! zE")
        for _, range in ipairs(state.folds) do
            vim.cmd(("silent! %d,%dfold"):format(range[1], range[2]))
        end
    end)
    folded[win] = folded[win] or {}
    folded[win][buf] = state.tick
end

--- Folds made again in every window showing `buf`, e.g. after its notes moved.
function M.refold(buf, anchored)
    local state = buffers[buf]
    if not state then
        return
    end
    state.folds = fold_ranges(state, anchored or {})
    state.tick = state.tick + 1
    for _, win in ipairs(vim.fn.win_findbuf(buf)) do
        apply_folds(win, buf)
    end
end

--- Whether `line` of `buf` is hidden in a closed fold in any window.
function M.in_closed_fold(buf, line)
    for _, win in ipairs(vim.fn.win_findbuf(buf)) do
        local closed = vim.api.nvim_win_call(win, function()
            return vim.fn.foldclosed(line)
        end)
        if closed ~= -1 then
            return true
        end
    end
    return false
end

-- A highlight over the changed middle of each removed/added line pair: what
-- differs after the common start and end.
local function mark_words(buf, rows, from, to)
    local removed, added = {}, {}
    for line = from, to do
        table.insert(rows[line].kind == "-" and removed or added, line)
    end
    if #removed ~= #added then
        return
    end
    for index, old_line in ipairs(removed) do
        local new_line = added[index]
        local old_text, new_text = rows[old_line].text, rows[new_line].text
        local start = 1
        while
            start <= #old_text
            and start <= #new_text
            and old_text:byte(start) == new_text:byte(start)
        do
            start = start + 1
        end
        local old_end, new_end = #old_text, #new_text
        while
            old_end >= start
            and new_end >= start
            and old_text:byte(old_end) == new_text:byte(new_end)
        do
            old_end, new_end = old_end - 1, new_end - 1
        end
        if start > 1 or old_end < #old_text then
            if old_end >= start then
                vim.api.nvim_buf_set_extmark(
                    buf,
                    lines_namespace,
                    old_line - 1,
                    start - 1,
                    {
                        end_col = old_end,
                        hl_group = "ReviewDeleteText",
                        priority = 150,
                    }
                )
            end
            if new_end >= start then
                vim.api.nvim_buf_set_extmark(
                    buf,
                    lines_namespace,
                    new_line - 1,
                    start - 1,
                    {
                        end_col = new_end,
                        hl_group = "ReviewAddText",
                        priority = 150,
                    }
                )
            end
        end
    end
end

local function language_of(path)
    local filetype = vim.filetype.match({ filename = path })
    return filetype and vim.treesitter.language.get_lang(filetype) or nil
end

local function placeholder(detail)
    if not detail then
        return "Not changed in this scope"
    end
    if detail.failed then
        return "Could not read this file's diff"
    end
    if detail.binary then
        return "Binary file"
    end
    return "No changes to the text (only the file mode)"
end

--- Draws `detail` (Session:detail) into `buf`.
function M.render(buf, detail)
    local state = buffers[buf]
    local rows = detail and detail.rows or {}
    local lines = {}
    for index, row in ipairs(rows) do
        lines[index] = row.text
    end
    state.empty = #rows == 0
    if state.empty then
        lines = { placeholder(detail) }
    end
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
    vim.bo[buf].modified = false
    vim.api.nvim_buf_clear_namespace(buf, lines_namespace, 0, -1)
    state.rows = rows
    state.hunks = {}
    state.marks = {}
    local largest = 0
    local run_start = nil
    for line, row in ipairs(rows) do
        largest = math.max(largest, row.number, row.old or 0)
        if row.kind ~= " " then
            -- A range rather than line_hl_group, which would cover the word
            -- highlights whatever their priority.
            vim.api.nvim_buf_set_extmark(buf, lines_namespace, line - 1, 0, {
                end_row = line,
                end_col = 0,
                hl_eol = true,
                hl_group = row.kind == "+" and "ReviewAdd" or "ReviewDelete",
                priority = 10,
                strict = false,
            })
            run_start = run_start or line
        end
        local next_row = rows[line + 1]
        if run_start and (not next_row or next_row.kind == " ") then
            table.insert(state.hunks, run_start)
            mark_words(buf, rows, run_start, line)
            run_start = nil
        end
    end
    state.digits = math.max(#tostring(largest), 2)
    state.key = detail and detail.key or "none"
    M.refold(buf, require("review.notes").decorate(buf))
end

local function set_keymaps(buf)
    local function map(lhs, fn, desc)
        vim.keymap.set(
            "n",
            lhs,
            fn,
            { buffer = buf, silent = true, nowait = true, desc = desc }
        )
    end
    map("]c", function()
        M.jump_hunk(1)
    end, "Next change")
    map("[c", function()
        M.jump_hunk(-1)
    end, "Previous change")
    map("]f", function()
        M.jump_file(1)
    end, "Next changed file")
    map("[f", function()
        M.jump_file(-1)
    end, "Previous changed file")
    map("<CR>", M.open_real_file, "Open the file at this line")
end

local function create(current, path)
    local buf = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_buf_set_name(buf, PREFIX .. path)
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "hide"
    vim.bo[buf].swapfile = false
    vim.bo[buf].undolevels = -1
    vim.b[buf].review_path = path
    buffers[buf] = {
        path = path,
        rows = {},
        hunks = {},
        marks = {},
        folds = {},
        tick = 0,
        digits = 2,
    }
    current.buffers[path] = buf
    set_keymaps(buf)
    local language = language_of(path)
    if language then
        pcall(vim.treesitter.start, buf, language)
    end
    M.render(buf, current:detail(path))
    vim.bo[buf].readonly = true
    return buf
end

--- The review buffer of `path`, made and drawn when there is none yet.
function M.buffer(path)
    local current = session()
    local buf = current.buffers[path]
    if buf and vim.api.nvim_buf_is_valid(buf) and buffers[buf] then
        return buf
    end
    return create(current, path)
end

--- The first line of `buf` whose row passes `test`.
local function line_where(buf, test)
    for line, row in ipairs(buffers[buf].rows) do
        if test(row) then
            return line
        end
    end
    return nil
end

-- The empty buffer Neovim starts with, which nothing else shows.
local function is_blank(buf)
    return vim.api.nvim_buf_get_name(buf) == ""
        and vim.bo[buf].buftype == ""
        and not vim.bo[buf].modified
        and vim.api.nvim_buf_line_count(buf) == 1
        and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == ""
        and #vim.fn.win_findbuf(buf) == 0
end

--- Shows the review buffer of `path` in the current window. `target`: { new =
--- number } puts the cursor on that new-file line, { line = n } on that buffer
--- line, else on the first change.
function M.open(path, target)
    local buf = M.buffer(path)
    local previous = vim.api.nvim_get_current_buf()
    vim.api.nvim_win_set_buf(0, buf)
    if previous ~= buf and is_blank(previous) then
        pcall(vim.api.nvim_buf_delete, previous, {})
    end
    local state = buffers[buf]
    local line
    if target and target.line then
        line = target.line
    elseif target and target.new then
        line = line_where(buf, function(row)
            return row.kind ~= "-" and row.number >= target.new
        end)
    end
    line = line or state.hunks[1] or 1
    line = math.max(1, math.min(line, vim.api.nvim_buf_line_count(buf)))
    vim.api.nvim_win_set_cursor(0, { line, 0 })
    vim.cmd("silent! normal! zv")
    return buf
end

--- Draws the open review buffers again where their file's diff changed (after a
--- refresh).
function M.refresh_all()
    local current = session()
    if not current then
        return
    end
    for path, buf in pairs(current.buffers) do
        local state = buffers[buf]
        if state and vim.api.nvim_buf_is_valid(buf) then
            local detail = current:detail(path)
            if (detail and detail.key or "none") ~= state.key then
                local cursors = {}
                for _, win in ipairs(vim.fn.win_findbuf(buf)) do
                    local line = vim.api.nvim_win_get_cursor(win)[1]
                    cursors[win] = state.rows[line]
                end
                M.render(buf, detail)
                for win, row in pairs(cursors) do
                    local line = diff.find_row(state.rows, row) or 1
                    pcall(vim.api.nvim_win_set_cursor, win, { line, 0 })
                end
            end
        end
    end
end

function M.jump_hunk(direction)
    local state = buffers[vim.api.nvim_get_current_buf()]
    local cursor = vim.api.nvim_win_get_cursor(0)[1]
    local hunks = state.hunks
    local target
    if direction > 0 then
        for _, line in ipairs(hunks) do
            if line > cursor then
                target = line
                break
            end
        end
    else
        for index = #hunks, 1, -1 do
            if hunks[index] < cursor then
                target = hunks[index]
                break
            end
        end
    end
    if not target then
        util.notify(
            direction > 0 and "No more changes in this file"
                or "No earlier changes"
        )
        return
    end
    vim.cmd("normal! m'")
    vim.api.nvim_win_set_cursor(0, { target, 0 })
    vim.cmd("silent! normal! zv")
end

--- The changed file `direction` files after (or before) the current one, in
--- diff order.
function M.jump_file(direction)
    local current = session()
    local path = vim.b.review_path or require("review.actions").current_path()
    local index = path and current.order[path]
    local target
    if index then
        target = current.files[index + direction]
    else
        target = current.files[direction > 0 and 1 or #current.files]
    end
    if not target then
        util.notify(
            direction > 0 and "This is the last changed file"
                or "This is the first one"
        )
        return
    end
    M.open(target.path)
end

--- The new-file line a buffer line stands for: its own for added and unchanged
--- lines, the next kept line's for removed ones.
function M.new_line_at(buf, line)
    local rows = buffers[buf].rows
    for index = line, #rows do
        if rows[index].kind ~= "-" then
            return rows[index].number
        end
    end
    for index = line, 1, -1 do
        if rows[index].kind ~= "-" then
            return rows[index].number + 1
        end
    end
    return 1
end

function M.open_real_file()
    local buf = vim.api.nvim_get_current_buf()
    local state = buffers[buf]
    local current = session()
    local line = state.empty and 1
        or M.new_line_at(buf, vim.api.nvim_win_get_cursor(0)[1])
    local file = current.repo.top .. "/" .. state.path
    if vim.fn.filereadable(file) == 0 then
        util.warn(state.path .. " isn't in the working tree")
        return
    end
    vim.cmd.edit(vim.fn.fnameescape(file))
    local count = vim.api.nvim_buf_line_count(0)
    vim.api.nvim_win_set_cursor(0, { math.min(line, count), 0 })
    vim.cmd("silent! normal! zvzz")
    require("review.gitsigns").follow(vim.api.nvim_get_current_buf())
end

function M.statuscolumn()
    local win = vim.g.statusline_winid
    local buf = vim.api.nvim_win_get_buf(win)
    local state = buffers[buf]
    if not state then
        return ""
    end
    local width = state.digits
    local blank = (" "):rep(width * 2 + 4)
    if vim.v.virtnum ~= 0 then
        return blank
    end
    local line = vim.v.lnum
    local row = state.rows[line]
    if not row then
        return blank
    end
    local mark = state.marks[line]
    local out = mark and ("%#" .. mark .. "#▎") or " "
    local number_group = vim.v.relnum == 0 and "%#CursorLineNr#" or "%#LineNr#"
    local old = row.kind == "-" and row.number or row.old
    local new = row.kind ~= "-" and row.number or nil
    local function pad(number)
        local text = number and tostring(number) or ""
        return (" "):rep(width - #text) .. text
    end
    out = out .. number_group .. pad(old) .. " " .. pad(new) .. " "
    if row.kind == "+" then
        return out .. "%#ReviewSignAdd#+ "
    elseif row.kind == "-" then
        return out .. "%#ReviewSignDelete#− "
    end
    return out .. "  "
end

function M.foldtext()
    local count = vim.v.foldend - vim.v.foldstart + 1
    return { { ("⋯ %d unchanged lines"):format(count), "ReviewFold" } }
end

function M.winbar()
    local win = vim.g.statusline_winid
    local buf = vim.api.nvim_win_get_buf(win)
    local state = buffers[buf]
    local current = session()
    if not state or not current then
        return ""
    end
    local file = current.by_path[state.path]
    local parts = {}
    local escape = function(text)
        return (text:gsub("%%", "%%%%"))
    end
    local status = file and file.status or " "
    table.insert(
        parts,
        "%#ReviewWinbar# " .. status .. " " .. escape(state.path)
    )
    if file then
        table.insert(
            parts,
            ("%%#ReviewSignAdd#+%d %%#ReviewSignDelete#−%d"):format(
                file.add,
                file.del
            )
        )
    end
    local info = {}
    local index = current.order[state.path]
    table.insert(
        info,
        (index and tostring(index) or "–") .. "/" .. #current.files
    )
    if current.state and current.state.viewed[state.path] then
        table.insert(info, "viewed")
    end
    table.insert(info, escape(current:scope_label()))
    if current.mr then
        table.insert(info, "!" .. current.mr.iid)
    end
    table.insert(parts, "%#ReviewWinbarDim#" .. table.concat(info, " · "))
    return table.concat(parts, "  ")
end

-- Window-local options set here apply to the review buffer in that window only:
-- Neovim gives other buffers shown there their own values back.
local function on_buf_win_enter(args)
    local buf = args.buf
    if not buffers[buf] then
        return
    end
    local win = vim.api.nvim_get_current_win()
    set_window_options(win)
    if not (folded[win] and folded[win][buf] == buffers[buf].tick) then
        apply_folds(win, buf)
    end
end

local group = vim.api.nvim_create_augroup("review.view", { clear = true })
vim.api.nvim_create_autocmd(
    "BufWinEnter",
    { group = group, callback = on_buf_win_enter }
)
vim.api.nvim_create_autocmd("BufWipeout", {
    group = group,
    callback = function(args)
        if buffers[args.buf] then
            local current = session()
            if
                current
                and current.buffers[buffers[args.buf].path] == args.buf
            then
                current.buffers[buffers[args.buf].path] = nil
            end
            buffers[args.buf] = nil
        end
    end,
})
vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    callback = function(args)
        folded[tonumber(args.match)] = nil
    end,
})

highlight.setup()

return M
