### Some info about the setup

---

Plugins are managed using [packer](https://github.com/wbthomason/packer.nvim)
Note that packer is currently unmaintained and I should probably move to something
else.

The `init.lua` calls the setup for each installed plugin. I add plugins
and optional user config using a lua table.
For adding a plugin use the following format:

```lua
{
    name = "module-name" -- same as plugin name
    config = {} -- the table that you would pass into the setup function for the plugin
}
```

Then I also have some modules under `lua/user`. These modules contain
the setup for plugins that need some additional setup as wel as
keybinds and global nvim options
