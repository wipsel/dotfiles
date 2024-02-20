-- This file contains a wrapper around packer.

local function setup_module(module)
    local ok, loaded = pcall(require, module.name)
    if not ok then
        vim.notify(string.format("module: %s not found, make sure it is installed.", module.name), vim.log.levels.WARN)

        return
    end

    if type(module.config) == "function" then
        local dependencies = {}

        if module.dependencies then
            for _, dependencie in pairs(module.dependencies) do
                local dep_ok, dep_loaded = pcall(require, dependencie.module)
                if not dep_ok then
                    vim.notify(
                        string.format("dep module: %s not found, make sure it is installed.", module.name),
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

local function use_plugins(plugin_specs)
    return function(use)
        for _, plugin in pairs(plugin_specs) do
            use(plugin)
        end
    end
end

return {
    load_config = function(config)
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

        local plugins = {}
        for _, module in pairs(config) do
            if module.plugin then
                table.insert(plugins, module.plugin)
            end
        end

        packer.init({
            display = {
                open_fn = function()
                    return util.float({ border = "rounded" })
                end,
            },
        })

        packer.startup(use_plugins(plugins))

        for _, module in pairs(config) do
            if module.name then
                setup_module(module)
            end
        end
    end,
}
