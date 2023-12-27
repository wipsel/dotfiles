local ok, kanagawa = pcall(require, "kanagawa")
if not ok then
	vim.notify("everforest not found, make sure it is installed.")
	return
end

local function setup()
	kanagawa.setup()
	vim.cmd("colorschem kanagawa")
end

local function toggle_style() end

return {
	setup = setup,
	toggle_style = toggle_style,
}
