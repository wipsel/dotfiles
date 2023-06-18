local ok, null_ls = pcall(require, "null-ls")
if not ok then
	vim.notify("null_ls not found, make sure it is installed.")
	return
end


local function setup()
        local formatting = null_ls.builtins.formatting
        local diagnostics = null_ls.builtins.diagnostics

	null_ls.setup({
		debug = false,
		sources = {
			formatting.stylua,
			formatting.prettier,
			formatting.eslint,
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
					"$DIRNAME",
					"--path-prefix",
					"$ROOT",
				},
			}),
		},
	})
end

return {
	setup = setup,
}
