-- A real file opened from a review buffer gets gitsigns' marks against the
-- review's base, for that buffer only; `restore` puts every such buffer back on
-- gitsigns' own base.
local M = {}

-- buffer → true for buffers whose gitsigns base this module changed.
local changed = {}

local function gitsigns()
    local ok, module = pcall(require, "gitsigns")
    return ok and module or nil
end

local function attached(buf)
    return vim.b[buf].gitsigns_status_dict ~= nil
end

local function change_base(buf, base, tries)
    local module = gitsigns()
    if not module or not vim.api.nvim_buf_is_valid(buf) then
        return
    end
    if not attached(buf) then
        -- gitsigns attaches a moment after the buffer is read.
        if tries < 20 then
            vim.defer_fn(function()
                change_base(buf, base, tries + 1)
            end, 100)
        end
        return
    end
    vim.api.nvim_buf_call(buf, function()
        module.change_base(base, false)
    end)
end

--- Shows the changes of the review's scope in `buf`, when the scope compares
--- against the working tree (a commit's changes aren't in the file as it is
--- now).
function M.follow(buf)
    local current = require("review.session").current
    if not current or not gitsigns() then
        return
    end
    local from, to =
        require("review.git").endpoints(current.repo, current.scope)
    if to or from == require("review.git").EMPTY_TREE then
        return
    end
    changed[buf] = true
    change_base(buf, from, 0)
end

function M.restore()
    local module = gitsigns()
    for buf in pairs(changed) do
        if module and vim.api.nvim_buf_is_valid(buf) and attached(buf) then
            vim.api.nvim_buf_call(buf, function()
                module.change_base(nil, false)
            end)
        end
    end
    changed = {}
end

return M
