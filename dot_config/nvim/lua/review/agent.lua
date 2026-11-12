-- The coding agent this Neovim sends to, through herdr-core (`hc`): the
-- terminal named by $REVIEW_AGENT, else the agent in the same herdr tab as this
-- Neovim's own terminal.
local util = require("review.util")

local M = {}

local function decode(text)
    local ok, data = pcall(
        vim.json.decode,
        text,
        { luanil = { object = true, array = true } }
    )
    return ok and data or nil
end

--- The agent's address, or nil and why there is none. A coroutine step.
function M.address()
    if vim.fn.executable("hc") == 0 then
        return nil, "No agent: hc (herdr-core) is not installed here"
    end
    local named = vim.env.REVIEW_AGENT
    if named and named ~= "" then
        return named
    end
    local own = vim.env.HC_TERMINAL_ID
    if not own or own == "" then
        return nil,
            "No agent: $REVIEW_AGENT is unset and this Neovim isn't in a herdr terminal"
    end
    local result = util.run_async({ "hc", "get", own, "--json" })
    if result.code ~= 0 then
        return nil, "No agent: " .. util.failure(result, "hc get failed")
    end
    local me = decode(result.stdout) or {}
    local tab = (me.labels or {})["herdr.tab"]
    if not tab then
        return nil, "No agent: this terminal isn't in a herdr tab"
    end
    result =
        util.run_async({ "hc", "ls", "--json", "--label", "herdr.tab=" .. tab })
    if result.code ~= 0 then
        return nil, "No agent: " .. util.failure(result, "hc ls failed")
    end
    local listed = decode(result.stdout) or {}
    for _, terminal in ipairs(listed.terminals or {}) do
        if terminal.address ~= own and terminal.status then
            return terminal.address
        end
    end
    return nil, "No agent in this herdr tab"
end

--- Pastes `text` into the agent and submits it. Returns the address, or nil and
--- an error.
function M.send(text)
    local address, why = M.address()
    if not address then
        return nil, why
    end
    local result = util.run_async(
        { "hc", "send", address, text },
        { timeout = 120000 }
    )
    if result.code ~= 0 then
        return nil, util.failure(result, "hc send failed")
    end
    return address
end

return M
