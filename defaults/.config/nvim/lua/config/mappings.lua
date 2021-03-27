local map = require('utils/keymap')
local api = vim.api
local utl = require('utils/utils')


local function refresh_buffer()
  api.nvim_exec([[
    nohlsearch
    diffupdate
    mode
    syntax sync fromstart
    edit
    normal! zz<cr>
  ]], true)

  if vim.fn.exists(':SignifyRefresh') > 0 then
    vim.cmd('SignifyRefresh')
  end

  if utl.is_mod_available('gitsigns') then
    require"gitsigns".reset_buffer()
  end

  local lsp_clients = vim.lsp.buf_get_clients()
  if #lsp_clients == 0 then
    return
  end
  -- print(vim.inspect(lsp_clients))
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
