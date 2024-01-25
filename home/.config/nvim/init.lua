require("user.options").setup()
require("neodev").setup()
require("user.keymaps").setup()
require("user.plugins").setup()
require("user.cmp").setup()
require("user.colorscheme").setup()
require("user.lualine").setup()
require("user.bufferline").setup()
require("user.lspconfig").setup()
require("user.nullls").setup()
require("user.telescope").setup()
require("user.treesitter").setup()
require("colorizer").setup()
require("dressing").setup()
require("gopher.dap").setup()
require("dapui").setup()
require("nvim-tree").setup()
require("gitsigns").setup({
	numhl = true,
	current_line_blame = true,
	current_line_blame_opts = {
		delay = 100,
	},
})
