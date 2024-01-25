local telescope = require("telescope")
local builtin = require("telescope.builtin")
local themes = require("telescope.themes")

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

local function setup()
	telescope.setup({
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
	})
end

return {
	setup = setup,
	open_file_finder = open_file_finder,
	open_grep_finder = open_grep_finder,
	open_git_commits = open_git_commits,
	open_color_picker = open_color_picker,
}
