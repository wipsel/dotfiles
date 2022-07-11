local keymap = vim.api.nvim_set_keymap
local options = { noremap = true, silent = true }

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local toggle_color = "<cmd>lua require('material.functions').toggle_style()<cr>"
local open_telescope_file_finder =
	"<cmd>lua require('telescope.builtin').find_files(require('telescope.themes').get_dropdown({ previewer = false })) <cr>"
local open_telescope_grep =
	"<cmd>lua require('telescope.builtin').live_grep(require('telescope.themes').get_dropdown({ previewer = false })) <cr>"
local open_telescope_git_commits =
	"<cmd>lua require('telescope.builtin').git_commits(require('telescope.themes').get_dropdown({ previewer = false })) <cr>"

keymap("", "<Space>", "<Nop>", options)
keymap("i", "jj", "<ESC>", options)
keymap("n", "<leader>h", ":bp<CR>", options)
keymap("n", "<leader>l", ":bn<CR>", options)
keymap("n", "<leader>j", ":bd<CR>", options)
keymap("n", "<CR>", ":w <CR>", options)
keymap("n", "<leader>q", ":q <CR>", options)
keymap("n", "<leader>k", toggle_color, options)
keymap("n", "<leader>p", open_telescope_file_finder, options)
keymap("n", "<leader>o", open_telescope_grep, options)
keymap("n", "<leader>i", open_telescope_git_commits, options)
