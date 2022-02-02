local opts = { noremap = true, silent = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "


-- exit insert mode on jj
keymap("i", "jj", "<ESC>", opts)


-- buffer moving
keymap("n", "<leader>h", ":bp<CR>", opts)
keymap("n", "<leader>l", ":bn<CR>", opts)
keymap("n", "<leader>j", ":bd<CR>", opts)

-- write file on enter
keymap("n", "<CR>", ":w <CR>", opts)
keymap("n", "<leader>q", ":q <CR>", opts)


-- TODO paste from clipboard


-- open telescope finder
keymap(
    "n",
    "<leader>p",
    "<cmd>lua require'telescope.builtin'.find_files(require('telescope.themes').get_dropdown({ previewer = false }))<cr>",
    opts
)
-- open live grep finder
keymap("n", "<leader>o", "<cmd>Telescope live_grep<cr>", opts)
