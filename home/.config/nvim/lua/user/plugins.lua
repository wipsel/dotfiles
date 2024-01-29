local ok, packer = pcall(require, "packer")
if not ok then
	vim.notify("packer not found, make sure it is installed.")
	return
end

-- Check if packer.nvim is installed
local ensure_packer = function()
	local fn = vim.fn
	local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
	if fn.empty(fn.glob(install_path)) > 0 then
		fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
		vim.cmd([[packadd packer.nvim]])
		return true
	end
	return false
end

local function plugins(use)
	use("wbthomason/packer.nvim")
	use("folke/neodev.nvim")
	use("nvim-lua/popup.nvim")
	-- Useful lua functions used by lots of plugins
	use("nvim-lua/plenary.nvim")

	-- colorschemes
	-- the real reason I became a programmer
	use("neanias/everforest-nvim")
	use("sainnhe/sonokai")
	use("navarasu/onedark.nvim")
	use("marko-cerovac/material.nvim")
	use("rebelot/kanagawa.nvim")

	-- icons for file types, errors git signs and stuff.
	use("kyazdani42/nvim-web-devicons")

	-- git stuff
	use("lewis6991/gitsigns.nvim")
	use("akinsho/git-conflict.nvim")

	use("nvim-tree/nvim-tree.lua")

	-- prettier ui for renaming and stuff.
	use("stevearc/dressing.nvim")

	-- colorize hex strings
	use("norcalli/nvim-colorizer.lua")

	-- easier commenting
	use("scrooloose/nerdcommenter")

	use("nvim-lualine/lualine.nvim")
	use("akinsho/bufferline.nvim")

	-- cmp plugins
	use("hrsh7th/nvim-cmp") -- Completion plugin
	use("hrsh7th/cmp-buffer") -- Buffer completions
	use("hrsh7th/cmp-path") -- Path completions
	use("hrsh7th/cmp-cmdline") -- Cmdline completions
	use("hrsh7th/cmp-nvim-lsp") -- LSP completions
	use("saadparwaiz1/cmp_luasnip") -- snippet completions

	-- snippets
	use("L3MON4D3/LuaSnip") --snippet engine
	use("rafamadriz/friendly-snippets") -- a bunch of snippets to use

	-- lsp setup
	use("neovim/nvim-lspconfig")
	use("jose-elias-alvarez/null-ls.nvim") -- for formatters and linters

	-- telescope
	use("nvim-telescope/telescope.nvim")

	-- treesitter
	use({
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
		tag = "v0.9.2",
	})
	use("echasnovski/mini.surround")

	-- debugging
	use("mfussenegger/nvim-dap")
	use("rcarriga/nvim-dap-ui")

	-- golang
	use("olexsmir/gopher.nvim")

	if ensure_packer() then
		print("Restart Neovim required after installation!")
		require("packer").sync()
	end
end

local function setup()
	local config = {
		profile = {
			enable = true,
			threshold = 0, -- the amount in ms that a plugins load time must be over for it to be included in the profile
		},

		display = {
			open_fn = function()
				return require("packer.util").float({ border = "rounded" })
			end,
		},
	}

	packer.init(config)
	packer.startup(plugins)
end

return {
	setup = setup,
}
