local Installer = {}

function Installer.setup(servers, options)
	local lspconfig = require("lspconfig")

	-- nvim-lsp-installer must be set up before nvim-lspconfig
	require("nvim-lsp-installer").setup({
		ensure_installed = vim.tbl_keys(servers),
		automatic_installation = false,
	})

	for server_name, _ in pairs(servers) do
		local opts = vim.tbl_deep_extend("force", options, servers[server_name] or {})

		-- TODO see if you need special setup for servers
                print(server_name)
		lspconfig[server_name].setup(opts)
	end
end

return Installer
