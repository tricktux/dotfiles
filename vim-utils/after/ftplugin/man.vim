" File:					man.vim
" Description:			Customizations for man pages
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:				0.0.0
" Last Modified: Jun 25 2017 09:09
" Created: Jun 25 2017 09:09

" Only do this when not done yet for this buffer
if exists("b:did_man_ftplugin")
	finish
endif

" Don't load another plugin for this buffer
let b:did_man_ftplugin = 1

if !exists("no_plugin_maps") && !exists("no_man_maps")
	nnoremap <buffer> gt K
	nnoremap <buffer> q ZZ
endif

