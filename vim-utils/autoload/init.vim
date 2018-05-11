" File:					init.vim
" Description:	Main file that call configuration functions
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:				0.0.0
" Last Modified: Aug 21 2017 16:15
" Created: Aug 21 2017 16:15

function! init#vim() abort
	" Needs to be defined before the first <Leader>/<LocalLeader> is used
	" otherwise it goes to "\"
	let g:mapleader="\<Space>"
	let g:maplocalleader="g"
	" Mon Oct 30 2017 15:24: Patched fonts depend on this option. It also needs
	" to be here. Otherwise Alt mappings stop working
	set encoding=utf-8

	" OS_SETTINGS
	if  has('unix')
		call unix#Config()
	else
		call win32#Config()
	endif

	" PLUGINS_INIT
	if plugin#Config()
		let g:loaded_plugins = 1
	else
		echomsg 'No plugins were loaded'
	endif

	" Create required folders for storing usage data
	call utils#CheckDirWoPrompt(g:std_data_path . '/sessions')
	call utils#CheckDirWoPrompt(g:std_data_path . '/ctags')
	if has('persistent_undo')
		let g:undofiles_path = g:std_cache_path . '/undofiles'
		call utils#CheckDirWoPrompt(g:undofiles_path)
	endif

	call mappings#Set()
	call options#Set()
	call augroup#Set()
	call commands#Set()
	call syntax#Set()
endfunction

" vim:tw=78:ts=2:sts=2:sw=2:
