local ok, treesitter = pcall(require, "nvim-treesitter.configs")
if not ok then
	vim.notify("treesitter not found, make sure it is installed.")
	return
end

treesitter.setup({
	ensure_installed = "all",
	highlight = {
		enable = true,
	},
	indent = {
		enable = false,
	},
})
