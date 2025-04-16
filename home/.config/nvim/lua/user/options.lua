local function setup()
    vim.cmd.colorscheme("kanagawa")

    vim.opt.foldmethod = "expr"
    vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
    vim.opt.list = true

    vim.g.python3_host_prog = "$HOME" .. "/.pyenv/versions/nvim/bin/python3"

    vim.opt.undofile = true
    vim.opt.backup = false
    vim.opt.swapfile = false

    vim.opt.cursorline = true
    vim.opt.number = true
    vim.opt.hidden = true
    vim.opt.colorcolumn = "80"

    vim.opt.fileencoding = "utf-8"

    vim.opt.hlsearch = true
    vim.opt.scrolloff = 8
    vim.opt.updatetime = 300
    vim.opt.smartindent = true
    vim.opt.background = "dark"

    vim.opt.expandtab = true
    vim.opt.shiftwidth = 4
    vim.opt.tabstop = 8
    vim.opt.expandtab = true
    vim.opt.softtabstop = 8
    vim.opt.numberwidth = 4

    vim.opt.wrap = false
    vim.opt.termguicolors = true

    vim.opt.foldlevel = 99
end

return {
    setup = setup,
}
