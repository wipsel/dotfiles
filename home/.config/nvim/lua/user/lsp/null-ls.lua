local ok, null_ls = pcall(require, "null-ls")
if not ok then
	vim.notify("null_ls not found, make sure it is installed.")
	return
end

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics

null_ls.setup({
	debug = false,
	sources = {
		formatting.stylua,
		formatting.prettier,
		formatting.goimports,
		diagnostics.golangci_lint.with({
			args = {
				"run",
				"--disable-all",
				"--enable=misspell",
				"--enable=godox",
				"--enable=revive",
				"--enable=govet",
				"--exclude-use-default=false",
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
