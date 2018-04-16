" File:					plantuml.vim
" Description:	mappings and settings for uml files
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:				0.0.0
" Last Modified: Oct 18 2017 21:11
" Created: Oct 18 2017 21:11

" Only do this when not done yet for this buffer
if exists("b:did_uml_ftplugin")
	finish
endif

" Don't load another plugin for this buffer
let b:did_uml_ftplugin = 1


if !exists('no_plugin_maps') && !exists('no_uml_maps')
	" Make and reload image preview
	" nnoremap <silent> <buffer> <Plug>Make :call neomake#Make({ 'file_mode' : 0 })<cr>
				" \:silent! !killall -s SIGHUP mupdf<CR>
	" nnoremap <buffer> <Plug>Preview :!mupdf %:r.png&<CR>
endif

