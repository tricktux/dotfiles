" File:					init.vim
" Description:	Main file that call configuration functions
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:				0.0.0
" Last Modified: Aug 21 2017 16:15
" Created: Aug 21 2017 16:15

function init#vim() abort
	" PLUGINS_INIT
	" ~/.dotfiles/vim-utils/autoload/plugin.vim
	" Attempt to install vim-plug and all plugins in case of first use
	" All of this is going to go into function InitVim
	" moved here otherwise conditional mappings get / instead ; as leader
	if plugin#Check() && plugin#Config()
		let g:plugins_loaded = 1
	else
		echomsg "No plugins where loaded"
	endif

	" NVIM SPECIFIC
	" ~/.dotfiles/vim-utils/autoload/nvim.vim
	if has('nvim')
		call nvim#Config()
	endif

	" WINDOWS_SETTINGS
	" ~/.dotfiles/vim-utils/autoload/win32.vim
	if has('win32')
		call win32#Config()
		" UNIX_SETTINGS
		" ~/.dotfiles/vim-utils/autoload/unix.vim
	elseif has('unix')
		call unix#Config()
	endif

	call options#Set()
	call augroup#Set()
	call mappings#Set()
	call commands#Set()
	call syntax#Set()

	" HIGHLITING
	" ~/.dotfiles/vim-utils/autoload/highlight.vim
		if exists("g:plugins_loaded")
			" Search
			call highlight#Set('Search',									{ 'fg': g:turquoise4 }, 'bold')
			call highlight#Set('IncSearch',								{ 'bg': g:white }, 'bold')
			highlight IncSearch cterm=bold gui=bold
			highlight Search cterm=bold gui=bold
			highlight Comment cterm=italic gui=italic
		endif
endfunction

" vim:tw=78:ts=2:sts=2:sw=2:
