local cmp_nvim_lsp = require("cmp_nvim_lsp")
local lspconfig = require("lspconfig")
local util = require("lspconfig/util")

local capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())

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
	client.server_capabilities.documentFormattingProvider = false
	client.server_capabilities.documentRangeFormattingProvider = false

	highlight_document(bufnr)
end

local lsps = {
	{
		server = lspconfig.gopls,
		config = {
			capabilities = capabilities,
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
			capabilities = capabilities,
			on_attach = on_attach,
		},
	},

	{
		server = lspconfig.tsserver,
		config = {
			capabilities = capabilities,
			on_attach = on_attach,
		},
	},

	{
		server = lspconfig.pyright,
		config = {
			capabilities = capabilities,
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
		vim.diagnostic.config(diagnostic)

		vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, float)
		vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, float)

		for _, sign in ipairs(signs) do
			vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
		end

		for _, lsp in pairs(lsps) do
			lsp.server.setup(lsp.config)
		end
	end,
}
