---@module vim after ftplugin
---@author Reinaldo Molina

if vim.b.did_vim_ftplugin then
  return
end

vim.b.did_vim_ftplugin = 1

vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2

vim.cmd[[
  " Quote text by inserting "> "
  nnoremap <buffer> <plug>make_file :so %<cr>
  nnoremap <buffer> <plug>make_project :so %<cr>
  " Echo highlighted text
  vnoremap <buffer> <localleader>e y:echomsg <c-r>"<cr>
  " Evaluate highlighted text
  vnoremap <buffer> <localleader>E y:<c-r>"<cr>
]]
