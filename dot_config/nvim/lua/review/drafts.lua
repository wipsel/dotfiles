-- Review state lives in the checkout's git folder (`<git dir>/review.json`),
-- per branch: it belongs to the worktree, goes when the worktree is removed,
-- and an agent or script can read it there. Per branch: { comments, included
-- (GitLab thread ids for the next agent review), viewed (paths), base (the
-- chosen base branch, or nil for automatic) }. A comment: { id, path, old_path,
-- from, to, quote, text, created, state, at } where `from`/`to` are rows ({
-- kind, number, old, text }), `quote` the rows as quoted when written, and
-- `state` "draft" | "sent" | "posted" (`at`: when it last changed state).
local M = {}

local FILE = "review.json"

local Drafts = {}
Drafts.__index = Drafts

function M.load(gitdir)
    local self = setmetatable(
        { path = gitdir .. "/" .. FILE, data = { branches = {} } },
        Drafts
    )
    local file = io.open(self.path, "r")
    if file then
        local text = file:read("*a")
        file:close()
        local ok, data = pcall(
            vim.json.decode,
            text,
            { luanil = { object = true, array = true } }
        )
        if ok and type(data) == "table" then
            self.data = data
        end
    end
    self.data.branches = self.data.branches or {}
    return self
end

--- The state of `branch` (nil: a detached HEAD), created empty when missing.
function Drafts:of(branch)
    local key = branch or "detached"
    local state = self.data.branches[key]
    if not state then
        state = {}
        self.data.branches[key] = state
    end
    state.comments = state.comments or {}
    state.included = state.included or {}
    state.viewed = state.viewed or {}
    return state
end

-- Empty tables would encode as JSON arrays, which reads back the same in Lua
-- but not elsewhere.
local function encodable(data)
    local copy = vim.deepcopy(data)
    for _, state in pairs(copy.branches) do
        if next(state.viewed or {}) == nil then
            state.viewed = vim.empty_dict()
        end
    end
    if next(copy.branches) == nil then
        copy.branches = vim.empty_dict()
    end
    return copy
end

--- Writes the file whole, through a temporary file so a reader never sees half
--- of it.
function Drafts:save()
    local text = vim.json.encode(
        encodable(self.data),
        { indent = " ", sort_keys = true }
    )
    local temporary = self.path .. ".tmp"
    local file, err = io.open(temporary, "w")
    if not file then
        vim.notify(
            "review: could not save drafts: " .. tostring(err),
            vim.log.levels.ERROR
        )
        return
    end
    file:write(text)
    file:close()
    local ok, rename_err = os.rename(temporary, self.path)
    if not ok then
        vim.notify(
            "review: could not save drafts: " .. tostring(rename_err),
            vim.log.levels.ERROR
        )
    end
end

return M
