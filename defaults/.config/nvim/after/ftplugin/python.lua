---@module python after ftplugin
---@author Reinaldo Molina

if vim.b.did_python_ftplugin then
  return
end

vim.b.did_python_ftplugin = 1

vim.opt_local.shiftwidth = 4
vim.opt_local.softtabstop = 4
vim.opt_local.tabstop = 4
