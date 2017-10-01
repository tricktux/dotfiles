
" File:					terminal.vim
"	Description:	Set mappings and settings proper of nvim-terminal
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:				1.0.0
" Last Modified: Apr 29 2017 19:26
" Created: Apr 29 2017 19:26

" Only do this when not done yet for this buffer
if exists("b:did_terminal_ftplugin")
	finish
endif

" Don't load another plugin for this buffer
let b:did_terminal_ftplugin = 1

" If plugin neoterm was loaded and mappings accepted
if !exists("no_plugin_maps") && !exists("no_terminal_maps")
	if exists('*neoterm#close()')
		" hide/close terminal
		nnoremap <buffer> <silent> <Leader>th :call neoterm#close()<cr>
	endif
endif
