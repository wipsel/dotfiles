local function highlight_document(bufnr)
    local augroup = vim.api.nvim_create_augroup("LspDocumentHiglight", { clear = true })
    vim.api.nvim_create_autocmd("CursorHold", {
        group = augroup,
        callback = function()
            vim.lsp.buf.document_highlight()
        end,
        buffer = bufnr,
    })

    vim.api.nvim_create_autocmd("CursorMoved", {
        group = augroup,
        callback = function()
            vim.lsp.buf.clear_references()
        end,
        buffer = bufnr,
    })
end

local function auto_format(bufnr)
    local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
    vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        callback = function()
            vim.lsp.buf.format({ async = false })
        end,
        buffer = bufnr,
    })
end

local function on_attach(client, bufnr)
    if client.supports_method("textDocument/formatting") then
        auto_format(bufnr)
    end

    if client.supports_method("textDocument/documentHighlight") then
        highlight_document(bufnr)
    end
end

return {
    on_attach = on_attach,
    setup = function(config)
        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, config.diagnostic.float)
        vim.lsp.handlers["textDocument/signatureHelp"] =
            vim.lsp.with(vim.lsp.handlers.signature_help, config.diagnostic.float)

        for _, lsp in pairs(config.servers) do
            lsp.server.setup(lsp.config)
        end

        for _, sign in ipairs(config.diagnostic.signs.active) do
            vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
        end

        vim.diagnostic.config(config.diagnostic)
    end,
}
