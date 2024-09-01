---@module rust after ftplugin
---@author Reinaldo Molina
if vim.b.did_rust_ftplugin then
  return
end

vim.b.did_rust_ftplugin = 1
local vks = vim.keymap.set

vks('n', '<plug>make_file', '<cmd>RustRun<cr>', { desc = 'make_file' })
