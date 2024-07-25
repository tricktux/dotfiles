---@module help after ftplugin
---@author Reinaldo Molina

if vim.b.did_help_ftplugin then
  return
end

vim.b.did_help_ftplugin = 1

vim.opt_local.relativenumber = true

local opts = { silent = true, buffer = true, desc = 'exit help' }
vim.keymap.set('n', [[q]], [[:helpc<cr>]], opts)
opts.desc = 'show sections'
vim.keymap.set('n', [[g0]], [[g0]], opts)
vim.keymap.set('n', [[K]], [[K]], opts)
