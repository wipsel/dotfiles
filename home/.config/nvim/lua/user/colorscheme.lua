local ok, kanagawa = pcall(require, "kanagawa")
if not ok then
	vim.notify("kanagawa not found, make sure it is installed.")
	return
end

local function setup()
	kanagawa.setup()
	vim.cmd("colorscheme kanagawa")
end

return {
	setup = setup,
}
