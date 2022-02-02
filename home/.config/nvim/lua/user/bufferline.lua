require("bufferline").setup{
    options = {
        close_icon = '',
        buffer_close_icon = '',
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(count, level)
            local icon = level:match("error") and " " or " "
            return " " .. icon .. count
        end
    }
}
