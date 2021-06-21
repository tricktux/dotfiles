local api = vim.api
local utl = require('utils/utils')

local function refresh_buffer()
  api.nvim_exec([[
    update
    nohlsearch
    diffupdate
    mode
    edit
    normal! zzze<cr>
  ]], false)

  if vim.fn.exists(':SignifyRefresh') > 0 then vim.cmd('SignifyRefresh') end

  if vim.fn.exists(':IndentBlanklineRefresh') > 0 then
    vim.cmd('IndentBlanklineRefresh')
  end
end

local function setup()
  if not utl.is_mod_available('vimp') then
    api.nvim_err_writeln("vimp was set, but module not found")
    return
  end

  local vimp = require('vimp')
  vimp.nnoremap('<c-l>', refresh_buffer)

  vimp.vnoremap('gA', 'g<c-a>')
  vimp.vnoremap('gX', 'g<c-x>')
  vimp.vnoremap(']f', 'gf')
  vimp.nnoremap(']f', 'gf')
  vimp.nnoremap(']i', '[<c-i>')
  vimp.nnoremap('[i', '[<c-i>')
  vimp.nnoremap(']I', '<c-w>i<c-w>L')
  vimp.nnoremap('[I', '<c-w>i<c-w>H')
  vimp.nnoremap(']e', '[<c-d>')
  vimp.nnoremap('[e', '[<c-d>')
  vimp.nnoremap(']E', '<c-w>d<c-w>L')
  vimp.nnoremap('[E', '<c-w>d<c-w>H')
end

return {setup = setup}
