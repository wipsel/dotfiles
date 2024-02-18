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

local function focus_file_tree()
	return file_tree.tree.focus()
end

local function lsp_format()
	vim.lsp.buf.format({ timeout_ms = 2000 })
end

local function wrap(fn, options)
	return function()
		fn(options)
	end
end

local function write_file()
	local ok, _ = pcall(vim.cmd.w)
	if not ok then
		vim.ui.input({ prompt = "Please provide file name" }, vim.cmd.w)
	end
end

local NORMAL_MODE_KEYMAPS = {
	["<leader>h"] = vim.cmd.bp,
	["<leader>j"] = vim.cmd.bd,
	["<leader>l"] = vim.cmd.bn,
	-- is this the way to do a no op?
	["<Space>"] = function() end,
	["<CR>"] = write_file,
	["<leader>k"] = { fn = builtin.colorscheme, opts = themes.get_dropdown({ previewer = false }) },
	["<leader>p"] = open_file_finder,
	["<leader>o"] = open_grep_finder,
	["<leader>i"] = open_git_commits,
	["<leader>u"] = open_lsp_implementations,
	["<leader>t"] = open_file_tree,
	["<leader>r"] = focus_file_tree,
	["gd"] = vim.lsp.buf.definition,
	["<C-k>"] = vim.lsp.buf.hover,
	["gi"] = vim.lsp.buf.implementation,
	["rn"] = vim.lsp.buf.rename,
	["gr"] = vim.lsp.buf.references,
	["<C-f>"] = lsp_format,
	["<c-n>"] = { fn = vim.diagnostic.goto_next, opts = { border = "rounded" } },
	["<C-p>"] = diagnostic_goto_prev,
	["gl"] = diagnostic_open_float,
	["<leader>q"] = diagnostic_set_loc_list,
}

local function setup_keymapping()
	local options = { noremap = true, silent = true }

	vim.g.mapleader = " "
	vim.g.maplocalleader = " "

	vim.keymap.set("i", "jj", "<ESC>", options)

	for key, value in pairs(NORMAL_MODE_KEYMAPS) do
		if type(value) == "table" then
			vim.keymap.set("n", key, wrap(value.fn, value.opts), options)
		else
			vim.keymap.set("n", key, value, options)
		end
	end
end

return {
	setup = setup_keymapping,
}
