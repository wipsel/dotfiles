local ok, telescope = pcall(require, "telescope")
if not ok then
	vim.notify("telescope not found, make sure it is installed.")
	return
end

local function setup()
	telescope.setup({
		defaults = {
			find_cmd = "rg",
			prompt_prefix = " ",
			selection_caret = " ",
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
	})
end

return {
	setup = setup,
}
