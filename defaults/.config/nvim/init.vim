" File:					init.vim
" Description:  Vim/Neovim configuration file
" Author:				Reinaldo Molina
" Version:			9.0.0
"								- Fully modularize config files
"								- Dein plugin
"								- Python functions files
" Date:					Sun Aug 20 2017 05:13
" Created:			Aug 2015
" Improvements:
		" - [ ] Create a after/syntax/gitcommit.vim to redline ahead and greenline
		"   up-to-date
		" - [ ] Delete duplicate music.
		" - [ ] Construct unified music library
		" - [ ] Markdown math formulas

" Req for vim
	set nocompatible
	syntax on
	filetype plugin indent on
	let mapleader="\<Space>"
	let maplocalleader="\<Space>"

" You can a pass a list of files to the function and those will your vimrc files
function s:find_vim_config_file(...) abort
	let g:location_local_vim = '~/.dotfiles/vim-utils/autoload/*.vim'
	if has('nvim')
		let g:location_portable_vim = '../../.dotfiles/vim-utils/autoload/*.vim'
		let g:location_vim_utils = getcwd() . '/../../.dotfiles/vim-utils'
		let g:location_vim_plug = "../../vimfiles/autoload/plug.vim"
		let g:vimfile_path=  '../../vimfiles/'
	else
		let g:location_portable_vim = "../.dotfiles/vim-utils/autoload/*.vim"
		let g:location_vim_utils = getcwd() . '/../.dotfiles/vim-utils'
		let g:location_vim_plug = "../vimfiles/autoload/plug.vim"
		""let g:vimfile_path=  '../vimfiles/'
	endif

	if a:0 > 0
		for item in a:000
			execute "source " . item
		endfor
		return
	elseif !empty(glob(g:location_local_vim))
		let src_files = glob(g:location_local_vim, 0, 1)
		let g:location_vim_utils = "~/.dotfiles/vim-utils"
	elseif !empty(glob(g:location_portable_vim))
		let src_files = glob(g:location_portable_vim, 0, 1)
		let src_files += g:location_vim_plug
		let g:portable_vim = 1
	else
		echomsg "No vim-utils files where found"
		return
	endif

	for f in src_files
		execute "source " . f
	endfor
	call init#vim()

"	if !empty(glob(g:location_local_vim))
"		execute "source " . g:location_local_vim
"		let g:plugins_present = 1
"		let g:location_vim_utils = "~/.dotfiles/vim-utils"
"	elseif !empty(glob(g:location_portable_vim))
"		execute "source " . g:location_portable_vim
"		execute "source " . g:location_vim_plug
"		let g:plugins_present = 1
"	else
"		echomsg "No vim-utils files where found"
"	endif
endfunction

call s:find_vim_config_file()


" vim:tw=78:ts=2:sts=2:sw=2:
