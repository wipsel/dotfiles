local function old_plugins(use)
    use("wbthomason/packer.nvim")
    use("folke/neodev.nvim")

    -- Useful lua functions used by lots of plugins
    use("nvim-lua/plenary.nvim")

    -- colorschemes
    -- the real reason I became a programmer
    use({
        "neanias/everforest-nvim",
        "sainnhe/sonokai",
        "navarasu/onedark.nvim",
        "marko-cerovac/material.nvim",
        "rebelot/kanagawa.nvim",
    })

    -- icons for file types, errors git signs and stuff.
    --use("kyazdani42/nvim-web-devicons")
    use("nvim-tree/nvim-web-devicons")

    -- git stuff
    use("lewis6991/gitsigns.nvim")
    use("akinsho/git-conflict.nvim")

    use("nvim-tree/nvim-tree.lua")

    -- prettier ui for renaming and stuff.
    use("stevearc/dressing.nvim")
    use("nvim-lua/popup.nvim")

    -- colorize hex strings
    use("norcalli/nvim-colorizer.lua")

    -- easier commenting
    use("scrooloose/nerdcommenter")

    use("nvim-lualine/lualine.nvim")
    use("akinsho/bufferline.nvim")

    -- completion using cmp.
    use({
        "hrsh7th/nvim-cmp",
        -- A bunch of sources that cmp uses as input.
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/cmp-nvim-lsp",
        "saadparwaiz1/cmp_luasnip",
    })

    -- snippets
    use("L3MON4D3/LuaSnip")          --snippet engine
    use("rafamadriz/friendly-snippets") -- a bunch of snippets to use

    -- lsp setup
    use("neovim/nvim-lspconfig")
    use("jose-elias-alvarez/null-ls.nvim") -- for formatters and linters

    -- telescope
    use("nvim-telescope/telescope.nvim")

    -- treesitter
    use({
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
        tag = "v0.9.2",
    })
    use("echasnovski/mini.surround")

    -- golang
    use("olexsmir/gopher.nvim")
end

-------------------
-------------------

local function setup_module(module)
    return function()
        local ok, loaded = pcall(require, module.name)
        if not ok then
            vim.notify(
                string.format("module: %s not found, make sure it is installed.", module.name),
                vim.log.levels.WARN
            )

            return
        end

        if type(module.config) == "function" then
            local dependencies = {}

            if module.dependencies then
                for _, dependencie in pairs(module.dependencies) do
                    local dep_ok, dep_loaded = pcall(require, dependencie.module)
                    if not dep_ok then
                        vim.notify(
                            string.format("module: %s not found, make sure it is installed.", module.name),
                            vim.log.levels.WARN
                        )

                        return
                    end

                    dependencies[dependencie.name] = dep_loaded
                end
            end

            loaded.setup(module.config(loaded, dependencies))
        elseif type(module.config) == "table" then
            loaded.setup(module.config)
        elseif module.config == nil and loaded.setup then
            loaded.setup()
        end
    end
end

local function use_plugins(plugin_specs)
    return function(use)
        for _, plugin in pairs(plugin_specs) do
            use(plugin)
        end
    end
end

return {
    load_config = function(modules)
        local p_ok, packer = pcall(require, "packer")
        if not p_ok then
            vim.notify("packer not found, make sure it is installed.")
            return
        end

        local u_ok, util = pcall(require, "packer.util")
        if not u_ok then
            vim.notify("packer not found, make sure it is installed.")
            return
        end

        local config = {
            display = {
                open_fn = function()
                    return util.float({ border = "rounded" })
                end,
            },
        }

        local plugins = {}
        for i, module in pairs(modules) do
            if not module.plugin_name then
                setup_module(module)()
            else
                -- This is the "config" param that will be passed in to packers
                -- plugin spec. This is the code that will run after
                -- the plugin is loaded.
                -- An example of how a config would look like is
                -- require("lualine").setup(module.config)
                -- since the "name" is used in the "require" calle we check if the module has
                -- a name configured.
                local module_config = nil
                if module.name then
                    module_config = setup_module(module)
                end

                if type(module.plugin_name) == "table" then
                    for _, plugin in pairs(module.plugin_name) do
                        table.insert(plugins, plugin)
                    end

                    setup_module(module)()
                else
                    if module_config then
                        print(module.name)
                        print(module.plugin_name)
                        local plugin_spec = {
                            module.plugin_name,
                            config = module_config,
                        }
                        table.insert(plugins, plugin_spec)
                    else
                        --print(module.name)
                        --print(module.plugin_name)
                        table.insert(plugins, module.plugin_name)
                    end
                end
            end
        end

        packer.init(config)
        packer.startup(use_plugins(plugins))
    end,
}
