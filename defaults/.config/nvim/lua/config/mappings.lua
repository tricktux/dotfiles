local map = require('utils/keymap')
local utl = require('utils/utils')

local function setup_edit()
  -- map.nnoremap("<leader>ed" :call utils#PathFileFuzzer(g:dotfiles)<cr>)
  -- nnoremap <leader>eh :call utils#PathFileFuzzer($HOME)<cr>
  -- if (!has('unix'))
    -- nnoremap <leader>eC :call utils#PathFileFuzzer('C:\')<cr>
    -- nnoremap <leader>eD :call utils#PathFileFuzzer('D:\')<cr>
    -- nnoremap <leader>eP :e +<cr>
  -- endif
  -- nnoremap <leader>ec :call utils#PathFileFuzzer(getcwd())<cr>
  -- nnoremap <leader>el :call utils#PathFileFuzzer(input
        -- \ ('Folder to recurse: ', "", "file"))<cr>
end

return { setup_edit = setup_edit }
