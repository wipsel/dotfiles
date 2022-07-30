local handlers = require("user.lsp.lsp_config")
local null_ls = require("user.lsp.null_ls")

local function setup()
	handlers.setup()
	null_ls.setup()
end

return {
	setup = setup,
}
