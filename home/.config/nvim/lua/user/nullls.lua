local ok, null_ls = pcall(require, "null-ls")
if not ok then
	vim.notify("null_ls not found, make sure it is installed.")
	return
end

local function setup()
	local formatting = null_ls.builtins.formatting
	local diagnostics = null_ls.builtins.diagnostics

	local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

	null_ls.setup({
		debug = false,
		sources = {
			formatting.stylua,
			formatting.prettier,
			formatting.eslint_d,
			formatting.goimports,
			formatting.gofumpt,
			formatting.isort,
			formatting.black,
			diagnostics.eslint_d,
			diagnostics.stylelint,
			diagnostics.golangci_lint.with({
				args = {
					"run",
					"--fix=false",
					"--fast",
					"--out-format=json",
				},
			}),
		},
		on_attach = function(client, bufnr)
			if client.supports_method("textDocument/formatting") then
				vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
				vim.api.nvim_create_autocmd("BufWritePre", {
					group = augroup,
					buffer = bufnr,
					callback = function()
						vim.lsp.buf.format({ async = false })
					end,
				})
			end
		end,
	})
end

return {
	setup = setup,
}
