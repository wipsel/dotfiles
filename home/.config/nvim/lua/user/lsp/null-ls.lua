local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
  return
end

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics

null_ls.setup {
    debug = false,
    sources = {
        formatting.stylua,
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
}
