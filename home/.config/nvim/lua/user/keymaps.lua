local keymap = vim.api.nvim_set_keymap
local options = { noremap = true, silent = true }

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- predefined commands we can bind to a keymap.
local commands = {
	lsp = {
		goto_definition = "<cmd>lua vim.lsp.buf.definition()<CR>",
		hover = "<cmd>lua vim.lsp.buf.hover()<CR>",
		show_implementation = "<cmd>lua vim.lsp.buf.implementation()<CR>",
		rename = "<cmd>lua vim.lsp.buf.rename()<CR>",
		references = "<cmd>lua vim.lsp.buf.references()<CR>",
		format = "<cmd>lua vim.lsp.buf.format(nil, 2000)<CR>",
		goto_prev = '<cmd>lua vim.diagnostic.goto_prev({ border = "rounded" })<CR>',
		goto_next = '<cmd>lua vim.diagnostic.goto_next({ border = "rounded" })<CR>',
		diagnostic = '<cmd>lua vim.diagnostic.open_float(0, { scop = "line" })<CR>',
		loclist = "<cmd>lua vim.diagnostic.setloclist()<CR>",
	},
	telescope = {
		file_finder = "<cmd>lua require('telescope.builtin').find_files(require('telescope.themes').get_dropdown({ previewer = false })) <cr>",
		grep = "<cmd>lua require('telescope.builtin').live_grep(require('telescope.themes').get_dropdown({ previewer = false })) <cr>",
		git_commits = "<cmd>lua require('telescope.builtin').git_commits(require('telescope.themes').get_dropdown({ previewer = false })) <cr>",
		color_theme_picker = "<cmd>lua require('telescope.builtin').colorscheme(require('telescope.themes').get_dropdown({ previewer = false })) <cr>",
		resume = "<cmd>lua require('telescope.builtin').resume <cr>",
	},
}

local function setup_telescope_keymaps()
	keymap("n", "<leader>p", commands.telescope.file_finder, options)
	keymap("n", "<leader>o", commands.telescope.grep, options)
	keymap("n", "<leader>i", commands.telescope.git_commits, options)
	keymap("n", "<C-l>", commands.telescope.resume, options)
end

local function setup_default_keymaps()
	keymap("", "<Space>", "<Nop>", options)
	keymap("i", "jj", "<ESC>", options)
	keymap("n", "<leader>h", ":bp<CR>", options)
	keymap("n", "<leader>l", ":bn<CR>", options)
	keymap("n", "<leader>j", ":bd<CR>", options)
	keymap("n", "<CR>", ":w <CR>", options)
	keymap("n", "<leader>q", ":q <CR>", options)
	keymap("n", "<leader>k", commands.telescope.color_theme_picker, options)
end

local function setup_lsp_keymaps()
	keymap("n", "gd", commands.lsp.goto_definition, options)
	keymap("n", "<C-k>", commands.lsp.hover, options)
	keymap("n", "gi", commands.lsp.show_implementation, options)
	keymap("n", "rn", commands.lsp.rename, options)
	keymap("n", "gr", commands.lsp.references, options)
	keymap("n", "<C-f>", commands.lsp.format, options)
	keymap("n", "<c-n>", commands.lsp.goto_next, options)
	keymap("n", "<C-p>", commands.lsp.goto_prev, options)
	keymap("n", "gl", commands.lsp.diagnostic, options)
	keymap("n", "<leader>q", commands.lsp.loclist, options)
end

local function setup()
	setup_default_keymaps()
	setup_telescope_keymaps()
	setup_lsp_keymaps()
end

return {
	setup = setup,
}
