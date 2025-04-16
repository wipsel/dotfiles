if vim.g.neovide then
    vim.g.neovide_cursor_animation_length = 0
    vim.o.guifont = "FiraCode Nerd Font"
end

-- Below is my neovim config. The package manager used is packer but
-- the idea is that it could be used with a different package manager in the
-- future. The config table specifies the plugins and their configuration.
--
--
-- The goal of this configuration was that it is small and independent of a package
-- manager.
--
-- Here is how it works: The config table below specifies all the plugins
-- and their options. It uses the following format:
--
-- {
-- name: Name of the module used in the `require` call for loading the module/plugin
-- plugin: The name of the plugin as used by packer (and many others)
-- config: The configuration passed into the setup function of a module/plugin
--         can be either a function returning a table or a table
-- deps: Optional dependency table that can be used in the config function for
--       a plugin.
--       For example: `lsp_config` needs `cmp` in its setup. So cmp will be
--       loaded and can be accessed within the config function using deps.cmp
-- }
--
-- These plugins are loaded using `require(name)`
-- and for each plugin the  `setup()`
-- is called with the provided `config`. The `config` field can either be a
-- For the implementation see ./lua/user/plugins.lua
--
-- The config table defines all configuration for setting up nvim.
local config = {
    { plugin = "neanias/everforest-nvim" },
    { plugin = "sainnhe/sonokai" },
    { plugin = "navarasu/onedark.nvim" },
    { plugin = "marko-cerovac/material.nvim" },
    {
        name = "kanagawa",
        plugin = "rebelot/kanagawa.nvim",
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
    { name = "user.options" },
    { plugin = "wbthomason/packer.nvim" },
    { plugin = "nvim-lua/plenary.nvim" },
    -- Neodev is used for neovim development
    {
        plugin = "folke/neodev.nvim",
        name = "neodev",
    },
    -- Nice icons for a bunch of plugins
    {
        plugin = "nvim-tree/nvim-web-devicons",
        name = "nvim-web-devicons",
    },
    -- Find and replace all across all files
    {
        plugin = "nvim-pack/nvim-spectre",
        name = "spectre",
    },
    { plugin = "scrooloose/nerdcommenter" },

    -- Nice rename window
    { plugin = "stevearc/dressing.nvim" },
    -- Colorize hex color string
    {
        plugin = "norcalli/nvim-colorizer.lua",
        name = "colorizer",
        config = {
            "css",
            "javascript",
            "typescript",
        },
    },
    -- Easier surrounding tags brackets etc
    { plugin = "tpope/vim-surround" },
    { plugin = "olexsmir/gopher.nvim" },
    {
        name = "user.keymaps",
        deps = {
            { name = "themes",        module = "telescope.themes" },
            { name = "picker",        module = "telescope.builtin" },
            { name = "spectre",       module = "spectre" },
            { name = "oil",           module = "oil" },
            { name = "git_conflicts", module = "git-conflict" },
        },
        config = function(keymaps, deps)
            return {
                leader = " ",
                visual = {
                    ["<leader>y"] = '"+y',
                },
                insert = {
                    ["jj"] = "<ESC>",
                },
                normal = {
                    -- Buffer navigation
                    ["<leader>h"] = { fn = vim.cmd.bp, desc = "Buffer prev" },
                    ["<leader>l"] = { fn = vim.cmd.bn, desc = "Buffer next" },
                    ["<leader>j"] = { fn = vim.cmd.bd, desc = "Buffer close" },

                    -- File related stuff
                    ["<CR>"] = { fn = keymaps.write_file, desc = "Write file" },
                    ["-"] = { fn = deps.oil.open_float, desc = "Open oil" },
                    ["="] = { fn = deps.oil.close, desc = "Close oil" },
                    -- pickers
                    ["<leader>k"] = {
                        fn = deps.picker.colorscheme,
                        opts = deps.themes.get_dropdown({ previewer = false }),
                        desc = "[K]olor Scheme",
                    },
                    ["<leader>p"] = {
                        fn = deps.picker.find_files,
                        opts = deps.themes.get_dropdown({ previewer = false }),
                        desc = "Control [P]",
                    },
                    ["<leader>o"] = {
                        fn = deps.picker.live_grep,
                        opts = deps.themes.get_dropdown({ previewer = true }),
                        desc = "Grep",
                    },
                    ["<leader>b"] = {
                        fn = deps.picker.buffers,
                        opts = deps.themes.get_dropdown({ previewer = true }),
                        desc = "[B]uffers",
                    },
                    ["<leader>gc"] = {
                        fn = deps.picker.git_commits,
                        opts = deps.themes.get_dropdown({ previewer = false }),
                        desc = "[G]it [C]ommits",
                    },
                    -- LSP functionality
                    ["gi"] = {
                        fn = deps.picker.lsp_implementations,
                        opts = deps.themes.get_dropdown({ previewer = false }),
                        desc = "[G]oto [I]implementation",
                    },
                    ["gr"] = {
                        fn = deps.picker.lsp_references,
                        opts = deps.themes.get_dropdown({ previewer = true }),
                        desc = "[G]oto [R]eferences",
                    },
                    ["gd"] = {
                        fn = vim.lsp.buf.definition,
                        desc = "[G]oto [R]eferences",
                    },
                    ["rn"] = { fn = vim.lsp.buf.rename, desc = "[R]e[N]ame" },
                    ["<c-f>"] = {
                        fn = vim.lsp.buf.format,
                        opts = { timeout_ms = 2000 },
                        desc = "[F]ormat",
                    },
                    ["<c-a>"] = {
                        fn = vim.lsp.buf.code_action,
                        opts = deps.themes.get_cursor({ winblend = 0 }),
                        desc = "[C]ode [A]ctions",
                    },
                    ["<c-k>"] = vim.lsp.buf.hover,
                    ["<c-n>"] = {
                        fn = vim.diagnostic.goto_next,
                        opts = { border = "rounded" },
                        desc = "[N]ext diagnostic",
                    },
                    ["<c-p>"] = {
                        fn = vim.diagnostic.goto_prev,
                        opts = { border = "rounded" },
                        desc = "[P]rev diagnostic",
                    },
                    ["gl"] = {
                        fn = vim.diagnostic.open_float,
                        opts = { width = 400 },
                        desc = "Open diagnostic float",
                    },

                    -- Git stuff
                    ["<leader>gn"] = {
                        fn = deps.git_conflicts.find_next,
                        opts = "none",
                        desc = "[G]it conflict [N]ext",
                    },
                    ["<leader>gp"] = {
                        fn = deps.git_conflicts.find_next,
                        opts = "none",
                        desc = "[G]it conflict [P]rev",
                    },
                    ["<leader>gt"] = {
                        fn = deps.git_conflicts.choose,
                        opts = "theirs",
                        desc = "[G]it conflict [T]heirs",
                    },
                    ["<leader>go"] = {
                        fn = deps.git_conflicts.choose,
                        opts = "ours",
                        desc = "[G]it conflict [O]urs",
                    },
                },
            }
        end,
    },
    {
        name = "null-ls",
        plugin = "nvimtools/none-ls.nvim",
        deps = {
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
                    null_ls.builtins.diagnostics.stylelint,
                    null_ls.builtins.diagnostics.golangci_lint.with({
                        prefer_local = ".bin",
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
        plugin = "neovim/nvim-lspconfig",
        deps = {
            { name = "lspconfig", module = "lspconfig" },
            { name = "util",      module = "lspconfig/util" },
            { name = "blink",     module = "blink.cmp" },
            { name = "icons",     module = "user.icons" },
            { name = "telescope", module = "telescope.builtin" },
        },
        config = function(lsp, deps)
            local lspconfig = deps.lspconfig
            local capabilities = deps.blink.get_lsp_capabilities()
            local util = deps.util
            local icons = deps.icons.diagnostic

            return {
                lsp_definitions = deps.telescope.lsp_definitions,
                servers = {
                    {
                        server = lspconfig.ruff,
                        config = {
                            capabilities = capabilities,
                        },
                    },
                    {
                        server = lspconfig.gopls,
                        config = {
                            capabilities = capabilities,
                            filetypes = { "go", "gomod", "gowork", "gotmpl" },
                            root_dir = util.root_pattern(
                                "go.work",
                                "go.mod",
                                ".git"
                            ),
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
                                -- disable formatting for gopls since we want none-ls to
                                -- take care of this.
                                client.server_capabilities.documentFormattingProvider =
                                    false
                                client.server_capabilities.documentRangeFormattingProvider =
                                    false

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
                        server = lspconfig.eslint,
                        config = {
                            capabilities = capabilities,
                            on_attach = function(client, bufnr)
                                vim.api.nvim_create_autocmd("BufWritePre", {
                                    buffer = bufnr,
                                    command = "EslintFixAll",
                                })

                                lsp.on_attach(client, bufnr)
                            end,
                        },
                    },
                    {
                        server = lspconfig.ts_ls,
                        config = {
                            capabilities = capabilities,
                            on_attach = function(client, bufnr)
                                -- disable formatting for tsserver since we want to use prettier
                                -- trought none-ls
                                client.server_capabilities.documentFormattingProvider =
                                    false
                                client.server_capabilities.documentRangeFormattingProvider =
                                    false

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
                            {
                                name = "DiagnosticSignError",
                                text = icons.Error,
                            },
                            { name = "DiagnosticSignWarn", text = icons.Warn },
                            { name = "DiagnosticSignHint", text = icons.Hint },
                            { name = "DiagnosticSignInfo", text = icons.Info },
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
    -- A snippet engine
    { plugin = "L3MON4D3/LuaSnip" },
    { plugin = "rafamadriz/friendly-snippets" }, -- a bunch of snippets to use
    -- Completion using cmp.
    {
        name = "blink.cmp",
        plugin = "saghen/blink.cmp",
        deps = {
            { name = "icons", module = "user.icons" },
        },
        config = function(blink, deps)
            return {
                completion = {
                    documentation = {
                        auto_show = true,
                    },
                    menu = {
                        min_width = 20,
                        border = "rounded",
                        winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
                        draw = {
                            components = {
                                label_description = {
                                    width = { max = 30 },
                                    text = function(ctx)
                                        return ctx.label_description
                                    end,
                                    highlight = "NonText",
                                },
                            },
                            columns = {
                                { "label" },
                                { "kind_icon",         "kind", gap = 1 },
                                { "label_description", gap = 1 },
                            },
                        },
                    },
                },
                enabled = function()
                    return not vim.list_contains(
                        { "DressingInput" },
                        vim.bo.filetype
                    ) and vim.bo.buftype ~= "prompt" and vim.b.completion ~= false
                end,
                appearance = {
                    kind_icons = deps.icons.cmp,
                },
                keymap = {
                    preset = "default",
                    ["<S-Tab>"] = {
                        "select_prev",
                        "snippet_backward",
                        "fallback",
                    },
                    ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
                    ["<CR>"] = { "accept", "fallback" },
                    --["<Esc>"] = { "hide", "fallback" },
                    ["<PageUp>"] = { "scroll_documentation_up", "fallback" },
                    ["<PageDown>"] = { "scroll_documentation_down", "fallback" },
                },
            }
        end,
    },
    -- Telescope is defines multiple pickers that can be used to do stuff
    -- like finding a file or a word. Or select a colorscheme.
    {
        name = "telescope",
        plugin = "nvim-telescope/telescope.nvim",
        config = {
            defaults = {
                find_cmd = "rg",
                prompt_prefix = " ",
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
    -- Treat file structure like a buffer.
    {
        plugin = "stevearc/oil.nvim",
        name = "oil",
        config = {
            default_file_explorer = true,
            view_options = {
                show_hidden = true,
            },
            float = {
                padding = 4,
                max_width = 80,
                max_height = 30,
                border = "rounded",
            },
        },
    },
    {
        plugin = "nvim-treesitter/nvim-treesitter",
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
    --  Git integration stuff
    {
        name = "git-conflict",
        plugin = "akinsho/git-conflict.nvim",
    },
    {
        name = "gitsigns",
        plugin = "lewis6991/gitsigns.nvim",
        config = {
            numhl = true,
            signcolumn = false,
            current_line_blame = true,
            current_line_blame_opts = {
                delay = 100,
            },
        },
    },
    {
        name = "lualine",
        plugin = { "nvim-lualine/lualine.nvim" },
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
            tabline = {
                lualine_b = {
                    {
                        "buffers",
                        buffers_color = {
                            active = { bg = "#7e9cd8", fg = "#16161d" },
                            inactive = { bg = "#16161d", fg = "#7e9cd8" },
                        },
                        filetype_names = {
                            TelescopePrompt = "  ",
                        },
                        symbols = {
                            alternate_file = "",
                        },
                    },
                },
            },
            extensions = {},
        },
    },
}

local ok, plugins = pcall(require, "user.plugins")
if not ok then
    vim.notify("Failed to initialize nvim")
    return
end

plugins.load_config(config)
