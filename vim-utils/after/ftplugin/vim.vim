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

" Add mappings, unless the user didn't want this.
if !exists('no_plugin_maps') && !exists('no_vim_maps')
	" Quote text by inserting "> "
	nnoremap <buffer> <Plug>make_file :so %<cr>
	nnoremap <buffer> <Plug>make_project :so %<cr>
	nnoremap <buffer> <plug>help_under_cursor :h <c-r>=expand("<cword>")<CR><cr>
	" Echo highlighted text
	vnoremap <buffer> <LocalLeader>e y:echomsg <c-r>"<cr>
	" Evaluate highlighted text
	vnoremap <buffer> <LocalLeader>E y:<c-r>"<cr>
endif
