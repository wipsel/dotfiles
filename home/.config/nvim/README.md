### Some info about the setup
-----------------------------
The `init.lua` only contains calls to setup function of other config files 
located in `./lua/user`. Most of these files only do the setup for one specific 
plugin. These plugins are managed by [packer](https://github.com/wbthomason/packer.nvim).
The setup for a plugin is usually done in a lua file with the same name as the plugin. 
Each config file should return a function called `setup` which can be called in the init.
