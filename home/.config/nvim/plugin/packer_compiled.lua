-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

_G._packer = _G._packer or {}
_G._packer.inside_compile = true

local time
local profile_info
local should_profile = false
if should_profile then
  local hrtime = vim.loop.hrtime
  profile_info = {}
  time = function(chunk, start)
    if start then
      profile_info[chunk] = hrtime()
    else
      profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
    end
  end
else
  time = function(chunk, start) end
end

local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end
  if threshold then
    table.insert(results, '(Only showing plugins that took longer than ' .. threshold .. ' ms ' .. 'to load)')
  end

  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/home/wipsel/.cache/nvim/packer_hererocks/2.1.1699392533/share/lua/5.1/?.lua;/home/wipsel/.cache/nvim/packer_hererocks/2.1.1699392533/share/lua/5.1/?/init.lua;/home/wipsel/.cache/nvim/packer_hererocks/2.1.1699392533/lib/luarocks/rocks-5.1/?.lua;/home/wipsel/.cache/nvim/packer_hererocks/2.1.1699392533/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/home/wipsel/.cache/nvim/packer_hererocks/2.1.1699392533/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  ["bufferline.nvim"] = {
    config = { "\27LJ\2\n™\4\0\0\16\1\19\0Z6\0\0\0006\2\1\0-\3\0\0009\3\2\3B\0\3\3\14\0\0\0X\2\14€6\2\3\0009\2\4\0026\4\5\0009\4\6\4'\6\a\0-\a\0\0009\a\2\aB\4\3\0026\5\3\0009\5\b\0059\5\t\0059\5\n\5B\2\3\1K\0\1\0006\2\v\0-\4\0\0009\4\f\4B\2\2\2\a\2\r\0X\2*€4\2\0\0-\3\0\0009\3\14\3\15\0\3\0X\4\29€6\3\15\0-\5\0\0009\5\14\5B\3\2\4H\6\22€6\b\0\0006\n\1\0009\v\16\aB\b\3\3\14\0\b\0X\n\14€6\n\3\0009\n\4\n6\f\5\0009\f\6\f'\14\a\0-\15\0\0009\15\2\15B\f\3\0026\r\3\0009\r\b\r9\r\t\r9\r\n\rB\n\3\1K\0\1\0009\n\2\a<\t\n\2F\6\3\3R\6è\1279\3\17\1-\5\0\0009\5\f\5\18\a\1\0\18\b\2\0B\5\3\0A\3\0\1X\2\20€6\2\v\0-\4\0\0009\4\f\4B\2\2\2\a\2\18\0X\2\5€9\2\17\1-\4\0\0009\4\f\4B\2\2\1X\2\t€-\2\0\0009\2\f\2\v\2\0\0X\2\5€9\2\17\1\15\0\2\0X\3\2€9\2\17\1B\2\1\1K\0\1\0\0À\ntable\nsetup\vmodule\npairs\17dependencies\rfunction\vconfig\ttype\tWARN\vlevels\blog5module: %s not found, make sure it is installed.\vformat\vstring\vnotify\bvim\tname\frequire\npcall\0" },
    loaded = true,
    path = "/home/wipsel/.local/share/nvim/site/pack/packer/start/bufferline.nvim",
    url = "https://github.com/akinsho/bufferline.nvim"
  },
  ["cmp-buffer"] = {
    loaded = true,
    path = "/home/wipsel/.local/share/nvim/site/pack/packer/start/cmp-buffer",
    url = "https://github.com/hrsh7th/cmp-buffer"
  },
  ["cmp-cmdline"] = {
    loaded = true,
    path = "/home/wipsel/.local/share/nvim/site/pack/packer/start/cmp-cmdline",
    url = "https://github.com/hrsh7th/cmp-cmdline"
  },
  ["cmp-nvim-lsp"] = {
    loaded = true,
    path = "/home/wipsel/.local/share/nvim/site/pack/packer/start/cmp-nvim-lsp",
    url = "https://github.com/hrsh7th/cmp-nvim-lsp"
  },
  ["cmp-path"] = {
    loaded = true,
    path = "/home/wipsel/.local/share/nvim/site/pack/packer/start/cmp-path",
    url = "https://github.com/hrsh7th/cmp-path"
  },
  cmp_luasnip = {
    loaded = true,
    path = "/home/wipsel/.local/share/nvim/site/pack/packer/start/cmp_luasnip",
    url = "https://github.com/saadparwaiz1/cmp_luasnip"
  },
  ["everforest-nvim"] = {
    loaded = true,
    path = "/home/wipsel/.local/share/nvim/site/pack/packer/start/everforest-nvim",
    url = "https://github.com/neanias/everforest-nvim"
  },
  ["git-conflict.nvim"] = {
    config = { "\27LJ\2\n™\4\0\0\16\1\19\0Z6\0\0\0006\2\1\0-\3\0\0009\3\2\3B\0\3\3\14\0\0\0X\2\14€6\2\3\0009\2\4\0026\4\5\0009\4\6\4'\6\a\0-\a\0\0009\a\2\aB\4\3\0026\5\3\0009\5\b\0059\5\t\0059\5\n\5B\2\3\1K\0\1\0006\2\v\0-\4\0\0009\4\f\4B\2\2\2\a\2\r\0X\2*€4\2\0\0-\3\0\0009\3\14\3\15\0\3\0X\4\29€6\3\15\0-\5\0\0009\5\14\5B\3\2\4H\6\22€6\b\0\0006\n\1\0009\v\16\aB\b\3\3\14\0\b\0X\n\14€6\n\3\0009\n\4\n6\f\5\0009\f\6\f'\14\a\0-\15\0\0009\15\2\15B\f\3\0026\r\3\0009\r\b\r9\r\t\r9\r\n\rB\n\3\1K\0\1\0009\n\2\a<\t\n\2F\6\3\3R\6è\1279\3\17\1-\5\0\0009\5\f\5\18\a\1\0\18\b\2\0B\5\3\0A\3\0\1X\2\20€6\2\v\0-\4\0\0009\4\f\4B\2\2\2\a\2\18\0X\2\5€9\2\17\1-\4\0\0009\4\f\4B\2\2\1X\2\t€-\2\0\0009\2\f\2\v\2\0\0X\2\5€9\2\17\1\15\0\2\0X\3\2€9\2\17\1B\2\1\1K\0\1\0\0À\ntable\nsetup\vmodule\npairs\17dependencies\rfunction\vconfig\ttype\tWARN\vlevels\blog5module: %s not found, make sure it is installed.\vformat\vstring\vnotify\bvim\tname\frequire\npcall\0" },
    loaded = true,
    path = "/home/wipsel/.local/share/nvim/site/pack/packer/start/git-conflict.nvim",
    url = "https://github.com/akinsho/git-conflict.nvim"
  },
  ["gitsigns.nvim"] = {
    config = { "\27LJ\2\n™\4\0\0\16\1\19\0Z6\0\0\0006\2\1\0-\3\0\0009\3\2\3B\0\3\3\14\0\0\0X\2\14€6\2\3\0009\2\4\0026\4\5\0009\4\6\4'\6\a\0-\a\0\0009\a\2\aB\4\3\0026\5\3\0009\5\b\0059\5\t\0059\5\n\5B\2\3\1K\0\1\0006\2\v\0-\4\0\0009\4\f\4B\2\2\2\a\2\r\0X\2*€4\2\0\0-\3\0\0009\3\14\3\15\0\3\0X\4\29€6\3\15\0-\5\0\0009\5\14\5B\3\2\4H\6\22€6\b\0\0006\n\1\0009\v\16\aB\b\3\3\14\0\b\0X\n\14€6\n\3\0009\n\4\n6\f\5\0009\f\6\f'\14\a\0-\15\0\0009\15\2\15B\f\3\0026\r\3\0009\r\b\r9\r\t\r9\r\n\rB\n\3\1K\0\1\0009\n\2\a<\t\n\2F\6\3\3R\6è\1279\3\17\1-\5\0\0009\5\f\5\18\a\1\0\18\b\2\0B\5\3\0A\3\0\1X\2\20€6\2\v\0-\4\0\0009\4\f\4B\2\2\2\a\2\18\0X\2\5€9\2\17\1-\4\0\0009\4\f\4B\2\2\1X\2\t€-\2\0\0009\2\f\2\v\2\0\0X\2\5€9\2\17\1\15\0\2\0X\3\2€9\2\17\1B\2\1\1K\0\1\0\0À\ntable\nsetup\vmodule\npairs\17dependencies\rfunction\vconfig\ttype\tWARN\vlevels\blog5module: %s not found, make sure it is installed.\vformat\vstring\vnotify\bvim\tname\frequire\npcall\0" },
    loaded = true,
    path = "/home/wipsel/.local/share/nvim/site/pack/packer/start/gitsigns.nvim",
    url = "https://github.com/lewis6991/gitsigns.nvim"
  },
  ["kanagawa.nvim"] = {
    loaded = true,
    path = "/home/wipsel/.local/share/nvim/site/pack/packer/start/kanagawa.nvim",
    url = "https://github.com/rebelot/kanagawa.nvim"
  },
  ["lualine.nvim"] = {
    config = { "\27LJ\2\n™\4\0\0\16\1\19\0Z6\0\0\0006\2\1\0-\3\0\0009\3\2\3B\0\3\3\14\0\0\0X\2\14€6\2\3\0009\2\4\0026\4\5\0009\4\6\4'\6\a\0-\a\0\0009\a\2\aB\4\3\0026\5\3\0009\5\b\0059\5\t\0059\5\n\5B\2\3\1K\0\1\0006\2\v\0-\4\0\0009\4\f\4B\2\2\2\a\2\r\0X\2*€4\2\0\0-\3\0\0009\3\14\3\15\0\3\0X\4\29€6\3\15\0-\5\0\0009\5\14\5B\3\2\4H\6\22€6\b\0\0006\n\1\0009\v\16\aB\b\3\3\14\0\b\0X\n\14€6\n\3\0009\n\4\n6\f\5\0009\f\6\f'\14\a\0-\15\0\0009\15\2\15B\f\3\0026\r\3\0009\r\b\r9\r\t\r9\r\n\rB\n\3\1K\0\1\0009\n\2\a<\t\n\2F\6\3\3R\6è\1279\3\17\1-\5\0\0009\5\f\5\18\a\1\0\18\b\2\0B\5\3\0A\3\0\1X\2\20€6\2\v\0-\4\0\0009\4\f\4B\2\2\2\a\2\18\0X\2\5€9\2\17\1-\4\0\0009\4\f\4B\2\2\1X\2\t€-\2\0\0009\2\f\2\v\2\0\0X\2\5€9\2\17\1\15\0\2\0X\3\2€9\2\17\1B\2\1\1K\0\1\0\0À\ntable\nsetup\vmodule\npairs\17dependencies\rfunction\vconfig\ttype\tWARN\vlevels\blog5module: %s not found, make sure it is installed.\vformat\vstring\vnotify\bvim\tname\frequire\npcall\0" },
    loaded = true,
    path = "/home/wipsel/.local/share/nvim/site/pack/packer/start/lualine.nvim",
    url = "https://github.com/nvim-lualine/lualine.nvim"
  },
  ["material.nvim"] = {
    loaded = true,
    path = "/home/wipsel/.local/share/nvim/site/pack/packer/start/material.nvim",
    url = "https://github.com/marko-cerovac/material.nvim"
  },
  nerdcommenter = {
    loaded = true,
    path = "/home/wipsel/.local/share/nvim/site/pack/packer/start/nerdcommenter",
    url = "https://github.com/scrooloose/nerdcommenter"
  },
  ["null-ls.nvim"] = {
    config = { "\27LJ\2\n™\4\0\0\16\1\19\0Z6\0\0\0006\2\1\0-\3\0\0009\3\2\3B\0\3\3\14\0\0\0X\2\14€6\2\3\0009\2\4\0026\4\5\0009\4\6\4'\6\a\0-\a\0\0009\a\2\aB\4\3\0026\5\3\0009\5\b\0059\5\t\0059\5\n\5B\2\3\1K\0\1\0006\2\v\0-\4\0\0009\4\f\4B\2\2\2\a\2\r\0X\2*€4\2\0\0-\3\0\0009\3\14\3\15\0\3\0X\4\29€6\3\15\0-\5\0\0009\5\14\5B\3\2\4H\6\22€6\b\0\0006\n\1\0009\v\16\aB\b\3\3\14\0\b\0X\n\14€6\n\3\0009\n\4\n6\f\5\0009\f\6\f'\14\a\0-\15\0\0009\15\2\15B\f\3\0026\r\3\0009\r\b\r9\r\t\r9\r\n\rB\n\3\1K\0\1\0009\n\2\a<\t\n\2F\6\3\3R\6è\1279\3\17\1-\5\0\0009\5\f\5\18\a\1\0\18\b\2\0B\5\3\0A\3\0\1X\2\20€6\2\v\0-\4\0\0009\4\f\4B\2\2\2\a\2\18\0X\2\5€9\2\17\1-\4\0\0009\4\f\4B\2\2\1X\2\t€-\2\0\0009\2\f\2\v\2\0\0X\2\5€9\2\17\1\15\0\2\0X\3\2€9\2\17\1B\2\1\1K\0\1\0\0À\ntable\nsetup\vmodule\npairs\17dependencies\rfunction\vconfig\ttype\tWARN\vlevels\blog5module: %s not found, make sure it is installed.\vformat\vstring\vnotify\bvim\tname\frequire\npcall\0" },
    loaded = true,
    path = "/home/wipsel/.local/share/nvim/site/pack/packer/start/null-ls.nvim",
    url = "https://github.com/jose-elias-alvarez/null-ls.nvim"
  },
  ["nvim-cmp"] = {
    loaded = true,
    path = "/home/wipsel/.local/share/nvim/site/pack/packer/start/nvim-cmp",
    url = "https://github.com/hrsh7th/nvim-cmp"
  },
  ["nvim-lspconfig"] = {
    config = { "\27LJ\2\n™\4\0\0\16\1\19\0Z6\0\0\0006\2\1\0-\3\0\0009\3\2\3B\0\3\3\14\0\0\0X\2\14€6\2\3\0009\2\4\0026\4\5\0009\4\6\4'\6\a\0-\a\0\0009\a\2\aB\4\3\0026\5\3\0009\5\b\0059\5\t\0059\5\n\5B\2\3\1K\0\1\0006\2\v\0-\4\0\0009\4\f\4B\2\2\2\a\2\r\0X\2*€4\2\0\0-\3\0\0009\3\14\3\15\0\3\0X\4\29€6\3\15\0-\5\0\0009\5\14\5B\3\2\4H\6\22€6\b\0\0006\n\1\0009\v\16\aB\b\3\3\14\0\b\0X\n\14€6\n\3\0009\n\4\n6\f\5\0009\f\6\f'\14\a\0-\15\0\0009\15\2\15B\f\3\0026\r\3\0009\r\b\r9\r\t\r9\r\n\rB\n\3\1K\0\1\0009\n\2\a<\t\n\2F\6\3\3R\6è\1279\3\17\1-\5\0\0009\5\f\5\18\a\1\0\18\b\2\0B\5\3\0A\3\0\1X\2\20€6\2\v\0-\4\0\0009\4\f\4B\2\2\2\a\2\18\0X\2\5€9\2\17\1-\4\0\0009\4\f\4B\2\2\1X\2\t€-\2\0\0009\2\f\2\v\2\0\0X\2\5€9\2\17\1\15\0\2\0X\3\2€9\2\17\1B\2\1\1K\0\1\0\0À\ntable\nsetup\vmodule\npairs\17dependencies\rfunction\vconfig\ttype\tWARN\vlevels\blog5module: %s not found, make sure it is installed.\vformat\vstring\vnotify\bvim\tname\frequire\npcall\0" },
    loaded = true,
    path = "/home/wipsel/.local/share/nvim/site/pack/packer/start/nvim-lspconfig",
    url = "https://github.com/neovim/nvim-lspconfig"
  },
  ["nvim-tree.lua"] = {
    config = { "\27LJ\2\n™\4\0\0\16\1\19\0Z6\0\0\0006\2\1\0-\3\0\0009\3\2\3B\0\3\3\14\0\0\0X\2\14€6\2\3\0009\2\4\0026\4\5\0009\4\6\4'\6\a\0-\a\0\0009\a\2\aB\4\3\0026\5\3\0009\5\b\0059\5\t\0059\5\n\5B\2\3\1K\0\1\0006\2\v\0-\4\0\0009\4\f\4B\2\2\2\a\2\r\0X\2*€4\2\0\0-\3\0\0009\3\14\3\15\0\3\0X\4\29€6\3\15\0-\5\0\0009\5\14\5B\3\2\4H\6\22€6\b\0\0006\n\1\0009\v\16\aB\b\3\3\14\0\b\0X\n\14€6\n\3\0009\n\4\n6\f\5\0009\f\6\f'\14\a\0-\15\0\0009\15\2\15B\f\3\0026\r\3\0009\r\b\r9\r\t\r9\r\n\rB\n\3\1K\0\1\0009\n\2\a<\t\n\2F\6\3\3R\6è\1279\3\17\1-\5\0\0009\5\f\5\18\a\1\0\18\b\2\0B\5\3\0A\3\0\1X\2\20€6\2\v\0-\4\0\0009\4\f\4B\2\2\2\a\2\18\0X\2\5€9\2\17\1-\4\0\0009\4\f\4B\2\2\1X\2\t€-\2\0\0009\2\f\2\v\2\0\0X\2\5€9\2\17\1\15\0\2\0X\3\2€9\2\17\1B\2\1\1K\0\1\0\0À\ntable\nsetup\vmodule\npairs\17dependencies\rfunction\vconfig\ttype\tWARN\vlevels\blog5module: %s not found, make sure it is installed.\vformat\vstring\vnotify\bvim\tname\frequire\npcall\0" },
    loaded = true,
    path = "/home/wipsel/.local/share/nvim/site/pack/packer/start/nvim-tree.lua",
    url = "https://github.com/nvim-tree/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    config = { "\27LJ\2\n™\4\0\0\16\1\19\0Z6\0\0\0006\2\1\0-\3\0\0009\3\2\3B\0\3\3\14\0\0\0X\2\14€6\2\3\0009\2\4\0026\4\5\0009\4\6\4'\6\a\0-\a\0\0009\a\2\aB\4\3\0026\5\3\0009\5\b\0059\5\t\0059\5\n\5B\2\3\1K\0\1\0006\2\v\0-\4\0\0009\4\f\4B\2\2\2\a\2\r\0X\2*€4\2\0\0-\3\0\0009\3\14\3\15\0\3\0X\4\29€6\3\15\0-\5\0\0009\5\14\5B\3\2\4H\6\22€6\b\0\0006\n\1\0009\v\16\aB\b\3\3\14\0\b\0X\n\14€6\n\3\0009\n\4\n6\f\5\0009\f\6\f'\14\a\0-\15\0\0009\15\2\15B\f\3\0026\r\3\0009\r\b\r9\r\t\r9\r\n\rB\n\3\1K\0\1\0009\n\2\a<\t\n\2F\6\3\3R\6è\1279\3\17\1-\5\0\0009\5\f\5\18\a\1\0\18\b\2\0B\5\3\0A\3\0\1X\2\20€6\2\v\0-\4\0\0009\4\f\4B\2\2\2\a\2\18\0X\2\5€9\2\17\1-\4\0\0009\4\f\4B\2\2\1X\2\t€-\2\0\0009\2\f\2\v\2\0\0X\2\5€9\2\17\1\15\0\2\0X\3\2€9\2\17\1B\2\1\1K\0\1\0\0À\ntable\nsetup\vmodule\npairs\17dependencies\rfunction\vconfig\ttype\tWARN\vlevels\blog5module: %s not found, make sure it is installed.\vformat\vstring\vnotify\bvim\tname\frequire\npcall\0" },
    loaded = true,
    path = "/home/wipsel/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/home/wipsel/.local/share/nvim/site/pack/packer/start/nvim-web-devicons",
    url = "https://github.com/nvim-tree/nvim-web-devicons"
  },
  ["onedark.nvim"] = {
    loaded = true,
    path = "/home/wipsel/.local/share/nvim/site/pack/packer/start/onedark.nvim",
    url = "https://github.com/navarasu/onedark.nvim"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/home/wipsel/.local/share/nvim/site/pack/packer/start/plenary.nvim",
    url = "https://github.com/nvim-lua/plenary.nvim"
  },
  sonokai = {
    loaded = true,
    path = "/home/wipsel/.local/share/nvim/site/pack/packer/start/sonokai",
    url = "https://github.com/sainnhe/sonokai"
  },
  ["telescope.nvim"] = {
    config = { "\27LJ\2\n™\4\0\0\16\1\19\0Z6\0\0\0006\2\1\0-\3\0\0009\3\2\3B\0\3\3\14\0\0\0X\2\14€6\2\3\0009\2\4\0026\4\5\0009\4\6\4'\6\a\0-\a\0\0009\a\2\aB\4\3\0026\5\3\0009\5\b\0059\5\t\0059\5\n\5B\2\3\1K\0\1\0006\2\v\0-\4\0\0009\4\f\4B\2\2\2\a\2\r\0X\2*€4\2\0\0-\3\0\0009\3\14\3\15\0\3\0X\4\29€6\3\15\0-\5\0\0009\5\14\5B\3\2\4H\6\22€6\b\0\0006\n\1\0009\v\16\aB\b\3\3\14\0\b\0X\n\14€6\n\3\0009\n\4\n6\f\5\0009\f\6\f'\14\a\0-\15\0\0009\15\2\15B\f\3\0026\r\3\0009\r\b\r9\r\t\r9\r\n\rB\n\3\1K\0\1\0009\n\2\a<\t\n\2F\6\3\3R\6è\1279\3\17\1-\5\0\0009\5\f\5\18\a\1\0\18\b\2\0B\5\3\0A\3\0\1X\2\20€6\2\v\0-\4\0\0009\4\f\4B\2\2\2\a\2\18\0X\2\5€9\2\17\1-\4\0\0009\4\f\4B\2\2\1X\2\t€-\2\0\0009\2\f\2\v\2\0\0X\2\5€9\2\17\1\15\0\2\0X\3\2€9\2\17\1B\2\1\1K\0\1\0\0À\ntable\nsetup\vmodule\npairs\17dependencies\rfunction\vconfig\ttype\tWARN\vlevels\blog5module: %s not found, make sure it is installed.\vformat\vstring\vnotify\bvim\tname\frequire\npcall\0" },
    loaded = true,
    path = "/home/wipsel/.local/share/nvim/site/pack/packer/start/telescope.nvim",
    url = "https://github.com/nvim-telescope/telescope.nvim"
  }
}

time([[Defining packer_plugins]], false)
-- Config for: bufferline.nvim
time([[Config for bufferline.nvim]], true)
try_loadstring("\27LJ\2\n™\4\0\0\16\1\19\0Z6\0\0\0006\2\1\0-\3\0\0009\3\2\3B\0\3\3\14\0\0\0X\2\14€6\2\3\0009\2\4\0026\4\5\0009\4\6\4'\6\a\0-\a\0\0009\a\2\aB\4\3\0026\5\3\0009\5\b\0059\5\t\0059\5\n\5B\2\3\1K\0\1\0006\2\v\0-\4\0\0009\4\f\4B\2\2\2\a\2\r\0X\2*€4\2\0\0-\3\0\0009\3\14\3\15\0\3\0X\4\29€6\3\15\0-\5\0\0009\5\14\5B\3\2\4H\6\22€6\b\0\0006\n\1\0009\v\16\aB\b\3\3\14\0\b\0X\n\14€6\n\3\0009\n\4\n6\f\5\0009\f\6\f'\14\a\0-\15\0\0009\15\2\15B\f\3\0026\r\3\0009\r\b\r9\r\t\r9\r\n\rB\n\3\1K\0\1\0009\n\2\a<\t\n\2F\6\3\3R\6è\1279\3\17\1-\5\0\0009\5\f\5\18\a\1\0\18\b\2\0B\5\3\0A\3\0\1X\2\20€6\2\v\0-\4\0\0009\4\f\4B\2\2\2\a\2\18\0X\2\5€9\2\17\1-\4\0\0009\4\f\4B\2\2\1X\2\t€-\2\0\0009\2\f\2\v\2\0\0X\2\5€9\2\17\1\15\0\2\0X\3\2€9\2\17\1B\2\1\1K\0\1\0\0À\ntable\nsetup\vmodule\npairs\17dependencies\rfunction\vconfig\ttype\tWARN\vlevels\blog5module: %s not found, make sure it is installed.\vformat\vstring\vnotify\bvim\tname\frequire\npcall\0", "config", "bufferline.nvim")
time([[Config for bufferline.nvim]], false)
-- Config for: nvim-tree.lua
time([[Config for nvim-tree.lua]], true)
try_loadstring("\27LJ\2\n™\4\0\0\16\1\19\0Z6\0\0\0006\2\1\0-\3\0\0009\3\2\3B\0\3\3\14\0\0\0X\2\14€6\2\3\0009\2\4\0026\4\5\0009\4\6\4'\6\a\0-\a\0\0009\a\2\aB\4\3\0026\5\3\0009\5\b\0059\5\t\0059\5\n\5B\2\3\1K\0\1\0006\2\v\0-\4\0\0009\4\f\4B\2\2\2\a\2\r\0X\2*€4\2\0\0-\3\0\0009\3\14\3\15\0\3\0X\4\29€6\3\15\0-\5\0\0009\5\14\5B\3\2\4H\6\22€6\b\0\0006\n\1\0009\v\16\aB\b\3\3\14\0\b\0X\n\14€6\n\3\0009\n\4\n6\f\5\0009\f\6\f'\14\a\0-\15\0\0009\15\2\15B\f\3\0026\r\3\0009\r\b\r9\r\t\r9\r\n\rB\n\3\1K\0\1\0009\n\2\a<\t\n\2F\6\3\3R\6è\1279\3\17\1-\5\0\0009\5\f\5\18\a\1\0\18\b\2\0B\5\3\0A\3\0\1X\2\20€6\2\v\0-\4\0\0009\4\f\4B\2\2\2\a\2\18\0X\2\5€9\2\17\1-\4\0\0009\4\f\4B\2\2\1X\2\t€-\2\0\0009\2\f\2\v\2\0\0X\2\5€9\2\17\1\15\0\2\0X\3\2€9\2\17\1B\2\1\1K\0\1\0\0À\ntable\nsetup\vmodule\npairs\17dependencies\rfunction\vconfig\ttype\tWARN\vlevels\blog5module: %s not found, make sure it is installed.\vformat\vstring\vnotify\bvim\tname\frequire\npcall\0", "config", "nvim-tree.lua")
time([[Config for nvim-tree.lua]], false)
-- Config for: telescope.nvim
time([[Config for telescope.nvim]], true)
try_loadstring("\27LJ\2\n™\4\0\0\16\1\19\0Z6\0\0\0006\2\1\0-\3\0\0009\3\2\3B\0\3\3\14\0\0\0X\2\14€6\2\3\0009\2\4\0026\4\5\0009\4\6\4'\6\a\0-\a\0\0009\a\2\aB\4\3\0026\5\3\0009\5\b\0059\5\t\0059\5\n\5B\2\3\1K\0\1\0006\2\v\0-\4\0\0009\4\f\4B\2\2\2\a\2\r\0X\2*€4\2\0\0-\3\0\0009\3\14\3\15\0\3\0X\4\29€6\3\15\0-\5\0\0009\5\14\5B\3\2\4H\6\22€6\b\0\0006\n\1\0009\v\16\aB\b\3\3\14\0\b\0X\n\14€6\n\3\0009\n\4\n6\f\5\0009\f\6\f'\14\a\0-\15\0\0009\15\2\15B\f\3\0026\r\3\0009\r\b\r9\r\t\r9\r\n\rB\n\3\1K\0\1\0009\n\2\a<\t\n\2F\6\3\3R\6è\1279\3\17\1-\5\0\0009\5\f\5\18\a\1\0\18\b\2\0B\5\3\0A\3\0\1X\2\20€6\2\v\0-\4\0\0009\4\f\4B\2\2\2\a\2\18\0X\2\5€9\2\17\1-\4\0\0009\4\f\4B\2\2\1X\2\t€-\2\0\0009\2\f\2\v\2\0\0X\2\5€9\2\17\1\15\0\2\0X\3\2€9\2\17\1B\2\1\1K\0\1\0\0À\ntable\nsetup\vmodule\npairs\17dependencies\rfunction\vconfig\ttype\tWARN\vlevels\blog5module: %s not found, make sure it is installed.\vformat\vstring\vnotify\bvim\tname\frequire\npcall\0", "config", "telescope.nvim")
time([[Config for telescope.nvim]], false)
-- Config for: nvim-treesitter
time([[Config for nvim-treesitter]], true)
try_loadstring("\27LJ\2\n™\4\0\0\16\1\19\0Z6\0\0\0006\2\1\0-\3\0\0009\3\2\3B\0\3\3\14\0\0\0X\2\14€6\2\3\0009\2\4\0026\4\5\0009\4\6\4'\6\a\0-\a\0\0009\a\2\aB\4\3\0026\5\3\0009\5\b\0059\5\t\0059\5\n\5B\2\3\1K\0\1\0006\2\v\0-\4\0\0009\4\f\4B\2\2\2\a\2\r\0X\2*€4\2\0\0-\3\0\0009\3\14\3\15\0\3\0X\4\29€6\3\15\0-\5\0\0009\5\14\5B\3\2\4H\6\22€6\b\0\0006\n\1\0009\v\16\aB\b\3\3\14\0\b\0X\n\14€6\n\3\0009\n\4\n6\f\5\0009\f\6\f'\14\a\0-\15\0\0009\15\2\15B\f\3\0026\r\3\0009\r\b\r9\r\t\r9\r\n\rB\n\3\1K\0\1\0009\n\2\a<\t\n\2F\6\3\3R\6è\1279\3\17\1-\5\0\0009\5\f\5\18\a\1\0\18\b\2\0B\5\3\0A\3\0\1X\2\20€6\2\v\0-\4\0\0009\4\f\4B\2\2\2\a\2\18\0X\2\5€9\2\17\1-\4\0\0009\4\f\4B\2\2\1X\2\t€-\2\0\0009\2\f\2\v\2\0\0X\2\5€9\2\17\1\15\0\2\0X\3\2€9\2\17\1B\2\1\1K\0\1\0\0À\ntable\nsetup\vmodule\npairs\17dependencies\rfunction\vconfig\ttype\tWARN\vlevels\blog5module: %s not found, make sure it is installed.\vformat\vstring\vnotify\bvim\tname\frequire\npcall\0", "config", "nvim-treesitter")
time([[Config for nvim-treesitter]], false)
-- Config for: git-conflict.nvim
time([[Config for git-conflict.nvim]], true)
try_loadstring("\27LJ\2\n™\4\0\0\16\1\19\0Z6\0\0\0006\2\1\0-\3\0\0009\3\2\3B\0\3\3\14\0\0\0X\2\14€6\2\3\0009\2\4\0026\4\5\0009\4\6\4'\6\a\0-\a\0\0009\a\2\aB\4\3\0026\5\3\0009\5\b\0059\5\t\0059\5\n\5B\2\3\1K\0\1\0006\2\v\0-\4\0\0009\4\f\4B\2\2\2\a\2\r\0X\2*€4\2\0\0-\3\0\0009\3\14\3\15\0\3\0X\4\29€6\3\15\0-\5\0\0009\5\14\5B\3\2\4H\6\22€6\b\0\0006\n\1\0009\v\16\aB\b\3\3\14\0\b\0X\n\14€6\n\3\0009\n\4\n6\f\5\0009\f\6\f'\14\a\0-\15\0\0009\15\2\15B\f\3\0026\r\3\0009\r\b\r9\r\t\r9\r\n\rB\n\3\1K\0\1\0009\n\2\a<\t\n\2F\6\3\3R\6è\1279\3\17\1-\5\0\0009\5\f\5\18\a\1\0\18\b\2\0B\5\3\0A\3\0\1X\2\20€6\2\v\0-\4\0\0009\4\f\4B\2\2\2\a\2\18\0X\2\5€9\2\17\1-\4\0\0009\4\f\4B\2\2\1X\2\t€-\2\0\0009\2\f\2\v\2\0\0X\2\5€9\2\17\1\15\0\2\0X\3\2€9\2\17\1B\2\1\1K\0\1\0\0À\ntable\nsetup\vmodule\npairs\17dependencies\rfunction\vconfig\ttype\tWARN\vlevels\blog5module: %s not found, make sure it is installed.\vformat\vstring\vnotify\bvim\tname\frequire\npcall\0", "config", "git-conflict.nvim")
time([[Config for git-conflict.nvim]], false)
-- Config for: null-ls.nvim
time([[Config for null-ls.nvim]], true)
try_loadstring("\27LJ\2\n™\4\0\0\16\1\19\0Z6\0\0\0006\2\1\0-\3\0\0009\3\2\3B\0\3\3\14\0\0\0X\2\14€6\2\3\0009\2\4\0026\4\5\0009\4\6\4'\6\a\0-\a\0\0009\a\2\aB\4\3\0026\5\3\0009\5\b\0059\5\t\0059\5\n\5B\2\3\1K\0\1\0006\2\v\0-\4\0\0009\4\f\4B\2\2\2\a\2\r\0X\2*€4\2\0\0-\3\0\0009\3\14\3\15\0\3\0X\4\29€6\3\15\0-\5\0\0009\5\14\5B\3\2\4H\6\22€6\b\0\0006\n\1\0009\v\16\aB\b\3\3\14\0\b\0X\n\14€6\n\3\0009\n\4\n6\f\5\0009\f\6\f'\14\a\0-\15\0\0009\15\2\15B\f\3\0026\r\3\0009\r\b\r9\r\t\r9\r\n\rB\n\3\1K\0\1\0009\n\2\a<\t\n\2F\6\3\3R\6è\1279\3\17\1-\5\0\0009\5\f\5\18\a\1\0\18\b\2\0B\5\3\0A\3\0\1X\2\20€6\2\v\0-\4\0\0009\4\f\4B\2\2\2\a\2\18\0X\2\5€9\2\17\1-\4\0\0009\4\f\4B\2\2\1X\2\t€-\2\0\0009\2\f\2\v\2\0\0X\2\5€9\2\17\1\15\0\2\0X\3\2€9\2\17\1B\2\1\1K\0\1\0\0À\ntable\nsetup\vmodule\npairs\17dependencies\rfunction\vconfig\ttype\tWARN\vlevels\blog5module: %s not found, make sure it is installed.\vformat\vstring\vnotify\bvim\tname\frequire\npcall\0", "config", "null-ls.nvim")
time([[Config for null-ls.nvim]], false)
-- Config for: gitsigns.nvim
time([[Config for gitsigns.nvim]], true)
try_loadstring("\27LJ\2\n™\4\0\0\16\1\19\0Z6\0\0\0006\2\1\0-\3\0\0009\3\2\3B\0\3\3\14\0\0\0X\2\14€6\2\3\0009\2\4\0026\4\5\0009\4\6\4'\6\a\0-\a\0\0009\a\2\aB\4\3\0026\5\3\0009\5\b\0059\5\t\0059\5\n\5B\2\3\1K\0\1\0006\2\v\0-\4\0\0009\4\f\4B\2\2\2\a\2\r\0X\2*€4\2\0\0-\3\0\0009\3\14\3\15\0\3\0X\4\29€6\3\15\0-\5\0\0009\5\14\5B\3\2\4H\6\22€6\b\0\0006\n\1\0009\v\16\aB\b\3\3\14\0\b\0X\n\14€6\n\3\0009\n\4\n6\f\5\0009\f\6\f'\14\a\0-\15\0\0009\15\2\15B\f\3\0026\r\3\0009\r\b\r9\r\t\r9\r\n\rB\n\3\1K\0\1\0009\n\2\a<\t\n\2F\6\3\3R\6è\1279\3\17\1-\5\0\0009\5\f\5\18\a\1\0\18\b\2\0B\5\3\0A\3\0\1X\2\20€6\2\v\0-\4\0\0009\4\f\4B\2\2\2\a\2\18\0X\2\5€9\2\17\1-\4\0\0009\4\f\4B\2\2\1X\2\t€-\2\0\0009\2\f\2\v\2\0\0X\2\5€9\2\17\1\15\0\2\0X\3\2€9\2\17\1B\2\1\1K\0\1\0\0À\ntable\nsetup\vmodule\npairs\17dependencies\rfunction\vconfig\ttype\tWARN\vlevels\blog5module: %s not found, make sure it is installed.\vformat\vstring\vnotify\bvim\tname\frequire\npcall\0", "config", "gitsigns.nvim")
time([[Config for gitsigns.nvim]], false)
-- Config for: nvim-lspconfig
time([[Config for nvim-lspconfig]], true)
try_loadstring("\27LJ\2\n™\4\0\0\16\1\19\0Z6\0\0\0006\2\1\0-\3\0\0009\3\2\3B\0\3\3\14\0\0\0X\2\14€6\2\3\0009\2\4\0026\4\5\0009\4\6\4'\6\a\0-\a\0\0009\a\2\aB\4\3\0026\5\3\0009\5\b\0059\5\t\0059\5\n\5B\2\3\1K\0\1\0006\2\v\0-\4\0\0009\4\f\4B\2\2\2\a\2\r\0X\2*€4\2\0\0-\3\0\0009\3\14\3\15\0\3\0X\4\29€6\3\15\0-\5\0\0009\5\14\5B\3\2\4H\6\22€6\b\0\0006\n\1\0009\v\16\aB\b\3\3\14\0\b\0X\n\14€6\n\3\0009\n\4\n6\f\5\0009\f\6\f'\14\a\0-\15\0\0009\15\2\15B\f\3\0026\r\3\0009\r\b\r9\r\t\r9\r\n\rB\n\3\1K\0\1\0009\n\2\a<\t\n\2F\6\3\3R\6è\1279\3\17\1-\5\0\0009\5\f\5\18\a\1\0\18\b\2\0B\5\3\0A\3\0\1X\2\20€6\2\v\0-\4\0\0009\4\f\4B\2\2\2\a\2\18\0X\2\5€9\2\17\1-\4\0\0009\4\f\4B\2\2\1X\2\t€-\2\0\0009\2\f\2\v\2\0\0X\2\5€9\2\17\1\15\0\2\0X\3\2€9\2\17\1B\2\1\1K\0\1\0\0À\ntable\nsetup\vmodule\npairs\17dependencies\rfunction\vconfig\ttype\tWARN\vlevels\blog5module: %s not found, make sure it is installed.\vformat\vstring\vnotify\bvim\tname\frequire\npcall\0", "config", "nvim-lspconfig")
time([[Config for nvim-lspconfig]], false)
-- Config for: lualine.nvim
time([[Config for lualine.nvim]], true)
try_loadstring("\27LJ\2\n™\4\0\0\16\1\19\0Z6\0\0\0006\2\1\0-\3\0\0009\3\2\3B\0\3\3\14\0\0\0X\2\14€6\2\3\0009\2\4\0026\4\5\0009\4\6\4'\6\a\0-\a\0\0009\a\2\aB\4\3\0026\5\3\0009\5\b\0059\5\t\0059\5\n\5B\2\3\1K\0\1\0006\2\v\0-\4\0\0009\4\f\4B\2\2\2\a\2\r\0X\2*€4\2\0\0-\3\0\0009\3\14\3\15\0\3\0X\4\29€6\3\15\0-\5\0\0009\5\14\5B\3\2\4H\6\22€6\b\0\0006\n\1\0009\v\16\aB\b\3\3\14\0\b\0X\n\14€6\n\3\0009\n\4\n6\f\5\0009\f\6\f'\14\a\0-\15\0\0009\15\2\15B\f\3\0026\r\3\0009\r\b\r9\r\t\r9\r\n\rB\n\3\1K\0\1\0009\n\2\a<\t\n\2F\6\3\3R\6è\1279\3\17\1-\5\0\0009\5\f\5\18\a\1\0\18\b\2\0B\5\3\0A\3\0\1X\2\20€6\2\v\0-\4\0\0009\4\f\4B\2\2\2\a\2\18\0X\2\5€9\2\17\1-\4\0\0009\4\f\4B\2\2\1X\2\t€-\2\0\0009\2\f\2\v\2\0\0X\2\5€9\2\17\1\15\0\2\0X\3\2€9\2\17\1B\2\1\1K\0\1\0\0À\ntable\nsetup\vmodule\npairs\17dependencies\rfunction\vconfig\ttype\tWARN\vlevels\blog5module: %s not found, make sure it is installed.\vformat\vstring\vnotify\bvim\tname\frequire\npcall\0", "config", "lualine.nvim")
time([[Config for lualine.nvim]], false)

_G._packer.inside_compile = false
if _G._packer.needs_bufread == true then
  vim.cmd("doautocmd BufRead")
end
_G._packer.needs_bufread = false

if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
