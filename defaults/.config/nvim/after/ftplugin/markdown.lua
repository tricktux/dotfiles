---@module markdown after ftplugin
---@author Reinaldo Molina

if vim.b.did_markdown_ftplugin then
  return
end

vim.b.did_markdown_ftplugin = 1

local M = { opersistance = '' }

local output = function(filetype)
  return vim.fn.tempname() .. vim.fn.expand('%:t:r') .. filetype
end

local u = require('utils.utils')
local preview = function()
  u.browser.open_file_async(M.opersistance)
end

local _filetype = { 'html', 'docx', 'pdf' }
local function _validate_filetypes(filetype)
  return vim.tbl_contains(_filetype, filetype)
end

local _arguments = {
  html = { '--self-contained' },
  docx = {},
  pdf = { '--pdf-engine=xelatex' },
}

local render = function(filetype)
  vim.validate({
    filetype = { filetype, _validate_filetypes, 'one of: ' .. vim.inspect(_filetype) },
  })
  local f = vim.fn.expand('%:p')
  if not u.isfile(M.opersistance) then
    M.opersistance = output('.' .. filetype)
  end
  local o = { '-o', M.opersistance }
  local cmd = { 'pandoc', f }
  vim.list_extend(cmd, _arguments[filetype])
  vim.list_extend(cmd, o)
  vim.print(vim.inspect(cmd))
  vim.system(cmd, { detach = true })
end

if vim.g.no_plugin_maps == nil and vim.g.no_markdown_maps == nil then
  local vks = vim.keymap.set
  vks('n', '<plug>make_file', function()
    render('html')
  end, { desc = 'pandoc-render-html', buffer = true })
  vks('n', '<plug>preview', preview, { desc = 'file_preview', buffer = true })
end
