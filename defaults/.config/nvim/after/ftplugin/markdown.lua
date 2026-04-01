---@module markdown after ftplugin
---@author Reinaldo Molina

if vim.b.did_markdown_ftplugin then
  return
end

vim.b.did_markdown_ftplugin = 1

if vim.fn.executable('pandoc') > 0 then
  vim.cmd.compiler('pandoc')
  vim.keymap.set(
    'n',
    '<plug>make',
    '<cmd>make! html --embed-resources --standalone<cr>'
  )
  vim.keymap.set(
    'n',
    '<localleader>k',
    '<cmd>make! html -t revealjs --embed-resources --standalone<cr>'
  )
end
