local function highlight_document(bufnr)
    local augroup =
        vim.api.nvim_create_augroup("LspDocumentHiglight", { clear = true })
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
        for _, lsp in pairs(config.servers) do
            vim.lsp.config(lsp.server, lsp.config)
            vim.lsp.enable(lsp.server)
        end

        vim.diagnostic.config(config.diagnostic)
    end,
}
