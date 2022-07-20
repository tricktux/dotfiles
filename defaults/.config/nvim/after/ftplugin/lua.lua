---@module lua after ftplugin
---@author Reinaldo Molina

if vim.b.did_lua_ftplugin then
  return
end

vim.b.did_lua_ftplugin = 1

vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2

-- In Order For gf To Work
vim.opt_local.suffixesadd:prepend('.lua')
vim.opt_local.suffixesadd:prepend('init.lua')
vim.opt_local.path:prepend(vim.fn.stdpath('config')..'/lua')

local map = require("config.mappings")
local maps = {}
maps.opts = {silent = true, buffer = 0}
maps.mappings = {
  ["<localleader>e"] = {"y<cmd>lua print(<c-r>\")<cr>", "lua_print_selection", "v"},
  ["<plug>make_file"] = {"<cmd>so %<cr>", "source_file"},
  ["<localleader>E"] = {"y<cmd>lua <c-r>\"<cr>", "lua_eval_selection", "v"},
}

map:keymaps_sets(maps)
