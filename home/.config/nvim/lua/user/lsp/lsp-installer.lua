local ok, lsp_installer = pcall(require, "nvim-lsp-installer")
if not ok then
	vim.notify("nvim-lsp-installer not found, make sure it is installed.")
	return
end

-- Register a handler that will be called for all installed servers.
lsp_installer.on_server_ready(function(server)
	local options = {
		on_attach = require("user.lsp.handlers").on_attach,
		capabilities = require("user.lsp.handlers").capabilities,
	}

	if server.name == "sumneko_lua" then
		local sumneko_opts = require("user.lsp.settings.sumneko_lua")
		options = vim.tbl_deep_extend("force", sumneko_opts, options)
	end

	server:setup(options)
end)
