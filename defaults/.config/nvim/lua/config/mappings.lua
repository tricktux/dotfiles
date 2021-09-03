local map = require('utils.keymap')

local M = {}

function M:window_movement_setup()
  if vim.fn.exists('*Focus') > 0 and vim.fn.executable('i3-vim-nav') > 0 then
    -- " i3 integration
    map.nnoremap('<A-l>', '<cmd>call Focus("right", "l")<cr>')
    map.nnoremap('<A-h>', '<cmd>call Focus("left", "h")<cr>')
    map.nnoremap('<A-k>', '<cmd>call Focus("up", "k")<cr>')
    map.nnoremap('<A-j>', '<cmd>call Focus("down", "j")<cr>')
    return
  end

  if vim.fn.has('unix') > 0 and vim.fn.executable('tmux') > 0 and vim.fn.exists('$TMUX') > 0 then
    map.nnoremap('<A-h>', "<cmd>call <SID>tmux_move('h')<cr>")
    map.nnoremap('<A-j>', "<cmd>call <SID>tmux_move('j')<cr>")
    map.nnoremap('<A-k>', "<cmd>call <SID>tmux_move('k')<cr>")
    map.nnoremap('<A-l>', "<cmd>call <SID>tmux_move('l')<cr>")
    return
  end

  map.nnoremap("<A-l>", "<C-w>lzz")
  map.nnoremap("<A-h>", "<C-w>hzz")
  map.nnoremap("<A-k>", "<C-w>kzz")
  map.nnoremap("<A-j>", "<C-w>jzz")
end

function M:setup()
  -- Awesome hack, typing a command is used way more often than next
  map.nnoremap(';', ':', {nowait = true, silent = true})
  map.vnoremap(';', ':', {nowait = true, silent = true})

  -- Let's make <s-v> consistent as well
  map.nnoremap('<s-v>', 'v$h')
  map.nnoremap('<c-q>', '<s-v>')

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
