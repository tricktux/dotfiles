" File:					man.vim
" Description:			Customizations for man pages
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:				0.0.0
" Last Modified: Sun Jul 30 2017 12:53
" Created: Jun 25 2017 09:09

" Only do this when not done yet for this buffer
if exists("b:did_man_ftplugin")
	finish
endif

" Don't load another plugin for this buffer
let b:did_man_ftplugin = 1
let s:keepcpo= &cpo
set cpo&vim

setlocal wrap

if !exists("no_plugin_maps") && !exists("no_man_maps")
	nmap <buffer> Q :bp\|bw #\|bd #<CR>
	nnoremap <buffer> q :hide\|bw #\|bd #<CR>
	nnoremap <buffer> <S-k> :CtrlPBuffer<CR>
	nnoremap <buffer> ]t K
	nnoremap <buffer> [t <C-T>
endif

let b:undo_ftplugin = "setlocal wrap<"

let &cpo = s:keepcpo
unlet s:keepcpo
