local M = {}

M.setup = function()
  local ok_comment = pcall(vim.cmd, 'packadd! comment')
  if ok_comment then
    map('n', '<bs>', 'gcc', { remap = true })
    map('x', '<bs>', 'gc', { remap = true })
  end

  vim.cmd('packadd nvim.undotree')
  vim.keymap.set(
    'n',
    '<leader>u',
    require('undotree').open,
    { desc = 'undotree-open' }
  )
end

return M
