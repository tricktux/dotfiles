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

local function ewr() return require('plugin.report'):edit_weekly_report() end

local function ff(arg)
  vim.validate {arg = {arg, 's'}}
  return require('utils.utils').file_fuzzer(arg)
end

local function setup()
  if not utl.is_mod_available('vimp') then
    api.nvim_err_writeln("vimp was set, but module not found")
    return
  end

  local vimp = require('vimp')
  vimp.nnoremap('<c-l>', refresh_buffer)
  vimp.nnoremap([[<leader>wp]], ewr)

  vimp.nnoremap('<leader>eh', function() ff('$HOME') end)
  vimp.nnoremap('<leader>ev', function() ff('$VIMRUNTIME') end)
  vimp.nnoremap('<leader>eP', function() ff(vim.g.vim_plugins_path) end)
  local lua_plugins = vim.g.std_data_path .. [[/site/pack/packer]]
  vimp.nnoremap('<leader>ep', function() ff(lua_plugins) end)
  vimp.nnoremap('<leader>ec', function() ff(vim.fn.getcwd()) end)
  if not utl.has_unix() then
    vimp.nnoremap('<leader>eC', function() ff([[C:\]]) end)
    vimp.nnoremap('<leader>eD', function() ff([[D:\]]) end)
    vimp.nnoremap('<leader>ed', function() ff([[$APPDATA\dotfiles]]) end)
  else
    vimp.nnoremap('<leader>ed', function() ff(vim.g.dotfiles) end)
  end
end

return {setup = setup}
