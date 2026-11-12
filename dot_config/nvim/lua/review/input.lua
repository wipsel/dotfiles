-- A small floating window for multi-line text (comments, replies, notes,
-- questions), opened under the cursor line, or above it when there's no room
-- below.
local M = {}

local MAX_HEIGHT = 15

--- Opens the input. `options`: { title, text (initial), allow_empty }. Calls
--- `on_done(text)` with the trimmed text when saved, or `on_done(nil)` when
--- cancelled.
function M.open(options, on_done)
    local origin = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = "wipe"
    vim.b[buf].completion = false
    local initial = vim.split(options.text or "", "\n", { plain = true })
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, initial)

    local width = math.min(vim.o.columns - 4, 100)
    local cursor_row = vim.fn.screenpos(origin, vim.fn.line("."), 1).row
    local below = vim.o.lines - cursor_row - 3
    local height = math.max(3, math.min(#initial, MAX_HEIGHT))
    local row = cursor_row
    if below < height + 2 then
        row = math.max(cursor_row - height - 3, 0)
    end
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        row = row,
        col = math.max(math.floor((vim.o.columns - width) / 2) - 1, 0),
        width = width,
        height = height,
        border = "rounded",
        style = "minimal",
        title = " " .. options.title .. " ",
        title_pos = "left",
        footer = " ctrl-s save · q cancel ",
        footer_pos = "right",
    })
    vim.wo[win].wrap = true
    vim.wo[win].linebreak = true

    local finished = false
    local function finish(text)
        if finished then
            return
        end
        finished = true
        vim.cmd.stopinsert()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
        if vim.api.nvim_win_is_valid(origin) then
            vim.api.nvim_set_current_win(origin)
        end
        on_done(text)
    end
    local function save()
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local text = vim.trim(table.concat(lines, "\n"))
        if text == "" and not options.allow_empty then
            vim.notify(
                "Type something first, or cancel with q",
                vim.log.levels.WARN
            )
            return
        end
        finish(text)
    end
    local function cancel()
        finish(nil)
    end
    local function map(modes, lhs, fn)
        vim.keymap.set(
            modes,
            lhs,
            fn,
            { buffer = buf, nowait = true, silent = true }
        )
    end
    map({ "n", "i" }, "<C-s>", save)
    map("n", "<CR>", save)
    map("n", "q", cancel)
    map("n", "<Esc>", cancel)

    local function fit()
        if not vim.api.nvim_win_is_valid(win) then
            return
        end
        local lines = vim.api.nvim_buf_line_count(buf)
        local wanted = vim.api.nvim_win_text_height(
            win,
            { start_row = 0, end_row = lines - 1 }
        ).all
        vim.api.nvim_win_set_height(
            win,
            math.max(3, math.min(wanted, MAX_HEIGHT))
        )
    end
    vim.api.nvim_create_autocmd(
        { "TextChanged", "TextChangedI" },
        { buffer = buf, callback = fit }
    )
    vim.api.nvim_create_autocmd("WinLeave", {
        buffer = buf,
        once = true,
        callback = function()
            vim.schedule(cancel)
        end,
    })
    if options.text and options.text ~= "" then
        vim.api.nvim_win_set_cursor(win, { #initial, #initial[#initial] })
        vim.cmd("startinsert!")
    else
        vim.cmd.startinsert()
    end
end

return M
