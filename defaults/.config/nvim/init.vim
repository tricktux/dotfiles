" File:					init.vim
" Description:  Vim/Neovim configuration file
" Author:				Reinaldo Molina
" Version:			0.2.0
"								- Properly distribute files so they are autoloaded
"								- Fully modularize config files
"								- Dein plugin
"								- Python functions files
" Date:					Sun Aug 20 2017 05:13
" Created:			Aug 2015
" Vimfiles:
" Make symbolic link from dotfiles/defaults/.config/nvim to:
" - unix (vim)  : ~/.vim
" - unix (nvim) : ~/.config/nvim
" - win (vim)  : ~/vimfiles
" - win (nvim) : ~/AppData/Local/nvim
"		vim:
"			unix: ~/.vim
"			unix: ~/.vim/vimrc
"			win: ~/vimfiles
"			win: ~/vimfiles/vimrc
"		nvim:
"			unix: ~/.config/nvim
"			unix: ~/.config/nvim/init.vim
"			unix (data): ~/.local/share/nvim
"
"			win: ~/AppData/Local/nvim
"			win (data): ~/AppData/Local/nvim-data

if !has('nvim')
	" Required settings for vim
	set nocompatible
	" Thu Sep 28 2017 15:07: This order matters.
	filetype plugin indent on
	syntax on
endif

" Needs to be defined before the first <Leader>/<LocalLeader> is used
" otherwise it goes to "\"
let g:mapleader="\<Space>"
let g:maplocalleader="g"
" Mon Oct 30 2017 15:24: Patched fonts depend on this option. It also needs
" to be here. Otherwise Alt mappings stop working
set encoding=utf-8

" You can a pass a list of files to the function and those and only
" those files will be sourced
function! s:find_vim_config_file(...) abort
	" If source files were provided source only those and exit
	if a:0 > 0
		for item in a:000
			let l:files = glob(item, 0, 1)
			if empty(l:files)
				continue
			endif
			for fil in l:files
				execute "source " . fil
			endfor
		endfor
		return
	endif

	call s:set_stdpaths()

	let l:root_folder_portable_vim = getcwd() . (has('nvim') ?
				\ '/../../../data/' : '/../../data/')
	let g:dotfiles = has('unix') ?
				\ expand('~/.config/dotfiles') : $LOCALAPPDATA . "\\dotfiles"

	if !empty(glob(l:root_folder_portable_vim))
		" If found portable vim. Redifine std_path
		" You need 3 folders in root
		" nvim: copy dotfiles/defaults/.config/nvim
		" nvim-data: copy nvim-data (win) or .local/share/nvim 
		" (unix) from some computer cache: create empty folder
		let g:std_config_path = l:root_folder_portable_vim . 'nvim'
		let g:std_data_path = l:root_folder_portable_vim . 'nvim-data'
		let g:std_cache_path = l:root_folder_portable_vim . 'cache'
		let g:portable_vim = 1
		let g:dotfiles = g:std_config_path
	endif

	" Define plugins locations
	let g:plug_path = g:std_data_path . '/site/autoload/plug.vim'
	let g:vim_plugins_path = g:std_data_path . '/vim_plugins'

	" Add them to the path so that they can be found
	" Sometimes they are already in the path, but just to be sure
	let &runtimepath .= ',' . g:std_config_path . ',' . g:std_data_path . '/site'

	" Configure
  " Sun Aug 30 2020 01:14: 
  "  Load lua modules. Commencement of lua awesomeness
  "  Lua plugin modules are not loaded until after plug#end(). See lua-require
  "  All lua configs are called from 'config/init.lua' which is sourced below
  if has('nvim-0.5')
    lua require('config').init()
    if plugin#Config() != 1
        echoerr 'No plugins were loaded'
    endif
    call mappings#Set()
    call options#Set()
    call augroup#Set()
    call commands#Set()
  else
    call init#vim()
  endif
  call plugin#AfterConfig()
endfunction

function! s:set_stdpaths() abort
	if has('nvim')
		return s:set_nvim_stdpaths()
	endif

	" Fix here. These should be vim std paths. Like vimfiles
	if has('unix')
		let g:std_config_path = expand('~/.vim')
		let g:std_data_path = (exists('$XDG_DATA_HOME')) ?
					\ $XDG_DATA_HOME . '/nvim' : expand('~/.local/share/nvim')
		let g:std_cache_path = (exists('$XDG_CACHE_HOME')) ?
					\ $XDG_CACHE_HOME . '/nvim' : expand('~/.cache/nvim')
	else
		let g:std_config_path = expand("~\\vimfiles")
		let g:std_data_path = (exists('$LOCALAPPDATA')) ?
					\ $LOCALAPPDATA . "\\nvim-data" :
					\ expand("~\\AppData\\Local\\nvim-data")
		let g:std_cache_path = (exists('$TEMP')) ?
					\ $TEMP : expand("~\\AppData\\Local\\Temp\\nvim")
	endif

endfunction

function! s:set_nvim_stdpaths()
	let g:std_config_path = stdpath('config')
	let g:std_data_path = stdpath('data')
	let g:std_cache_path = stdpath('cache')
endfunction

call s:find_vim_config_file()

" call s:set_stdpaths()
" execute "source " . g:std_data_path . '/site/autoload/plug.vim'
" call plug#begin(g:std_data_path . '/vim_plugins')
  " Plug 'nvim-lua/completion-nvim'
  " Plug 'neovim/nvim-lspconfig'
" call plug#end()

" lua require('utils/keymap'):set()
" lua require('config/completion').compl:set()
