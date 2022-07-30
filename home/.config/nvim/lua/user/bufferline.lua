local ok, bufferline = pcall(require, "bufferline")
if not ok then
	vim.notify("bufferline not found, make sure it is installed.")
	return
end

-- formats the indicator for diagnostics on the buffer.
local indicator = function(count, level)
	-- TODO info icon
	local icon = level:match("error") and " " or " "
	return " " .. icon .. count
end

local function setup()
	bufferline.setup({
		options = {
			close_icon = "",
			buffer_close_icon = "",
			diagnostics = "nvim_lsp",
			diagnostics_indicator = indicator,
		},
	})
end

return {
	setup = setup,
}
