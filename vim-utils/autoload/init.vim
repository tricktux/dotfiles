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
		syntax on
		filetype plugin indent on
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
