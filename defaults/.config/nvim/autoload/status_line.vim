" File:           status_line.vim
" Description:    lightline plugin configuration and helper functions
" Author:		    Reinaldo Molina
" Email:          rmolin88 at gmail dot com
" Revision:	    0.0.0
" Created:        Sat Apr 21 2018 23:11
" Last Modified:  Sat Apr 21 2018 23:11

" selection - {lightline, airline}
function! status_line#config(selection) abort
	if a:selection ==# 'lightline'
		return s:lightline_config()
	elseif a:selection ==# 'airline'
		return s:airline_config()
	endif

	echomsg '[status_line#config]: No valid status line selected'
endfunction

function! s:airline_config() abort
	Plug 'vim-airline/vim-airline-themes'
	Plug 'vim-airline/vim-airline'
		if exists('g:valid_device')
			let g:airline_powerline_fonts = 1
		endif

		if !has('unix')
			let g:airline#extensions#whitespace#enabled = 0

			" Fancy separator doesnt look well in windows
			" let g:airline_left_sep = '|'
			" let g:airline_left_alt_sep = '|'
			" let g:airline_right_sep = '|'
			" let g:airline_right_alt_sep = '|'
		endif

		let g:airline_detect_spelllang=0

		let g:airline#extensions#default#layout = [
					\ [ 'error', 'warning', 'a', 'b', 'c' ],
					\ [ 'x', 'y', 'z' ]
					\ ]

		" let g:airline#extensions#default#section_truncate_width = { 'z': 25 }

		let g:airline_theme='papercolor'

		let g:airline_section_c = "\uf02d %t"

		let g:airline#extensions#ctrlp#show_adjacent_modes = 1

		let g:airline#extensions#neomake#enabled = 1
		let g:airline#extensions#neomake#error_symbol = 'E:'
		let g:airline#extensions#neomake#warning_symbol = 'W:'

		let g:airline#extensions#nrrwrgn#enabled = 0

		let g:airline#extensions#capslock#enabled = 1

		let g:airline#extensions#hunks#enabled = 1
		let g:airline#extensions#hunks#non_zero_only = 0
		let g:airline#extensions#hunks#hunk_symbols = ['+', '~', '-']
endfunction

function! s:lightline_config() abort
	Plug 'itchyny/lightline.vim'

	if !exists('g:lightline')
		let g:lightline = {}
	endif
	" Basic options
	" otf-inconsolata-powerline-git
	let g:lightline = {
				\ 'active' : {
				\   'left': [
				\							[ 'mode', 'spell' ],
				\							[ 'readonly', 'filename' ],
				\							[  ]
				\						],
				\ 'right': [ [ 'lineinfo' ],
				\            [ 'filetype' ],
				\            [ 'word_count' ] ] }
				\ }

	let g:lightline.inactive = {
			\ 'left': [ [ 'absolutepath' ] ],
			\ 'right': [ [ 'lineinfo' ],
			\            [ '' ] ] }

	let g:lightline.tabline = {
				\ 'left': [ ['tabs'] ],
				\ 'right': [ [ 'bufnum' , 'close'] ] }

  let g:lightline.mode_map = {
        \ 'n' : 'N',
        \ 'i' : 'I',
        \ 'R' : 'R',
        \ 'v' : 'V',
        \ 'V' : 'VL',
        \ "\<C-v>": 'VB',
        \ 'c' : 'C',
        \ 's' : 'S',
        \ 'S' : 'SL',
        \ "\<C-s>": 'SB',
        \ 't': 'T',
        \ }

	let g:lightline.component = {}
	if exists('g:valid_device')
		" Ovals. As opposed to the triangles. They do not look quite good
		" let g:lightline.separator['left']     = "\ue0b4"
		" let g:lightline.separator['right']    = "\ue0b6"
		" let g:lightline.subseparator['left']  = "\ue0b5"
		" let g:lightline.subseparator['right'] = "\ue0b7"

		" Fri May 18 2018 14:09: Also a little tired of these. Taking a break
		" let g:lightline.separator = {}
		" let g:lightline.separator['left']     = ''
		" let g:lightline.separator['right']    = ''

		" let g:lightline.subseparator = {}
		" let g:lightline.subseparator['left']  = ''
		" let g:lightline.subseparator['right'] = ''

		let g:lightline.component['lineinfo'] = ' %p%%/%L:%-2v'
		" let g:lightline.component['filename'] = "\uf02d %t"
	else
		let g:lightline.component['lineinfo'] = '%p%%/%L:%-2v'
		" let g:lightline.component['filename'] = "%t"
	endif

	let g:lightline.component_function = {}
	let g:lightline.component_function['filename']   = string(function('s:get_filename'))
	let g:lightline.component_function['filetype']   = string(function('s:devicons_filetype'))
	let g:lightline.component_function['fileformat'] = string(function('s:devicons_fileformat'))
	let g:lightline.component_function['readonly']   = string(function('s:get_readonly'))
	let g:lightline.component_function['spell']      = string(function('s:get_spell'))
	let g:lightline.component_function['mode']       = string(function('s:get_mode'))

	let g:lightline.component_function['word_count'] = string(function('s:get_word_count'))

	let g:lightline.active.left[2] += [ 'ver_control' ]
	let g:lightline.component_function['ver_control'] = string(function('s:get_version_control'))

	" 0.000001*bytes = mb
endfunction

function! s:get_mode() abort
	let fname = expand('%:t')
	return fname ==# '__Tagbar__' ? 'Tagbar' :
				\ fname ==# 'ControlP' ? 'CtrlP' :
				\ fname ==# '__Gundo__' ? 'Gundo' :
				\ fname ==# '__Gundo_Preview__' ? 'Gundo Preview' :
				\ fname =~# 'NERD_tree' ? 'NERDTree' :
				\ &filetype ==# 'unite' ? 'Unite' :
				\ &filetype ==# 'vimfiler' ? 'VimFiler' :
				\ &filetype ==# 'vimshell' ? 'VimShell' :
				\ winwidth(0) > 60 ? lightline#mode() : ''
endfunction

function! s:get_filename() abort
	let l:fname = expand('%:t')
	let l:rc = l:fname ==# 'ControlP' && has_key(g:lightline, 'ctrlp_item') ? g:lightline.ctrlp_item :
				\ l:fname ==# '__Tagbar__' ? g:lightline.fname :
				\ l:fname =~# '__Gundo\|NERD_tree' ? '' :
				\ &filetype ==# 'vimfiler' ? vimfiler#get_status_string() :
				\ &filetype ==# 'unite' ? unite#get_status_string() :
				\ &filetype ==# 'vimshell' ? vimshell#get_status_string() :
				\ ('' !=# l:fname ? l:fname : '[No Name]') .
				\ ('' !=# s:get_modifiable() ? ' ' . s:get_modifiable() : '')
	return exists('g:valid_device') ? "\uf02d " . l:rc : l:rc
endfunction

function! s:get_modifiable() abort
	return &filetype =~# 'help' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! s:get_spell() abort
	return &spell ? 'SPELL' : ''
endfunction

function! s:get_cwd(count) abort
	return getcwd()
endfunction

function! s:devicons_filetype() abort
	if !exists('*WebDevIconsGetFileTypeSymbol') || !exists('g:valid_device')
		return &filetype
	endif

	return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype . ' ' . WebDevIconsGetFileTypeSymbol() : 'no ft') : ''
endfunction

function! s:get_version_control() abort
	return exists('s:ver_ctrl') ? s:ver_ctrl : ''
endfunction

function! status_line#SetVerControl() abort
	if &modifiable == 0 || &ft =~? 'vimfiler\|gitcommit\|no ft'
		unlet! s:ver_ctrl
	endif

	let svn_mark = exists('g:valid_device') ? '' . ':' : 'svn:'
	let git_mark = exists('g:valid_device') ? "\uf406" . ':' : 'git:'

	let l:signify_stats = ''
	if (exists('*plugin#SyStatsWrapper'))
		let l:signify_stats = plugin#SyStatsWrapper()
	endif

	try
		if exists('*fugitive#head')
			let git = fugitive#statusline()
			" echomsg 'git = ' . git
			if !empty(git)
				let s:ver_ctrl = git_mark . git . l:signify_stats
				" echomsg s:ver_ctrl
				return
			endif
		endif
		" TODO-[RM]-(Mon Oct 30 2017 16:37): This here really doesnt work
		if exists('*utils#UpdateSvnBranchInfo')
			let svn = utils#UpdateSvnBranchInfo()
			" echomsg 'svn = ' . svn
			if !empty(svn)
				let s:ver_ctrl = svn_mark . svn . l:signify_stats
				" echomsg s:ver_ctrl
				return
			endif
		endif
	catch
		unlet! s:ver_ctrl
	endtry
	unlet! s:ver_ctrl
endfunction

function! s:devicons_fileformat() abort
	if !exists('*WebDevIconsGetFileTypeSymbol') || !exists('g:valid_device')
		return &fileformat
	endif

	return winwidth(0) > 70 ? (&fileformat . ' ' . WebDevIconsGetFileFormatSymbol()) : ''
endfunction

function! s:get_readonly() abort
	return &readonly ?
				\ (exists('g:valid_device') ? '' : 'R')
				\  : ''
endfunction

function! s:get_word_count() abort
	if &filetype !=# 'markdown' || !exists('*wordcount')
		return ''
	endif

	let l:words = wordcount()

	if has_key(l:words, 'visual_words')
		let l:ret = l:words.visual_words
	elseif has_key(l:words, 'words')
		let l:ret = l:words.words
	else
		return ''
	endif

	return l:ret . ' words'
endfunction
