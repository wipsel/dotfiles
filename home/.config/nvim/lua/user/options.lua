local function setup()
	vim.opt.backup = false
	vim.opt.cursorline = true
	vim.opt.number = true
	vim.opt.hidden = true
	vim.opt.colorcolumn = "80"
	vim.opt.fileencoding = "utf-8"
	vim.opt.swapfile = false
	vim.opt.expandtab = true
	vim.opt.hlsearch = true
	vim.opt.scrolloff = 8
	vim.opt.updatetime = 300
	vim.opt.smartindent = true
	vim.opt.background = "dark"
	vim.opt.shiftwidth = 4
	vim.opt.tabstop = 8
	vim.opt.expandtab = true
	vim.opt.list = true
	vim.opt.listchars = "tab:>-"
	vim.opt.softtabstop = 8
	vim.opt.numberwidth = 4
	vim.opt.wrap = false
	vim.opt.termguicolors = true
	vim.opt.foldlevel = 99
end

return {
	setup = setup,
}
