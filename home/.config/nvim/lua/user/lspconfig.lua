local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not ok then
	vim.notify("cmp_nvim_lsp not found, make sure it is installed.")
	return
end

local ok, lspconfig = pcall(require, "lspconfig")
if not ok then
	vim.notify("nvim-lsp-config not found, make sure it is installed.")
	return
end

local capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())

local config = {
	float = {
		focusable = true,
		style = "minimal",
		border = "rounded",
                width = 200,
	},

	diagnostic = {
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
	},
}

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

local function format_on_save(bufnr)
	vim.api.nvim_create_augroup("auto_format", { clear = true })
	vim.api.nvim_create_autocmd("BufWritePre", {
		callback = function()
			vim.lsp.buf.format(nil, 2000)
		end,
		buffer = bufnr,
	})
end


local function setup_gopls()
	lspconfig.gopls.setup({
		capabilities = capabilities,
		on_attach = function(client, bufnr)
			-- disable document formatting because null-ls takes care of this.
			client.server_capabilities.documentFormattingProvider = false
			client.server_capabilities.documentRangeFormattingProvider = false

                        -- Gofumpt is fast enough so we can format on save.
			format_on_save(bufnr)
			highlight_document(bufnr)
		end,
	})
end

local function setup_pyright() 
    lspconfig.pyright.setup({
		capabilities = capabilities,
		on_attach = function(client, bufnr)
			client.server_capabilities.documentFormattingProvider = false
			client.server_capabilities.documentRangeFormattingProvider = false

			format_on_save(bufnr)
			highlight_document(bufnr)
		end,
    })
end


local function setup_tsserver()
	lspconfig.tsserver.setup({
		capabilities = capabilities,
		on_attach = function(client, bufnr)
			-- disable document formatting because null-ls takes care of this.
			client.server_capabilities.documentFormattingProvider = false
			client.server_capabilities.documentRangeFormattingProvider = false

			highlight_document(bufnr)
		end,
	})
end

local function setup_signs() 
	local signs = {
		{ name = "DiagnosticSignError", text = "" },
		{ name = "DiagnosticSignWarn", text = "" },
		{ name = "DiagnosticSignHint", text = "" },
		{ name = "DiagnosticSignInfo", text = "" },
	}

	for _, sign in ipairs(signs) do
		vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
	end
end

local function setup()
	vim.diagnostic.config(config.diagnostic)
	vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, config.float)
	vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, config.float)

        setup_signs()
	setup_gopls()
        setup_pyright()
	setup_tsserver()
end

return {
	setup = setup,
}
