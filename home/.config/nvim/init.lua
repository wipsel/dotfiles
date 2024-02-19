local KIND_ICONS = {
    Text = "",
    Method = "m",
    Function = "",
    Constructor = "",
    Field = "",
    Variable = "",
    Class = "",
    Interface = "",
    Module = "",
    Property = "",
    Unit = "",
    Value = "",
    Enum = "",
    Keyword = "",
    Snippet = "",
    Color = "",
    File = "",
    Reference = "",
    Folder = "",
    EnumMember = "",
    Constant = "",
    Struct = "",
    Event = "",
    Operator = "",
    TypeParameter = "",
}

local modules = {
    {
        name = "user.plugins",
    },
    {
        name = "user.keymaps",
        dependencies = {
            { name = "themes",   module = "telescope.themes" },
            { name = "picker",   module = "telescope.builtin" },
            { name = "tree_api", module = "nvim-tree.api" },
        },
        config = function(keymaps, deps)
            local picker = deps.picker
            local dropdown = deps.themes.get_dropdown({ previewer = false })
            local cursor = deps.themes.get_cursor({ winblend = 0 })
            local tree = deps.tree_api.tree

            return {
                leader = " ",
                insert = {
                    ["jj"] = "<ESC>",
                },
                normal = {
                    ["<leader>h"] = vim.cmd.bp,
                    ["<leader>j"] = vim.cmd.bd,
                    ["<leader>l"] = vim.cmd.bn,
                    -- is this the way to do a no op?
                    ["<Space>"] = function() end,
                    ["<CR>"] = keymaps.write_file,
                    ["<leader>k"] = { fn = picker.colorscheme, opts = dropdown },
                    ["<leader>p"] = { fn = picker.find_files, opts = dropdown },
                    ["<leader>o"] = { fn = picker.live_grep, opts = dropdown },
                    ["<leader>i"] = { fn = picker.git_commits, opts = dropdown },
                    ["<leader>u"] = { fn = picker.lsp_implementation, opts = cursor },
                    ["<leader>t"] = tree.toggle,
                    ["<leader>r"] = tree.focus,
                    ["gd"] = vim.lsp.buf.definition,
                    ["<C-k>"] = vim.lsp.buf.hover,
                    ["gi"] = vim.lsp.buf.implementation,
                    ["rn"] = vim.lsp.buf.rename,
                    ["gr"] = vim.lsp.buf.references,
                    ["<C-f>"] = { fn = vim.lsp.buf.format, opts = { timeout_ms = 2000 } },
                    ["<c-n>"] = { fn = vim.diagnostic.goto_next, opts = { border = "rounded" } },
                    ["<C-p>"] = { fn = vim.diagnostic.goto_prev, opts = { border = "rounded" } },
                    ["gl"] = { fn = vim.diagnostic.open_float, opts = { width = 400 } },
                    ["<leader>q"] = vim.diagnostic.setloclist,
                },
            }
        end,
    },
    {
        plugin_name = "jose-elias-alvarez/null-ls.nvim",
        name = "null-ls",
        dependencies = {
            { name = "lsp", module = "user.lsp" },
        },
        config = function(null_ls, deps)
            return {
                debug = false,
                sources = {
                    null_ls.builtins.formatting.stylua,
                    null_ls.builtins.formatting.prettier,
                    null_ls.builtins.formatting.goimports,
                    null_ls.builtins.formatting.gofumpt,
                    null_ls.builtins.formatting.isort,
                    null_ls.builtins.formatting.black,
                    null_ls.builtins.diagnostics.eslint_d,
                    null_ls.builtins.diagnostics.stylelint,
                    null_ls.builtins.diagnostics.golangci_lint.with({
                        args = {
                            "run",
                            "--fix=false",
                            "--fast",
                            "--out-format=json",
                        },
                    }),
                },
                on_attach = deps.lsp.on_attach,
            }
        end,
    },
    {
        name = "user.lsp",
        plugin_name = "neovim/nvim-lspconfig",
        dependencies = {
            { name = "lspconfig", module = "lspconfig" },
            { name = "cmp",       module = "cmp_nvim_lsp" },
            { name = "util",      module = "lspconfig/util" },
        },
        config = function(lsp, deps)
            local lspconfig = deps.lspconfig
            local capabilities = deps.cmp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
            local util = deps.util

            return {
                servers = {
                    {
                        server = lspconfig.ruff_lsp,
                        config = {
                            capabilities = capabilities,
                        },
                    },
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
                            on_attach = function(client, bufnr)
                                -- disable formatting for gopls since we want null-ls to
                                -- take care of this.
                                client.server_capabilities.documentFormattingProvider = false
                                client.server_capabilities.documentRangeFormattingProvider = false

                                lsp.on_attach(client, bufnr)
                            end,
                        },
                    },
                    {
                        server = lspconfig.lua_ls,
                        config = {
                            capabilities = capabilities,
                            on_attach = lsp.on_attach,
                        },
                    },
                    {
                        server = lspconfig.tsserver,
                        config = {
                            capabilities = capabilities,
                            on_attach = function(client, bufnr)
                                -- disable formatting for tsserver since we want to use prettier
                                -- trhought null-ls
                                client.server_capabilities.documentFormattingProvider = false
                                client.server_capabilities.documentRangeFormattingProvider = false

                                lsp.on_attach(client, bufnr)
                            end,
                        },
                    },
                    {
                        server = lspconfig.pyright,
                        config = {
                            capabilities = capabilities,
                            on_attach = lsp.on_attach,
                        },
                    },
                },
                diagnostic = {
                    virtual_text = false,
                    signs = {
                        active = {
                            { name = "DiagnosticSignError", text = "" },
                            { name = "DiagnosticSignWarn", text = "" },
                            { name = "DiagnosticSignHint", text = "" },
                            { name = "DiagnosticSignInfo", text = "" },
                        },
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
        end,
    },
    {
        plugin_name = {
            "hrsh7th/nvim-cmp",
            -- A bunch of sources that cmp uses as input.
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-nvim-lsp",
            "saadparwaiz1/cmp_luasnip",
        },
        name = "cmp",
        dependencies = {
            { name = "luasnip",        module = "luasnip" },
            { name = "luasnip_loader", module = "luasnip/loaders/from_vscode" },
        },
        config = function(cmp, deps)
            deps.luasnip_loader.lazy_load()
            local luasnip = deps.luasnip

            return {
                snippet = {
                    expand = function(args)
                        deps.luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = {
                    ["<CR>"] = cmp.mapping.confirm({
                        behavior = cmp.ConfirmBehavior.Insert,
                        select = true,
                    }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expandable() then
                            luasnip.expand()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                },
                formatting = {
                    fields = { "kind", "abbr", "menu" },
                    format = function(entry, vim_item)
                        vim_item.kind = string.format("%s", KIND_ICONS[vim_item.kind])
                        vim_item.menu = ({
                            nvim_lsp = "[Lsp]",
                            luasnip = "[Snippet]",
                            buffer = "[Buffer]",
                            path = "[Path]",
                        })[entry.source.name]

                        return vim_item
                    end,
                },
                sources = {
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "buffer" },
                    { name = "nvim_lsp_signature_help" },
                    { name = "path" },
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
            }
        end,
    },
    {
        plugin_name = "nvim-telescope/telescope.nvim",
        name = "telescope",
        config = {
            defaults = {
                find_cmd = "rg",
                prompt_prefix = "  ",
                selection_caret = "  ",
                selection_strategy = "reset",
                sorting_strategy = "ascending",
                layout_strategy = "vertical",
                layout_config = {
                    vertical = {
                        mirror = true,
                    },
                },
                winblend = 20,
                use_less = false,
                set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
            },
        },
    },
    {
        plugin_name = "nvim-tree/nvim-tree.lua",
        name = "nvim-tree",
    },
    {
        name = "neodev",
    },
    {
        plugin_name = "nvim-treesitter/nvim-treesitter",
        name = "nvim-treesitter.configs",
        config = {
            ensure_installed = "all",
            highlight = {
                enable = true,
            },
            indent = {
                enable = false,
            },
        },
    },
    {
        plugin_name = "akinsho/git-conflict.nvim",
        name = "git-conflict",
    },
    {
        plugin_name = "lewis6991/gitsigns.nvim",
        name = "gitsigns",
        config = {
            numhl = true,
            current_line_blame = true,
            current_line_blame_opts = {
                delay = 100,
            },
        },
    },
    {
        name = "bufferline",
        plugin_name = "akinsho/bufferline.nvim",
        config = {
            options = {
                close_icon = "",
                buffer_close_icon = "",
                diagnostics = "nvim_lsp",
                diagnostics_indicator = function(count, level)
                    local icon = level:match("error") and " " or " "
                    return " " .. icon .. count
                end,
            },
        },
    },
    {
        name = "kanagawa",
        plugin_name = {
            "neanias/everforest-nvim",
            "sainnhe/sonokai",
            "navarasu/onedark.nvim",
            "marko-cerovac/material.nvim",
            "rebelot/kanagawa.nvim",
        },
        config = {
            commentStyle = { italic = true },
            functionStyle = { bold = true },
            overrides = function(colors)
                local theme = colors.theme
                return {
                    NormalFloat = { bg = "none" },
                    FloatBorder = { bg = "none" },
                    FloatTitle = { bg = "none" },
                    NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },
                }
            end,
        },
    },
    {
        plugin_name= "nvim-tree/nvim-web-devicons",
    },
    {
        plugin_name= "nvim-lua/plenary.nvim",
    },
    {
        plugin_name = "scrooloose/nerdcommenter",
    },
    {
        name = "lualine",
        plugin_name = "nvim-lualine/lualine.nvim",
        config = {
            options = {
                icons_enabled = true,
                theme = "auto",
                component_separators = { left = "|", right = "|" },
                section_separators = { left = "", right = "" },
                disabled_filetypes = {},
                always_divide_middle = true,
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "branch", "diff", "diagnostics" },
                lualine_c = { "filename" },
                lualine_x = { "encoding", "fileformat", "filetype" },
                lualine_y = { "progress" },
                lualine_z = { "location" },
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = { "filename" },
                lualine_x = { "location" },
                lualine_y = {},
                lualine_z = {},
            },
            tabline = {},
            extensions = {},
        },
    },
    {
        name = "user.options",
    },
}


local ok, plugins = pcall(require, "user.plugins")
if not ok then
    vim.notify("stuk")
    return
end

plugins.load_config(modules)
