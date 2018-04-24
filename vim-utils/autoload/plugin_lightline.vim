" File:           plugin_lightline.vim
" Description:    lightline plugin configuration and helper functions
" Author:		    Reinaldo Molina
" Email:          rmolin88 at gmail dot com
" Revision:	    0.0.0
" Created:        Sat Apr 21 2018 23:11
" Last Modified:  Sat Apr 21 2018 23:11


function! plugin_lightline#config() abort
	Plug 'itchyny/lightline.vim'
	" Note: Inside of the functions here there can be no single quotes (') only double (")
	if !exists('g:lightline')
		let g:lightline = {}
	endif
	" Basic options
	" otf-inconsolata-powerline-git
	let g:lightline = {
				\ 'active' : {
				\   'left': [
				\							[ 'mode', 'paste' ],
				\							[ 'readonly', 'relativepath' ],
				\							[  ]
				\						],
				\ 'right': [ [ 'lineinfo' ],
				\            [ 'percent' ],
				\            [ 'fileformat', 'fileencoding', 'filetype' ] ] }
				\ }
	" \ 'component': {
	" \   'lineinfo': ' %3l:%-2v',
	" \ },
	" \ 'separator': { 'left': '', 'right': '' },
	" \ 'subseparator': { 'left': '', 'right': '' }
	" \ }

	" let g:lightline.tab = {
	" \ 'active': [ 'tabnum', 'absolutepath', 'modified' ],
	" \ }
	let g:lightline.tabline = {
				\ 'left': [ ['tabs'] ],
				\ 'right': [ [ 'bufnum' , 'close'] ] }
	let g:lightline.tab_component_function = {
				\ 'filename': 'plugin_lightline#cwd'
				\ }
	" Addons
	let g:lightline.component = {}
	let g:lightline.component['lineinfo'] = ' %3l:%-2v'

	let g:lightline.separator = {}
	let g:lightline.subseparator = {}

	" Ovals. As opposed to the triangles. They do not look quite good
	" let g:lightline.separator['left'] = "\ue0b4"
	" let g:lightline.separator['right'] = "\ue0b6"
	" let g:lightline.subseparator['left'] = "\ue0b5"
	" let g:lightline.subseparator['right'] = "\ue0b7"

	let g:lightline.separator['left'] = ''
	let g:lightline.separator['right'] = ''
	let g:lightline.subseparator['left'] = ''
	let g:lightline.subseparator['right'] = ''

	let g:lightline.component_function = {}
	let g:lightline.component_function['filetype'] = 'plugin_lightline#DeviconsFileType'
	let g:lightline.component_function['fileformat'] = 'plugin_lightline#DeviconsFileFormat'
	let g:lightline.component_function['readonly'] = 'plugin_lightline#Readonly'

	let g:lightline.active.left[2] += [ 'ver_control' ]
	let g:lightline.component_function['ver_control'] = 'plugin_lightline#VerControl'

	" These settings do not use patched fonts
	" Fri Feb 02 2018 15:38: Its number one thing slowing down vim right now.
	" let g:lightline.active.left[2] += [ 'tagbar' ]
	" let g:lightline.component_function['tagbar'] = 'utils#LightlineTagbar'
endfunction

function! plugin_lightline#cwd(count) abort
	return getcwd()
endfunction

function! plugin_lightline#DeviconsFileType() abort
	if !exists('*WebDevIconsGetFileTypeSymbol')
		return &filetype
	endif

	return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype . ' ' . WebDevIconsGetFileTypeSymbol() : 'no ft') : ''
endfunction

function! plugin_lightline#VerControl() abort
	" let mark = ''  " edit here for cool mark
	let mark = "\uf406"  " edit here for cool mark
	if expand('%:t') =~? 'Tagbar\|Gundo\|NERD\|ControlP' || &ft =~? 'vimfiler\|gitcommit'
		return ''
	endif

	try
		if exists('*fugitive#head')
			let git = fugitive#head()
			return empty(git) ? '' : mark . ' ' . git
		endif
		" TODO-[RM]-(Mon Oct 30 2017 16:37): This here really doesnt work
		" if executable('svn') && exists('*utils#UpdateSvnBranchInfo')
		" let svn = utils#UpdateSvnBranchInfo()
		" if !empty(svn)
		" return '' . ' ' . svn
		" endif
		" endif
	catch
		return ''
	endtry
	return ''
endfunction

function! plugin_lightline#DeviconsFileFormat() abort
	if !exists('*WebDevIconsGetFileTypeSymbol')
		return &fileformat
	endif

	return winwidth(0) > 70 ? (&fileformat . ' ' . WebDevIconsGetFileFormatSymbol()) : ''
endfunction

function! plugin_lightline#Readonly() abort
	return &readonly ? '' : ''
endfunction

function! plugin_lightline#CtrlPMark() abort
	if expand('%:t') !~# 'ControlP' || !has_key(g:lightline, 'ctrlp_item')
		return ''
	endif

	call lightline#link('iR'[g:lightline.ctrlp_regex])
	return lightline#concatenate([g:lightline.ctrlp_prev, g:lightline.ctrlp_item
				\ , g:lightline.ctrlp_next], 0)
endfunction

function! plugin_lightline#CtrlPStatusFunc_1(focus, byfname, regex, prev, item, next, marked) abort
	let g:lightline.ctrlp_regex = a:regex
	let g:lightline.ctrlp_prev = a:prev
	let g:lightline.ctrlp_item = a:item
	let g:lightline.ctrlp_next = a:next
	return lightline#statusline(0)
endfunction

function! plugin_lightline#CtrlPStatusFunc_2(str) abort
	return lightline#statusline(0)
endfunction

function! plugin_lightline#Tagbar() abort
	try
		let ret =  tagbar#currenttag('%s','')
	catch
		return ''
	endtry
	return empty(ret) ? '' : "\uf02b" . ' ' . ret
endfunction

function! plugin_lightline#TagbarStatusFunc(current, sort, fname, ...) abort
	let g:lightline.fname = a:fname
	return lightline#statusline(0)
endfunction

function! plugin_lightline#UpdateColorscheme() abort
	if !exists('g:loaded_lightline')
		return
	endif

	" Update the name first. This is important. Otherwise no colorscheme is set during startup
	if exists('g:lightline')
		if &background ==# 'dark'
			let g:lightline.colorscheme = g:colorscheme_night . '_dark'
		else
			let g:lightline.colorscheme = g:colorscheme_day . '_light'
		endif
	endif

	try
		" if g:colors_name =~# 'wombat\|solarized\|landscape\|jellybeans\|seoul256\|Tomorrow\|gruvbox\|PaperColor\|zenburn'
		" let g:lightline.colorscheme =
		" \ substitute(substitute(g:colors_name, '-', '_', 'g'), '256.*', '', '')
		call lightline#init()
		call lightline#colorscheme()
		call lightline#update()
	catch
	endtry
endfunction
