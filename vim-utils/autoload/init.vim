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
	execute 'call ' . (has('unix') ? 'unix#Config()' : 'win32#Config()')

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
	call s:set_syntax()
endfunction

function! s:set_syntax() abort
	" SYNTAX_OPTIONS
	" ft-java-syntax
	let g:java_highlight_java_lang_ids=1
	let g:java_highlight_functions='indent'
	let g:java_highlight_debug=1
	let g:java_space_errors=1
	let g:java_comment_strings=1
	hi javaParen ctermfg=blue guifg=#0000ff

	" ft-c-syntax
	let g:c_gnu = 1
	let g:c_ansi_constants = 1
	let g:c_ansi_typedefs = 1
	let g:c_minlines = 500
	" Breaks too often
	" let c_curly_error = 1
	" Automatically highlight doxygen when doing c, c++
	let g:load_doxygen_syntax=1

	" ft-markdown-syntax
	let g:markdown_fenced_languages= [ 'cpp', 'vim', 'dosini', 'wings_syntax' ]
	" This is handled now by Plug 'plasticboy/vim-markdown'
	let g:markdown_folding= 0

	" ft-python-syntax
	" This option also highlights erroneous whitespaces
	let g:python_highlight_all = 1

	" Man
	" let g:no_man_maps = 1
	let g:ft_man_folding_enable = 1

	" Never load netrw
	let g:loaded_netrw       = 1
	let g:loaded_netrwPlugin = 1

endfunction
