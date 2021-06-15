local map = require('utils/keymap')
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

  if vim.fn.exists(':SignifyRefresh') > 0 then
    vim.cmd('SignifyRefresh')
  end

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
end

return { setup = setup }
