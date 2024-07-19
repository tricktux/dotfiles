---@module quarto (qmd) after ftplugin
---@author Reinaldo Molina

if vim.b.did_quarto_ftplugin then
  return
end

vim.b.did_quarto_ftplugin = 1

vim.opt_local.formatoptions:append('t')
vim.opt_local.textwidth = 100
local u = require('utils.utils')

local preview = function()
  local o = vim.fn.expand('%:p:r') .. '.html'
  u.browser.open_file_async(o)
end

local _filetype = { 'html', 'docx', 'pdf' }
local function _validate_filetypes(filetype)
  return vim.tbl_contains(_filetype, filetype)
end

local render = function(filetype)
  vim.validate({
    filetype = { filetype, _validate_filetypes, 'one of: ' .. vim.inspect(_filetype) },
  })
  local filename = vim.fn.expand('%:p')
  local cmd = { 'quarto', 'render', filename, '--to', filetype }
  u.term.exec(cmd)
end

if vim.g.no_plugin_maps == nil and vim.g.no_quarto_maps == nil then
  local vks = vim.keymap.set
  if vim.fn.executable('quarto') > 0 then
    vks('n', '<plug>preview', preview, { desc = 'quarto-preview' })
    vks('n', '<plug>make_file', function()
      render('html')
    end, { desc = 'quarto-render-html' })
  else
    vim.api.nvim_err_writeln(
      'Quarto not found. Install it with: `paru -Syu quarto-cli-bin` or npm install -g @quarto/cli'
    )
  end
end
