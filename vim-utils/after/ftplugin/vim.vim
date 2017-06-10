" File:vim.vim
"	Description:	ftplugin for the vim filetype
" Author:Reinaldo Molina <rmolin88@gmail.com>
" Version:1.0.0
" Last Modified: Sat Jun 03 2017 19:11
" Created: Apr 28 2017 15:41

" Only do this when not done yet for this buffer
if exists("b:did_vim_ftplugin")
	finish
endif

" Don't load another plugin for this buffer
let b:did_vim_ftplugin = 1

" Add mappings, unless the user didn't want this.
if !exists("no_plugin_maps") && !exists("no_vim_maps")
	" Quote text by inserting "> "
	nnoremap <buffer> <Plug>Make :so %<CR>
	nnoremap <buffer> <unique> <Leader>lh :h <c-r>=expand("<cword>")<CR><cr>
	call ftplugin#Align('/"')
	" Evaluate highlighted text
	vnoremap <buffer> <Leader>le y:echomsg <c-r>"<cr>
	" Execute highlighted text
	vnoremap <buffer> <Leader>lE y:<c-r>"<cr>
endif
