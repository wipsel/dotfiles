local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not ok then
	vim.notify("cmp_nvim_lsp not found, make sure it is installed.")
	return
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

-- highlight identifiers.
local function highlight_document(client)
	if client.resolved_capabilities.document_highlight then
		vim.api.nvim_exec(
			[[
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]],
			false
		)
	end
end

-- format on save
local function format_on_save()
	vim.api.nvim_exec(
		[[
      augroup AutoFormat
        autocmd! * <buffer>
        autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()
      augroup END
    ]],
		false
	)
end

-- lsp keymap commands
local cmd = {
	goto_definition = "<cmd>lua vim.lsp.buf.definition()<CR>",
	hover = "<cmd>lua vim.lsp.buf.hover()<CR>",
	show_implementation = "<cmd>lua vim.lsp.buf.implementation()<CR>",
	rename = "<cmd>lua vim.lsp.buf.rename()<CR>",
	references = "<cmd>lua vim.lsp.buf.references()<CR>",
	format = "<cmd>lua vim.lsp.buf.formatting_sync()<CR>",
	goto_prev = '<cmd>lua vim.diagnostic.goto_prev({ border = "rounded" })<CR>',
	goto_next = '<cmd>lua vim.diagnostic.goto_next({ border = "rounded" })<CR>',
	diagnostic = '<cmd>lua vim.diagnostic.open_float(0, { scop = "line" })<CR>',
	loclist = "<cmd>lua vim.diagnostic.setloclist()<CR>",
}

-- setup lsp keymaps
local function keymaps(bufnr)
	local options = { noremap = true, silent = true }

	vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", cmd.goto_definition, options)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-k>", cmd.hover, options)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", cmd.show_implementation, options)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "rn", cmd.rename, options)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", cmd.references, options)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-f>", cmd.format, options)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<c-n>", cmd.goto_next, options)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-p>", cmd.goto_prev, options)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "gl", cmd.diagnostic, options)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>q", cmd.loclist, options)
end

local function setup()
	local signs = {
		{ name = "DiagnosticSignError", text = "" },
		{ name = "DiagnosticSignWarn", text = "" },
		{ name = "DiagnosticSignHint", text = "" },
		{ name = "DiagnosticSignInfo", text = "" },
	}

	for _, sign in ipairs(signs) do
		vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
	end

	-- config for diagnostic
	local config = {
		virtual_text = false,
		signs = { active = signs },
		update_in_insert = true,
		underline = true,
		severity_sort = true,
		float = {
			focusable = false,
			style = "minimal",
			border = "rounded",
			source = "always",
			header = "",
			prefix = "",
		},
	}

	vim.diagnostic.config(config)

	vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
	vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
		vim.lsp.handlers.signature_help,
		{ border = "rounded" }
	)
end

local function on_attach(client, bufnr)
	if client.name == "tsserver" then
		client.resolved_capabilities.document_formatting = false
	end

	-- explicitly disable formatting for gopls since we let null-ls handle the formatting.
	if client.name == "gopls" then
		client.resolved_capabilities.document_formatting = false
		client.resolved_capabilities.document_range_formatting = false
	end

	-- explicitly disable formatting for sumneko_lua since we let null-ls handle the formatting.
	if client.name == "sumneko_lua" then
		client.resolved_capabilities.document_formatting = false
		client.resolved_capabilities.document_range_formatting = false
	end

	keymaps(bufnr)
	highlight_document(client)
	format_on_save()
end

-- lsp setup class
local lsp_setup = {
	setup = setup,
	on_attach = on_attach,
	capabilities = cmp_nvim_lsp.update_capabilities(capabilities),
}

return lsp_setup
