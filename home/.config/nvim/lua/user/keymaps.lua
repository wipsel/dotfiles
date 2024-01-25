local telescope = require("user.telescope")
local diagnostic = require("user.diagnostic")
diagnostic.print("yolo")

local function lsp_format()
	vim.lsp.buf.format({ timeout_ms = 2000 })
end

local function diagnostic_goto_next()
	vim.diagnostic.goto_next({ border = "rounded" })
end

local function diagnostic_goto_prev()
	vim.diagnostic.goto_prev({ border = "rounded" })
end

local function diagnostic_open()
	vim.diagnostic.open_float()
end

local NORMAL_MODE_KEYMAPS = {
	["<leader>h"] = ":bp<CR>",
	["<leader>j"] = ":bd<CR>",
	["<leader>l"] = ":bn<CR>",
	["<Space>"] = "<Nop>",
	["<CR>"] = ":w <CR>",
	["<leader>k"] = telescope.open_color_picker,
	["<leader>p"] = telescope.open_file_finder,
	["<leader>o"] = telescope.open_grep_finder,
	["<leader>i"] = telescope.open_git_commits,
	["gd"] = vim.lsp.buf.definition,
	["<C-k>"] = vim.lsp.buf.hover,
	["gi"] = vim.lsp.buf.implementation,
	["rn"] = vim.lsp.buf.rename,
	["gr"] = vim.lsp.buf.references,
	["<C-f>"] = lsp_format,
	["<c-n>"] = diagnostic_goto_next,
	["<C-p>"] = diagnostic_goto_prev,
	["gl"] = diagnostic_open,
	["<leader>q"] = vim.diagnostic.setloclist,
}

local function setup_keymapping()
	local keymap = vim.api.nvim_set_keymap
	local options = { noremap = true, silent = true }
	vim.g.mapleader = " "
	vim.g.maplocalleader = " "

	keymap("i", "jj", "<ESC>", options)

	for key, value in pairs(NORMAL_MODE_KEYMAPS) do
		vim.keymap.set("n", key, value, options)
	end
end

return {
	setup = setup_keymapping,
}
