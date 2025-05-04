local function wrap(fn, options)
    return function()
        fn(options)
    end
end

local function apply_keymaps(mode, keymaps)
    local options = { noremap = true, silent = true }

    for key, value in pairs(keymaps) do
        if type(value) == "table" then
            if value.desc then
                options = { noremap = true, silent = true, desc = value.desc }
            else
                options = { noremap = true, silent = true }
            end

            if value.opts then
                vim.keymap.set(mode, key, wrap(value.fn, value.opts), options)
            else
                vim.keymap.set(mode, key, value.fn, options)
            end
        else
            vim.keymap.set(mode, key, value, options)
        end
    end
end

local function write_file()
    local prompt = "Please provide a file name"
    local buf = vim.api.nvim_get_current_buf()

    local ok, _ = pcall(vim.cmd.w)
    if not ok and vim.api.nvim_buf_get_name(buf) == "" then
        if not vim.bo.modifiable then
            vim.notify("Buffer is not modifiable.", vim.log.levels.ERROR)
            return
        end

        if vim.bo.readonly then
            vim.notify("Buffer is readonly.", vim.log.levels.ERROR)
            return
        end

        local on_confirm = function(file_name)
            if file_name == "" or file_name == nil then
                vim.notify("No file name", vim.log.levels.WARN)
                return
            else
                vim.cmd.w(file_name)
            end
        end

        vim.ui.input({ prompt = prompt }, on_confirm)
    end
end

return {
    setup = function(config)
        apply_keymaps("i", config.insert)
        apply_keymaps("n", config.normal)
        apply_keymaps("v", config.visual)
    end,

    write_file = write_file,
}
