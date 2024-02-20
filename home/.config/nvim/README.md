### Some info about the setup

---

Plugins are managed using [packer](https://github.com/wbthomason/packer.nvim)
Note that packer is currently unmaintained and I should probably move to something
else.

The `init.lua` calls setup for each installed plugin. I add plugins
and optional user config using a lua table.
For adding a plugin use the following format:

```lua
{
    plugin = "plugin-name" -- name of the plugin according to the packer plugin spec.
    name = "module-name" -- name of the module that should be loaded for a plugin
    dependencies = {name = "identifier", module="module-name"} --
    config = {} or function(module, deps) -- the table that you would pass into the setup function for the plugin
}
```

Then I also have some modules under `lua/user`. These modules contain
the setup for plugins that need some additional setup as wel as
keybinds and global nvim options
