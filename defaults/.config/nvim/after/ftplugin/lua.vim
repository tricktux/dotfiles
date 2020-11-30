
" Only do this when not done yet for this buffer
if exists('b:did_lua_ftplugin')
  finish
endif

" Don't load another plugin for this buffer
let b:did_lua_ftplugin = 1

let s:keepcpo= &cpo
set cpo&vim

setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal nospell
setlocal textwidth=79

let &cpo = s:keepcpo
unlet s:keepcpo

" Add mappings, unless the user didn't want this.
if !exists('no_plugin_maps') && !exists('no_lua_maps')
  " Quote text by inserting "> "
  nnoremap <buffer> <plug>make_file :luafile %<cr>
  nnoremap <buffer> <plug>make_project :luafile %<cr>
endif

let b:undo_ftplugin = 'setlocal tabstop<'
      \ . '|setlocal shiftwidth<'
      \ . '|setlocal softtabstop<'
      \ . '|setlocal nospell<'
      \ . '|setlocal textwidth<'
