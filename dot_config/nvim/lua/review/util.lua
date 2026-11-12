local M = {}

--- Runs a program without blocking and calls `on_done({ code, stdout, stderr
--- })` on the main loop. A program that isn't installed gives code -1 and says
--- so in stderr, so callers handle it like any other failure (remote machines
--- may lack glab or hc).
function M.run(command, options, on_done)
    options = options or {}
    local ok, started = pcall(vim.system, command, {
        cwd = options.cwd,
        stdin = options.stdin,
        text = true,
        timeout = options.timeout,
    }, function(result)
        vim.schedule(function()
            on_done({
                code = result.code,
                stdout = result.stdout or "",
                stderr = result.stderr or "",
            })
        end)
    end)
    if not ok then
        local message = tostring(started)
        if message:find("ENOENT") or message:find("not executable") then
            message = command[1] .. " is not installed here"
        end
        vim.schedule(function()
            on_done({ code = -1, stdout = "", stderr = message })
        end)
    end
end

--- The same, waiting for the result: for the few reads an action needs before
--- it can go on.
function M.run_wait(command, options)
    options = options or {}
    local ok, process = pcall(vim.system, command, {
        cwd = options.cwd,
        text = true,
        timeout = options.timeout or 10000,
    })
    if not ok then
        return {
            code = -1,
            stdout = "",
            stderr = command[1] .. " is not installed here",
        }
    end
    local result = process:wait()
    return {
        code = result.code,
        stdout = result.stdout or "",
        stderr = result.stderr or "",
    }
end

--- The last meaningful line of a failed run, for a notification.
function M.failure(result, fallback)
    local text =
        vim.trim(result.stderr ~= "" and result.stderr or result.stdout)
    local lines = vim.split(text, "\n", { trimempty = true })
    return lines[#lines] or fallback
end

local function resume(routine, ...)
    local ok, err = coroutine.resume(routine, ...)
    if not ok then
        vim.notify("review: " .. tostring(err), vim.log.levels.ERROR)
    end
end

--- Runs `fn` as a coroutine, so it can `await` callbacks in sequence.
function M.async(fn, ...)
    resume(coroutine.create(fn), ...)
end

--- Inside `async`: starts `start(callback)` and returns what the callback gets.
function M.await(start)
    local routine = coroutine.running()
    local done, values = false, nil
    start(function(...)
        values = { n = select("#", ...), ... }
        if coroutine.status(routine) == "suspended" then
            resume(routine)
        else
            done = true
        end
    end)
    if not done then
        coroutine.yield()
    end
    return unpack(values, 1, values.n)
end

--- `M.run` as a coroutine step.
function M.run_async(command, options)
    return M.await(function(callback)
        M.run(command, options, callback)
    end)
end

function M.notify(message, level)
    level = level or vim.log.levels.INFO
    if level == vim.log.levels.INFO then
        -- A longer message would stop Neovim at a hit-enter prompt in a narrow
        -- pane.
        message = M.truncate(message, math.max(vim.v.echospace - 1, 20))
    end
    vim.notify(message, level, { title = "review" })
end

function M.error(message)
    M.notify(message, vim.log.levels.ERROR)
end

function M.warn(message)
    M.notify(message, vim.log.levels.WARN)
end

--- Splits text into lines of at most `width` display cells, breaking at spaces
--- where it can.
function M.wrap(text, width)
    width = math.max(width, 10)
    local out = {}
    for _, paragraph in ipairs(vim.split(text, "\n", { plain = true })) do
        local line = ""
        for word in paragraph:gmatch("%S+") do
            local candidate = line == "" and word or (line .. " " .. word)
            if vim.fn.strdisplaywidth(candidate) <= width then
                line = candidate
            else
                if line ~= "" then
                    table.insert(out, line)
                end
                while vim.fn.strdisplaywidth(word) > width do
                    local piece = vim.fn.strcharpart(word, 0, width)
                    table.insert(out, piece)
                    word = vim.fn.strcharpart(word, vim.fn.strchars(piece))
                end
                line = word
            end
        end
        table.insert(out, line)
    end
    return out
end

--- Cuts text to `width` display cells, ending in an ellipsis when it was
--- longer.
function M.truncate(text, width)
    if vim.fn.strdisplaywidth(text) <= width then
        return text
    end
    return vim.fn.strcharpart(text, 0, math.max(width - 1, 0)) .. "…"
end

--- Cuts text to `width` display cells from the start, for paths whose end
--- matters most.
function M.truncate_start(text, width)
    local length = vim.fn.strchars(text)
    if vim.fn.strdisplaywidth(text) <= width then
        return text
    end
    return "…" .. vim.fn.strcharpart(text, length - math.max(width - 1, 0))
end

function M.plural(count, word)
    return ("%d %s%s"):format(count, word, count == 1 and "" or "s")
end

function M.new_id()
    return ("%x%04x"):format(os.time(), vim.uv.hrtime() % 0x10000)
end

--- Milliseconds since the epoch, as stored in review.json.
function M.now()
    return os.time() * 1000
end

return M
