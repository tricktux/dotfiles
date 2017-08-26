" File:					init.vim
" Description:  Vim/Neovim configuration file
" Author:				Reinaldo Molina
" Version:			10.0.0
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

" You can a pass a list of files to the function and those will your vimrc files
function! s:find_vim_config_file(...) abort
	" If source files were provided source only those and exit
	if a:0 > 0
		for item in a:000
			execute "source " . item
		endfor
		return
	endif

	" Otherwise try to find local or portable configuration files
	call s:set_stdpaths()
	let location_local_vim = g:std_config_path . '/dotfiles/vim-utils'
	let location_portable_vim = has('nvim') ? getcwd() . '/../../../dotfiles/vim-utils' : getcwd() . '/../../dotfiles/vim-utils'

	if !empty(glob(location_local_vim))
		let g:location_vim_utils = location_local_vim
	elseif !empty(glob(location_portable_vim))
		let g:vim_plugins_path= has('nvim') ? '../../../vim_plugins/' : '../../vim_plugins/'
		let g:location_vim_utils = location_portable_vim
		let g:portable_vim = 1
	else
		echomsg "No vim configuration files where found"
		return
	endif

	let src_files = glob(g:location_vim_utils . '/autoload/*.vim', 0, 1)
	for f in src_files
		execute "source " . f
	endfor
	call init#vim()
endfunction

function! s:set_stdpaths() abort
	if has('win32')
		let g:std_config_path = (exists('$APPDATA')) ? $APPDATA : "~\\AppData\\Roaming"
		let g:std_data_path = (exists('$LOCALAPPDATA')) ? $LOCALAPPDATA : "~\\AppData\\Local"
		let g:std_cache_path = (exists('$TEMP')) ? $TEMP : "~\\AppData\\Local\\Temp"
	else
		let g:std_config_path = (exists('$XDG_CONFIG_HOME')) ? $XDG_CONFIG_HOME : "~/.config"
		let g:std_data_path = (exists('$XDG_DATA_HOME')) ? $XDG_DATA_HOME : "~/.local/share"
		let g:std_cache_path = (exists('$XDG_CACHE_HOME')) ? $XDG_CACHE_HOME : "~/.cache"
	endif
endfunction

call s:find_vim_config_file()

" call s:set_stdpaths()

" let vim_plugins =  g:std_data_path . '/vim_plugins'
" execute "source " . vim_plugins . '/plug/plug.vim'
" call plug#begin(vim_plugins)
" Plug 'Shougo/denite.nvim', { 'as' : has('nvim') ? 'nvim_denite' : 'vim_denite' }
" call plug#end()

" vim:tw=78:ts=2:sts=2:sw=2:
