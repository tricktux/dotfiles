" File:					qf.vim
"	Description:	Mappings particular to quickfix window
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:			1.0.0
" Last Modified: Tue May 02 2017 21:24
" Created:			 May 02 2017 18:52

" Only do this when not done yet for this buffer
if exists("b:did_qf_ftplugin")
	finish
endif

" Don't load another plugin for this buffer
let b:did_qf_ftplugin = 1

setlocal wrap
setlocal nospell

" Taken from http://stackoverflow.com/questions/18522086/what-is-the-best-way-to-distinguish-the-current-buffer-is-location-list-or-quick
function! s:DetectList() abort
	exec 'redir @a | silent! ls | redir END'
	if match(@a,'%a   "\[Location List\]"') >= 0
		let b:list_type = 'l' " loc
	elseif match(@a,'%a   "\[Quickfix List\]"') >= 0
		let b:list_type = 'c' " qf
	else
		echomsg "Neither Location or Quicklist focused!"
		return 0
	endif
	return 1
endfunction

" Add mappings, unless the user didn't want this.
if <SID>DetectList() == 1 && exists('b:list_type') && !exists("no_plugin_maps") && !exists("no_qf_maps")
	exec 'nnoremap <buffer> <C-j> :' . b:list_type . 'next<CR><c-w>j'
	exec 'nnoremap <buffer> <C-k> :' . b:list_type . 'previous<CR><c-w>j'
	exec 'nnoremap <buffer> <C-l> :' . b:list_type . 'nf<CR><c-w>j'
	exec 'nnoremap <buffer> <C-h> :' . b:list_type . 'pf<CR><c-w>j'

	exec 'nnoremap <buffer> <cr> :.' . b:list_type . b:list_type . '<CR>'
	exec 'nnoremap <buffer> q :' . b:list_type . 'cl<CR><C-w>p'
endif

let b:undo_ftplugin += "setlocal wrap< spell<" 
