" File:					init.vim
" Description:  Vim/Neovim configuration file
" Author:				Reinaldo Molina
" Version:			0.1.0
"								- Fully modularize config files
"								- Dein plugin
"								- Python functions files
" Date:					Sun Aug 20 2017 05:13
" Created:			Aug 2015

if !has('nvim')
	" Required settings for vim
	set nocompatible
	" Thu Sep 28 2017 15:07: This order matters.
	filetype plugin indent on
	syntax on
endif

" You can a pass a list of files to the function and those and only those files will be sourced
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
	let root_folder_portable_vim = getcwd() . (has('nvim') ?  '/../../../' : '/../../')
	let location_portable_vim = root_folder_portable_vim . 'dotfiles/vim-utils'

	" Below here defines the default location for where the plugins go and
	" vim-plug as well
	if !empty(glob(location_local_vim))
		let g:location_vim_utils = location_local_vim
		let g:vim_plugins_path = g:std_data_path . '/vim_plugins'
		let g:plug_path = g:std_data_path . '/vim-plug/plug.vim'
	elseif !empty(glob(location_portable_vim))
		let g:vim_plugins_path= root_folder_portable_vim .'vim-data/vim_plugins/'
		let g:location_vim_utils = location_portable_vim
		let g:plug_path = root_folder_portable_vim . 'vim-data/vim-plug/plug.vim'
		let g:portable_vim = 1
	else
		echomsg 'No vim configuration files where found'
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
		let g:std_config_path = (exists('$APPDATA')) ? $APPDATA : expand("~\\AppData\\Roaming")
		let g:std_data_path = (exists('$LOCALAPPDATA')) ? $LOCALAPPDATA . "\\vim-data" : expand("~\\AppData\\Local\\vim-data")
		let g:std_cache_path = (exists('$TEMP')) ? $TEMP : expand("~\\AppData\\Local\\Temp")
	else
		let g:std_config_path = (exists('$XDG_CONFIG_HOME')) ? $XDG_CONFIG_HOME : expand("~/.config")
		let g:std_data_path = (exists('$XDG_DATA_HOME')) ? $XDG_DATA_HOME . '/vim-data' : expand("~/.local/share/vim-data")
		let g:std_cache_path = (exists('$XDG_CACHE_HOME')) ? $XDG_CACHE_HOME : expand("~/.cache")
	endif
endfunction

call s:find_vim_config_file()

" call s:set_stdpaths()
" execute "source " . g:std_data_path . '/vim-plug/plug.vim'
" call plug#begin(g:std_data_path . '/vim_plugins')
" Plug 'francoiscabrol/ranger.vim'
" Plug 'c0r73x/neotags.nvim' " Depends on pip3 install --user psutil
" let g:neotags_enabled = 1
" call plug#end()
