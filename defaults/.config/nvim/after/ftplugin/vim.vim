" File:vim.vim
"	Description:	ftplugin for the vim filetype
" Author:Reinaldo Molina <rmolin88@gmail.com>
" Version:1.0.0
" Last Modified: Sat Jun 03 2017 19:11
" Created: Apr 28 2017 15:41

" Only do this when not done yet for this buffer
if exists('b:did_vim_ftplugin')
	finish
endif
" Don't load another plugin for this buffer
let b:did_vim_ftplugin = 1

let s:keepcpo= &cpo
set cpo&vim

setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal nospell

" Add mappings, unless the user didn't want this.
if !exists('no_plugin_maps') && !exists('no_vim_maps')
	" Quote text by inserting "> "
	nnoremap <buffer> <plug>make_file :so %<cr>
	nnoremap <buffer> <plug>make_project :so %<cr>
	" Echo highlighted text
	vnoremap <buffer> <localleader>e y:echomsg <c-r>"<cr>
	" Evaluate highlighted text
	vnoremap <buffer> <localleader>E y:<c-r>"<cr>
endif

let b:undo_ftplugin = 'setlocal tabstop<'
      \ . '|setlocal shiftwidth<'
      \ . '|setlocal softtabstop<'
      \ . '|setlocal nospell<'

let &cpo = s:keepcpo
unlet s:keepcpo
