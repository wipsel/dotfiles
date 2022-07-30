local ok, packer = pcall(require, "packer")
if not ok then
	vim.notify("packer not found, make sure it is installed.")
	return
end

-- Indicate first time installation
local packer_bootstrap = false

-- packer.nvim configuration
local conf = {
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

-- Check if packer.nvim is installed
-- Run PackerCompile if there are changes in this file
local function packer_init()
	local fn = vim.fn
	local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
	if fn.empty(fn.glob(install_path)) > 0 then
		packer_bootstrap = fn.system({
			"git",
			"clone",
			"--depth",
			"1",
			"https://github.com/wbthomason/packer.nvim",
			install_path,
		})
		vim.cmd([[packadd packer.nvim]])
	end
	vim.cmd("autocmd BufWritePost plugins.lua source <afile> | PackerCompile")
end

local function plugins(use)
	use("wbthomason/packer.nvim") -- Have packer manage itself
	use("nvim-lua/popup.nvim") -- An implementation of the Popup API from vim in Neovim
	use("nvim-lua/plenary.nvim") -- Useful lua functions used by lots of plugins

	-- color scheme
	use("lunarvim/onedarker.nvim")
	use("marko-cerovac/material.nvim")
	use({
		"sainnhe/everforest",
		config = function()
			vim.cmd("colorscheme everforest")
		end,
	})

	-- easier commenting
	use("scrooloose/nerdcommenter")
	use("nvim-lualine/lualine.nvim")
	use("akinsho/bufferline.nvim")

	-- cmp plugins
	use("hrsh7th/nvim-cmp") -- Completion plugin
	use("hrsh7th/cmp-buffer") -- Buffer completions
	use("hrsh7th/cmp-path") -- Path completions
	use("hrsh7th/cmp-cmdline") -- Cmdline completions
	use("hrsh7th/cmp-nvim-lsp") -- Cmdline completions
	use("saadparwaiz1/cmp_luasnip") -- snippet completions

	-- snippets
	use("L3MON4D3/LuaSnip") --snippet engine
	use("rafamadriz/friendly-snippets") -- a bunch of snippets to use

	-- lsp setup
	use("neovim/nvim-lspconfig")
	use("jose-elias-alvarez/null-ls.nvim") -- for formatters and linters

	-- telescope
	use("nvim-telescope/telescope.nvim")
	-- icons for file types, errors git signs and stuff.
	use("kyazdani42/nvim-web-devicons")

	-- treesitter
	use({
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
	})

	if packer_bootstrap then
		print("Restart Neovim required after installation!")
		require("packer").sync()
	end
end

local function setup()
	packer_init()

	packer.init(conf)
	packer.startup(plugins)
end

return {
	setup = setup,
}
