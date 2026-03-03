---@module markdown after ftplugin
---@author Reinaldo Molina

if vim.b.did_markdown_ftplugin then
  return
end

vim.b.did_markdown_ftplugin = 1

local M = { opersistance = '' }

local u = require('utils.utils')

local preview = function()
  if M.opersistance == '' then
    vim.notify('No file rendered yet', vim.log.levels.WARN)
    return
  end
  vim.ui.open(M.opersistance)
end

---Maps a format key to its output extension and pandoc arguments
local _formats = {
  html = { ext = 'html', args = { '--embed-resources', '--standalone' } },
  revealjs = {
    ext = 'html',
    args = { '-t', 'revealjs', '--embed-resources', '--standalone' },
  },
  pptx = { ext = 'pptx', args = {} },
  pdf = { ext = 'pdf', args = { '--pdf-engine=xelatex' } },
  docx = { ext = 'docx', args = {} },
}

local render = function(format)
  local fmt = _formats[format]
  if not fmt then
    vim.notify('Unknown format: ' .. tostring(format), vim.log.levels.ERROR)
    return
  end
  local f = vim.fn.expand('%:p')
  local out = vim.fn.expand('%:p:r') .. '.' .. fmt.ext
  M.opersistance = out
  local cmd = { 'pandoc', f }
  vim.list_extend(cmd, fmt.args)
  vim.list_extend(cmd, { '-o', out })
  vim.print(vim.inspect(cmd))
  vim.system(cmd, { detach = true })
end

if vim.g.no_plugin_maps == nil and vim.g.no_markdown_maps == nil then
  local vks = vim.keymap.set
  vks('n', '<localleader>mk', function()
    render('html')
  end, { desc = 'pandoc-render-html', buffer = true })
  vks('n', '<localleader>mp', function()
    render('revealjs')
  end, { desc = 'pandoc-render-revealjs', buffer = true })
  vks('n', '<localleader>mw', function()
    render('pptx')
  end, { desc = 'pandoc-render-pptx', buffer = true })
  vks('n', '<localleader>mf', function()
    render('pdf')
  end, { desc = 'pandoc-render-pdf', buffer = true })
  vks('n', '<localleader>mx', function()
    render('docx')
  end, { desc = 'pandoc-render-docx', buffer = true })
  vks('n', '<plug>preview', preview, {
    desc = 'file_preview',
    buffer = true,
  })
end
