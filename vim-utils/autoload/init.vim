" File:					init.vim
" Description:	Main file that call configuration functions
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:				0.0.0
" Last Modified: Aug 21 2017 16:15
" Created: Aug 21 2017 16:15

function! init#vim() abort
	" Req for vim
	if !has('nvim')
		set nocompatible
		" Thu Sep 28 2017 15:07: This order matters. 
		filetype plugin indent on
		syntax on
	endif
	let g:mapleader="\<Space>"
	let g:maplocalleader="\<Space>"

	if has('win32')
		" WINDOWS_SETTINGS
		" ~/.dotfiles/vim-utils/autoload/win32.vim
		call win32#Config()
	elseif has('unix')
		" UNIX_SETTINGS
		" ~/.dotfiles/vim-utils/autoload/unix.vim
		call unix#Config()
	endif


	" PLUGINS_INIT
	" ~/.dotfiles/vim-utils/autoload/plugin.vim
	if plugin#Check() && plugin#Config()
		let g:plugins_loaded = 1
	else
		echomsg "No plugins where loaded"
	endif

	" Create required folders for storing usage data
	call utils#CheckDirwoPrompt(g:std_data_path . '/sessions')
	call utils#CheckDirwoPrompt(g:std_data_path . '/ctags')
	if has('persistent_undo') 
		let g:undofiles_path = g:std_cache_path . '/undofiles'
		call utils#CheckDirwoPrompt(g:undofiles_path)
	endif

	call mappings#Set()

	" NVIM SPECIFIC
	" ~/.dotfiles/vim-utils/autoload/nvim.vim
	if has('nvim')
		call nvim#Config()
	endif

	call options#Set()
	call augroup#Set()
	call commands#Set()
	call syntax#Set()
endfunction

" vim:tw=78:ts=2:sts=2:sw=2:
