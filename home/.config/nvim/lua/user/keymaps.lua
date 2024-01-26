local builtin = require("telescope.builtin")
local themes = require("telescope.themes")
local file_tree = require("nvim-tree.api")

local function diagnostic_goto_next()
	vim.diagnostic.goto_next({ border = "rounded" })
end

local function diagnostic_goto_prev()
	vim.diagnostic.goto_prev({ border = "rounded" })
end

local function diagnostic_open_float()
	vim.diagnostic.open_float()
end

local function diagnostic_set_loc_list()
	vim.diagnostic.setloclist()
end

local function open_file_finder()
	return builtin.find_files(themes.get_dropdown({ previewer = false }))
end

local function open_grep_finder()
	return builtin.live_grep(themes.get_dropdown({ previewer = false }))
end

local function open_git_commits()
	return builtin.git_commits(themes.get_dropdown({ previewer = false }))
end

local function open_color_picker()
	return builtin.colorscheme(themes.get_dropdown({ previewer = false }))
end

local function open_lsp_implementations()
	return builtin.lsp_implementations(themes.get_cursor({ winblend = 0 }))
end

local function open_file_tree()
	return file_tree.tree.toggle()
end

local function lsp_format()
	vim.lsp.buf.format({ timeout_ms = 2000 })
end

local NORMAL_MODE_KEYMAPS = {
	["<leader>h"] = ":bp<CR>",
	["<leader>j"] = ":bd<CR>",
	["<leader>l"] = ":bn<CR>",
	["<Space>"] = "<Nop>",
	["<CR>"] = ":w <CR>",
	["<leader>k"] = open_color_picker,
	["<leader>p"] = open_file_finder,
	["<leader>o"] = open_grep_finder,
	["<leader>i"] = open_git_commits,
	["<leader>u"] = open_lsp_implementations,
	["<leader>t"] = open_file_tree,
	["gd"] = vim.lsp.buf.definition,
	["<C-k>"] = vim.lsp.buf.hover,
	["gi"] = vim.lsp.buf.implementation,
	["rn"] = vim.lsp.buf.rename,
	["gr"] = vim.lsp.buf.references,
	["<C-f>"] = lsp_format,
	["<c-n>"] = diagnostic_goto_next,
	["<C-p>"] = diagnostic_goto_prev,
	["gl"] = diagnostic_open_float,
	["<leader>q"] = diagnostic_set_loc_list,
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
