local ok, onedark = pcall(require, "onedark")
if not ok then
	vim.notify("onedark not found, make sure it is installed.")
	return
end

local ok, everforest = pcall(require, "everforest") 
if not ok then
	vim.notify("everforest not found, make sure it is installed.")
	return
end



local function setup()
	--onedark.setup({
		--code_style = {
			--comments = "italic",
			--keywords = "none",
			--functions = "none",
			--strings = "italic",
			--variables = "none",
		--},
                --style = "darker",
		--diagnostics = {
                        --darker = true,
			--background = true, -- use background color for virtual text
		--},
	--})
	--onedark.load()
        everforest.setup({
              background = "hard",
              transparent_background_level = 0,
              italics = false,
              disable_italic_comments = false,
        })
        everforest.load()
end

local function toggle_style()
    print("yolo")
end

return {
	setup = setup,
        toggle_style = toggle_style,
}
