" File:vim.vim
"	Description:	ftplugin for the vim filetype
" Author:Reinaldo Molina <rmolin88@gmail.com>
" Version:1.0.0
" Last Modified: Fri Apr 28 2017 16:43
" Created: Apr 28 2017 15:41

" Only do this when not done yet for this buffer
if exists("b:did_vim_ftplugin")
	finish
endif

" Don't load another plugin for this buffer
let b:did_vim_ftplugin = 1

" Add mappings, unless the user didn't want this.
if !exists("no_plugin_maps") && !exists("no_c_maps")
	" Quote text by inserting "> "
	if !hasmapto('<Plug>VimMake')
		nmap <buffer> <Leader>jk <Plug>VimMake
	endif
	nnoremap <buffer> <unique> <Plug>VimMake :so %<CR>
	nnoremap <buffer> <unique> <Leader>lh :h <c-r>=expand("<cword>")<CR><cr>
endif


