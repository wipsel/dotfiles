local keymap = vim.api.nvim_set_keymap
local options = { noremap = true, silent = true }

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local open_telescope_cmd =
	"<cmd>lua require'telescope.builtin'.find_files(require('telescope.themes').get_dropdown({ previewer = false}))<cr>"

keymap("", "<Space>", "<Nop>", options)
keymap("i", "jj", "<ESC>", options)
keymap("n", "<leader>h", ":bp<CR>", options)
keymap("n", "<leader>l", ":bn<CR>", options)
keymap("n", "<leader>j", ":bd<CR>", options)
keymap("n", "<CR>", ":w <CR>", options)
keymap("n", "<leader>q", ":q <CR>", options)
keymap("n", "<leader>p", open_telescope_cmd, options)
keymap("n", "<leader>o", "<cmd>Telescope live_grep<cr>", options)
