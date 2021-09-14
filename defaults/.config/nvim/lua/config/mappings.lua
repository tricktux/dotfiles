local map = require('utils.keymap')

local M = {}

function _G.tmux_move(direction)
  vim.validate {direction = {direction, 'string'}}

  local valid_dir = 'phjkl'
  if not (valid_dir):find(direction) then
    vim.api.nvim_err_writeln('tmux_move: direction: "' .. direction ' is not a valid"')
    return
  end

  local curr_win = vim.api.nvim_get_current_win()
  vim.fn.execute('wincmd ' .. direction)
  local new_win = vim.api.nvim_get_current_win()
  if new_win == curr_win then
    vim.fn.system('tmux select-pane -' .. vim.fn.tr(direction, valid_dir, 'lLDUR'))
  end
end

function M:window_movement_setup()
  if vim.fn.has('unix') > 0 and vim.fn.executable('tmux') > 0 and
      vim.fn.exists('$TMUX') > 0 then
      map.nnoremap('<A-h>', [[<cmd>call v:lua.tmux_move('h')<cr>]])
      map.nnoremap('<A-j>', [[<cmd>call v:lua.tmux_move('j')<cr>]])
      map.nnoremap('<A-k>', [[<cmd>call v:lua.tmux_move('k')<cr>]])
      map.nnoremap('<A-l>', [[<cmd>call v:lua.tmux_move('l')<cr>]])
      map.nnoremap('<A-p>', [[<cmd>call v:lua.tmux_move('p')<cr>]])
    return
  end

  map.nnoremap("<A-l>", "<C-w>lzz")
  map.nnoremap("<A-h>", "<C-w>hzz")
  map.nnoremap("<A-k>", "<C-w>kzz")
  map.nnoremap("<A-j>", "<C-w>jzz")
  map.nnoremap("<A-p>", "<C-w>pzz")
end

function M:setup()
  -- Awesome hack, typing a command is used way more often than next
  map.nnoremap(';', ':', {nowait = true, silent = true})
  map.vnoremap(';', ':', {nowait = true, silent = true})

  -- Let's make <s-v> consistent as well
  map.nnoremap('<s-v>', 'v$h')
  map.nnoremap('vv', '<s-v>')

  map.vnoremap('gA', 'g<c-a>')
  map.vnoremap('gX', 'g<c-x>')
  map.vnoremap(']f', 'gf')
  map.nnoremap(']f', 'gf')
  map.nnoremap(']i', '[<c-i>')
  map.nnoremap('[i', '[<c-i>')
  map.nnoremap(']I', '<c-w>i<c-w>L')
  map.nnoremap('[I', '<c-w>i<c-w>H')
  map.nnoremap(']e', '[<c-d>')
  map.nnoremap('[e', '[<c-d>')
  map.nnoremap(']E', '<c-w>d<c-w>L')
  map.nnoremap('[E', '<c-w>d<c-w>H')

  self:window_movement_setup()
  -- Window resizing
  map.nnoremap("<A-S-l>", "<C-w>>")
  map.nnoremap("<A-S-h>", "<C-w><")
  map.nnoremap("<A-S-k>", "<C-w>-")
  map.nnoremap("<A-S-j>", "<C-w>+")
end

return M
