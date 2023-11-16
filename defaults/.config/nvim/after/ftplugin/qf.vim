" File:					qf.vim
"	Description:	Mappings particular to quickfix window
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:			1.0.0
" Last Modified: Tue May 02 2017 21:24
" Created:			 May 02 2017 18:52

" Only do this when not done yet for this buffer
if exists('b:did_qf_ftplugin')
	finish
endif

" Don't load another plugin for this buffer
let b:did_qf_ftplugin = 1

let s:keepcpo= &cpoptions
set cpoptions&vim

setlocal cursorline
setlocal colorcolumn=""
setlocal nospell

" Taken from 
" "http://stackoverflow.com/questions/18522086/what-is-the-best-way-to-
" distinguish-the-current-buffer-is-location-list-or-quick"
function! s:detect_list() abort
	exec 'redir @a | silent! ls | redir END'
	if match(@a,'%a   "\[Location List\]"') >= 0
		let b:list_type = 'l' " loc
	elseif match(@a,'%a   "\[Quickfix List\]"') >= 0
		let b:list_type = 'c' " qf
	else
		echomsg 'Neither Location or Quicklist focused!'
		return 0
	endif
	return 1
endfunction

" Add mappings, unless the user didn't want this.
if !exists('no_plugin_maps') && !exists('no_qf_maps')
	if <sid>detect_list() == 1 && exists('b:list_type')
		exec 'nnoremap <buffer> <c-j> :' . b:list_type . 'next<cr><c-w>j'
		exec 'nnoremap <buffer> <c-k> :' . b:list_type . 'previous<cr><c-w>j'
		exec 'nnoremap <buffer> <c-l> :' . b:list_type . 'nf<cr><c-w>j'
		exec 'nnoremap <buffer> <c-h> :' . b:list_type . 'pf<cr><c-w>j'

		exec 'nnoremap <buffer> <cr> :.' . b:list_type . b:list_type . '<CR>'
		exec 'nnoremap <buffer> q :' . b:list_type . 'cl<cr><c-w>p'
		exec 'nnoremap <silent> <buffer> c :call ' .
					\ (b:list_type ==# 'c' ? 'setqflist([])' : 'setloclist(0, [])') .
					\ '<cr>'
	endif
endif

let &cpoptions = s:keepcpo
unlet s:keepcpo

let b:undo_ftplugin = 'setlocal cursorline<'
      \ . '|setlocal colorcolumn<'
      \ . '|setlocal spell<'
