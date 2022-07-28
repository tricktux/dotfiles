---@module python after ftplugin
---@author Reinaldo Molina

if vim.b.did_python_ftplugin then
  return
end

vim.b.did_python_ftplugin = 1
local vks = vim.keymap.set
local utl = require('utils.utils')
local fn = vim.fn

vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4

local o = {silent = true, buffer = true, desc = 'terminal_send_file'}
local r = function()
  local filename = fn.expand("%")
  utl.term.exec(fmt("python %s", filename))
end
vks('n', '<plug>terminal_send_file', r, o)
