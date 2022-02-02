local colorscheme = "onedarker"

-- protected call to find colorscheme and notify with error if the scheme 
-- is not installed.
local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
  vim.notify("colorscheme " .. colorscheme .. " not found!")
  return
end
