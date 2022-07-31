local ok, onedark = pcall(require, "onedark")
if not ok then
	vim.notify("onedark not found, make sure it is installed.")
	return
end

local function setup()
	onedark.setup({
		code_style = {
			comments = "italic",
			keywords = "none",
			functions = "none",
			strings = "none",
			variables = "none",
		},
		diagnostics = {
			background = false, -- use background color for virtual text
		},
	})
	onedark.load()
end

return {
	setup = setup,
}
