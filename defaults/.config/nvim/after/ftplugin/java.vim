" File:					java.vim
" Description:	After default ftplugin for java
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:			1.0.0
" Last Modified: Wed Apr 25 2018 15:26
" Created:			Wed Nov 30 2016 09:21

" Only do this when not done yet for this buffer
if exists("b:did_java_ftplugin")
	finish
endif

" Don't load another plugin for this buffer
let b:did_java_ftplugin = 1

if exists('*javacomplete#Complete')
	setlocal omnifunc=javacomplete#Complete
endif
setlocal foldenable

" Add mappings, unless the user didn't want this.
if !exists("no_plugin_maps") && !exists("no_java_maps")
	" Special mappings go here

	if exists("g:loaded_sortimport")
		nmap <buffer> <localleader>ii <Plug>JavaInsertImport
		nmap <buffer> <localleader>is <Plug>JavaSortImport
	endif
endif

" if !exists('b:neomake_java_enabled_makers')
	" let b:neomake_java_enabled_makers = []
	" " let b:neomake_java_enabled_makers += executable('mvn') ? [''] : []
" endif

let b:undo_ftplugin += "setl omnifunc< foldenable<"
