local modules = {
	{
		name = "user.plugins",
	},
	{
		name = "user.lsp",
	},
	{
		name = "user.completion",
	},
	{
		name = "user.options",
	},
	{
		name = "user.keymaps",
	},
	{
		name = "telescope",
		config = {
			defaults = {
				find_cmd = "rg",
				prompt_prefix = "  ",
				selection_caret = "  ",
				selection_strategy = "reset",
				sorting_strategy = "ascending",
				layout_strategy = "vertical",
				layout_config = {
					vertical = {
						mirror = true,
					},
				},
				winblend = 20,
				use_less = false,
				set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
			},
		},
	},
	{
		name = "nvim-tree",
	},
	{
		name = "neodev",
	},
	{
		name = "nvim-treesitter.configs",
		config = {
			ensure_installed = "all",
			highlight = {
				enable = true,
			},
			indent = {
				enable = false,
			},
		},
	},
	{
		name = "gitsigns",
		config = {
			numhl = true,
			current_line_blame = true,
			current_line_blame_opts = {
				delay = 100,
			},
		},
	},
	{
		name = "bufferline",
		config = {
			options = {
				close_icon = "",
				buffer_close_icon = "",
				diagnostics = "nvim_lsp",
				diagnostics_indicator = function(count, level)
					local icon = level:match("error") and " " or " "
					return " " .. icon .. count
				end,
			},
		},
	},
	{
		name = "lualine",
		config = {
			options = {
				icons_enabled = true,
				theme = "auto",
				component_separators = { left = "|", right = "|" },
				section_separators = { left = "", right = "" },
				disabled_filetypes = {},
				always_divide_middle = true,
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = { "filename" },
				lualine_x = { "encoding", "fileformat", "filetype" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { "filename" },
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
			tabline = {},
			extensions = {},
		},
	},
}

for _, module in pairs(modules) do
	local ok, loaded = pcall(require, module.name)
	if not ok then
		vim.notify(string.format("module: %s not found, make sure it is installed.", module.name), vim.log.levels.WARN)

		return
	end

	loaded.setup(module.config)
end
