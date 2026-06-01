local function setup_module(module)
    local ok, loaded = pcall(require, module.name)
    if not ok then
        vim.notify(
            string.format(
                "module: %s not found, make sure it is installed.",
                module.name
            ),
            vim.log.levels.WARN
        )

        return
    end

    if type(module.config) == "function" then
        local deps = {}

        if module.deps then
            for _, dep in pairs(module.deps) do
                local dep_ok, dep_loaded = pcall(require, dep.module)
                if not dep_ok then
                    vim.notify(
                        string.format(
                            "dependency module: %s not found, make sure it is installed.",
                            module.name
                        ),
                        vim.log.levels.WARN
                    )

                    return
                end

                deps[dep.name] = dep_loaded
            end
        end

        loaded.setup(module.config(loaded, deps))
    elseif type(module.config) == "table" then
        loaded.setup(module.config)
    elseif module.config == nil and loaded.setup then
        loaded.setup()
    end
end

return {
    load_config = function(config)
        local specs = {}
        for _, module in pairs(config) do
            if module.plugin then
                local plugin = module.plugin
                if not plugin:match("^https?://") then
                    plugin = "https://github.com/" .. plugin
                end
                table.insert(specs, plugin)
            end
        end
        vim.pack.add(specs)

        for _, module in pairs(config) do
            if module.name then
                setup_module(module)
            end
        end
    end,
}
