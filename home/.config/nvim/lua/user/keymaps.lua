local function wrap(fn, options)
    return function()
        fn(options)
    end
end

local function apply_keymaps(mode, keymaps)
    local options = { noremap = true, silent = true }

    for key, value in pairs(keymaps) do
        if type(value) == "table" then
            vim.keymap.set(mode, key, wrap(value.fn, value.opts), options)
        else
            vim.keymap.set(mode, key, value, options)
        end
    end
end

local function write_file()
    local ok, _ = pcall(vim.cmd.w)
    if not ok and vim.fn.win_gettype() == "" then
        local on_confirm = function(file_name)
            if file_name == "" then
                return
            else
                vim.cmd.w(file_name)
            end
        end

        vim.ui.input({ prompt = "Please provide file name" }, on_confirm)
    end
end

return {
    setup = function(config)
        vim.g.mapleader = config.leader
        vim.g.maplocalleader = config.leader

        apply_keymaps("i", config.insert)
        apply_keymaps("n", config.normal)
    end,
    write_file = write_file,
}
