
if vim.b.did_cs_ftplugin then
  return
end

vim.b.did_cs_ftplugin = 1

vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4
vim.opt_local.textwidth = 100
