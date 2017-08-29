" File:					syntax.vim
" Description:			Customize vim's syntax highlights
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:				0.0.0
" Last Modified: Aug 26 2017 17:58
" Created: Aug 26 2017 17:58


function! syntax#Set() abort
	" SYNTAX_OPTIONS
	" ft-java-syntax
	let g:java_highlight_java_lang_ids=1
	let g:java_highlight_functions="indent"
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
