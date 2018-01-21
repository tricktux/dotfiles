" File:           sql.vim
" Description:    Custom settings for sql
" Author:		    Reinaldo Molina
" Email:          rmolin88 at gmail dot com
" Revision:	    <`4:0.0.0`>
" Created:        Sun Jan 21 2018 10:13
" Last Modified:  Sun Jan 21 2018 10:13

" Only do this when not done yet for this buffer
if exists('b:did_sql_ftplugin')
	finish
endif

" Don't load another plugin for this buffer
let b:did_sql_ftplugin = 1

if !exists('no_plugin_maps') && !exists('no_sql_maps')
	if exists(':TREPLSendLine') " if neoterm plugin available
		nnoremap <buffer> gS :TREPLSetTerm<CR>
		xnoremap <buffer> gl :TREPLSendSelection<CR>
		nnoremap <buffer> gl :TREPLSendLine<CR>
		nnoremap <buffer> gf :TREPLSendFile<CR>	
	endif
endif

" let b:undo_ftplugin = 'setl spell< spelllang< formatoptions< wrap< tw<'
