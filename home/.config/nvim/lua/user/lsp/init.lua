local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
	vim.notify("lspconfig not found, make sure it is installed.")
	return
end

require("user.lsp.installer")
require("user.lsp.handlers").setup()
require("user.lsp.null-ls")
