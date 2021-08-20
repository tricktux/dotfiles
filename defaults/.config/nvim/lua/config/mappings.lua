local map = require('utils.keymap')

local function setup()
  -- Awesome hack, typing a command is used way more often than next
  map.nnoremap(';', ':', {nowait = true, silent = true})
  map.vnoremap(';', ':', {nowait = true, silent = true})

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
end

return {setup = setup}
