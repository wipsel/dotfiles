-- Highlight groups, derived from the colour scheme's diff colours so any theme
-- applies. Only the backgrounds are taken for line highlights, so the language
-- colouring stays readable on them.
local M = {}

local function color(name, key)
    local ok, group =
        pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
    return ok and group[key] or nil
end

local function first_color(names, key)
    for _, name in ipairs(names) do
        local value = color(name, key)
        if value then
            return value
        end
    end
end

local function blend(under, over, amount)
    if not under or not over then
        return under or over
    end
    local function channel(value, shift)
        return math.floor(value / 2 ^ shift) % 256
    end
    local out = 0
    for _, shift in ipairs({ 16, 8, 0 }) do
        local mixed = channel(under, shift) * (1 - amount)
            + channel(over, shift) * amount
        out = out + math.floor(mixed + 0.5) * 2 ^ shift
    end
    return out
end

function M.apply()
    local add_bg = color("DiffAdd", "bg")
    local delete_bg = color("DiffDelete", "bg")
    local add_fg =
        first_color({ "diffAdded", "GitSignsAdd", "Added", "DiffAdd" }, "fg")
    local delete_fg = first_color(
        { "diffRemoved", "GitSignsDelete", "Removed", "DiffDelete" },
        "fg"
    )
    local set = vim.api.nvim_set_hl
    set(0, "ReviewAdd", { bg = add_bg, default = true })
    set(0, "ReviewDelete", { bg = delete_bg, default = true })
    set(0, "ReviewAddText", { bg = blend(add_bg, add_fg, 0.3), default = true })
    set(
        0,
        "ReviewDeleteText",
        { bg = blend(delete_bg, delete_fg, 0.3), default = true }
    )
    set(0, "ReviewSignAdd", { fg = add_fg, default = true })
    set(0, "ReviewSignDelete", { fg = delete_fg, default = true })
    set(0, "ReviewDraft", { link = "DiagnosticInfo", default = true })
    set(0, "ReviewDraftText", { link = "Normal", default = true })
    set(0, "ReviewSent", { link = "Comment", default = true })
    set(0, "ReviewThread", { link = "DiagnosticHint", default = true })
    set(0, "ReviewThreadText", { link = "Normal", default = true })
    set(0, "ReviewResolved", { link = "Comment", default = true })
    set(0, "ReviewTag", { link = "DiagnosticWarn", default = true })
    set(0, "ReviewIncluded", { link = "DiagnosticOk", default = true })
    set(0, "ReviewFold", { link = "Folded", default = true })
    set(0, "ReviewWinbar", { link = "WinBar", default = true })
    set(0, "ReviewWinbarDim", { link = "Comment", default = true })
end

local applied = false

function M.setup()
    if applied then
        return
    end
    applied = true
    M.apply()
    vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup(
            "review.highlight",
            { clear = true }
        ),
        callback = function()
            -- `default` groups keep their old values otherwise.
            for _, name in ipairs({
                "ReviewAdd",
                "ReviewDelete",
                "ReviewAddText",
                "ReviewDeleteText",
                "ReviewSignAdd",
                "ReviewSignDelete",
            }) do
                vim.api.nvim_set_hl(0, name, {})
            end
            M.apply()
        end,
    })
end

return M
