---@module c after ftplugin
---@author Reinaldo Molina
if vim.b.did_cpp_ftplugin then
  return
end

vim.b.did_cpp_ftplugin = 1
local fmt = string.format
local fn = vim.fn
local vks = vim.keymap.set
local log = require('utils.log')
local u = require('utils.utils')

local function repl()
  local comp = nil
  if fn.executable('clang++') > 0 then
    comp = 'clang++'
  elseif fn.executable('g++') > 0 then
    comp = 'g++'
  else
    vim.notify('[cpp.repl]: no compiler available', vim.log.levels.ERROR)
    return
  end

  local out = fn.tempname()
  local exec_out = fn.has('unix') > 0 and out or out .. '.exe'
  local filename = fn.expand('%')
  local cmd = fn.shellescape(fmt('%s %s -g -O3 -o %s && %s', comp, filename, out, exec_out))
  log.info(fmt('repl.cpp.cmd = %s', cmd))
  u.term.exec(cmd)
end

local o = { desc = 'terminal_send_file' }
vks('n', '<plug>terminal_send_file', repl, o)
vks('n', '<plug>make_file', '<cmd>make<cr>', { desc = 'make_file' })

-- Debugging
vks('n', '<plug>debug_start', function()
  require('plugin.termdebug').debug_start()
end, { desc = 'start_debug' })
