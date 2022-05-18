---@module lua after ftplugin
---@author Reinaldo Molina

if vim.b.did_lua_ftplugin then
  return
end

vim.b.did_lua_ftplugin = 1

vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2
vim.opt_local.tabstop = 2

-- In Order For gf To Work
vim.opt_local.suffixesadd:prepend('.lua')
vim.opt_local.suffixesadd:prepend('init.lua')
vim.opt_local.path:prepend(vim.fn.stdpath('config')..'/lua')

vim.cmd[[
  vnoremap <buffer> <localleader>e y:echomsg <c-r>"<cr>
  nnoremap <buffer> <plug>make_file :so %<cr>
  nnoremap <buffer> <plug>make_project :so %<cr>
  " Evaluate highlighted text
  vnoremap <buffer> <localleader>E y:<c-r>"<cr>
]]
