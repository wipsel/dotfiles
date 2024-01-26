local lspconfig = require("lspconfig")
local util = require("lspconfig/util")
local cmp = require("user.completion")
local null_ls = require("null-ls")

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics

local function highlight_document(bufnr)
	vim.api.nvim_create_augroup("lsp_document_highlight", { clear = true })
	vim.api.nvim_create_autocmd("CursorHold", {
		callback = function()
			vim.lsp.buf.document_highlight()
		end,
		buffer = bufnr,
	})

	vim.api.nvim_create_autocmd("CursorMoved", {
		callback = function()
			vim.lsp.buf.clear_references()
		end,
		buffer = bufnr,
	})
end

local function on_attach(client, bufnr)
	-- disable document formatting because null-ls takes care of this.
	if client.supports_method("textDocument/formatting") then
		local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
		vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = augroup,
			buffer = bufnr,
			callback = function()
				vim.lsp.buf.format({ async = false })
			end,
		})
	end

	highlight_document(bufnr)
end

local sources = {
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
}

local lsps = {
	{
		server = lspconfig.gopls,
		config = {
			capabilities = cmp.capabilities,
			filetypes = { "go", "gomod", "gowork", "gotmpl" },
			root_dir = util.root_pattern("go.work", "go.mod", ".git"),
			settings = {
				gopls = {
					completeUnimported = true,
					usePlaceholders = true,
					analyses = {
						unusedparams = true,
					},
				},
			},
			on_attach = on_attach,
		},
	},
	{
		server = lspconfig.lua_ls,
		config = {
			capabilities = cmp.capabilities,
			on_attach = on_attach,
		},
	},

	{
		server = lspconfig.tsserver,
		config = {
			capabilities = cmp.capabilities,
			on_attach = on_attach,
		},
	},

	{
		server = lspconfig.pyright,
		config = {
			capabilities = cmp.capabilities,
			on_attach = on_attach,
		},
	},
}

local signs = {
	{ name = "DiagnosticSignError", text = "" },
	{ name = "DiagnosticSignWarn", text = "" },
	{ name = "DiagnosticSignHint", text = "" },
	{ name = "DiagnosticSignInfo", text = "" },
}

local diagnostic = {
	virtual_text = false,
	signs = {
		active = signs,
	},
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		focusable = true,
		style = "minimal",
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
	},
}

local float = {
	focusable = true,
	style = "minimal",
	border = "rounded",
	width = 200,
}

return {
	setup = function()
		vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, float)
		vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, float)

		for _, lsp in pairs(lsps) do
			lsp.server.setup(lsp.config)
		end

		for _, sign in ipairs(signs) do
			vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
		end

		vim.api.nvim_set_option_value("winhighlight", "NormalFloat:Normal,FloatBorder:TelescopeBorder", {})
		vim.diagnostic.config(diagnostic)

		cmp.setup()
		null_ls.setup({
			debug = false,
			sources = sources,
			on_attach = on_attach,
		})
	end,
}
