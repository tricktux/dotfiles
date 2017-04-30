" File:					markdown.vim
" Description:	After default ftplugin for markdown
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:			1.0.0
" Last Modified: Fri Apr 28 2017 15:43
" Created:					Wed Nov 30 2016 11:02

" Only do this when not done yet for this buffer
if exists("b:did_markdown_ftplugin")
	finish
endif

" Don't load another plugin for this buffer
let b:did_markdown_ftplugin = 1

setlocal foldenable
setlocal foldexpr=MarkdownLevel()
setlocal foldmethod=expr
setlocal spell spelllang=en_us

" TODO.RM-Fri Apr 28 2017 15:43: Fix these mappings  
if has('unix')
	autocmd FileType markdown nnoremap <buffer> <Leader>lr :!google-chrome-stable %<CR>
endif

if !exists("no_plugin_maps") && !exists("no_markdown_maps")
	" Encapsulate in markdown file from current line until end of file in ```
	nnoremap <buffer> <unique> <Leader>l` :normal i````cpp<Esc>Go```<Esc><CR>
	" Markdown fix _ showing red
	nnoremap <buffer> <unique> <Leader>lf :%s/_/\\_/gc<CR>
	nnoremap <buffer> <unique> <Leader>td :call utils#TodoCreate()<CR>
	nnoremap <buffer> <unique> <Leader>tm :call utils#TodoMark()<CR>
	nnoremap <buffer> <unique> <Leader>tM :call utils#TodoClearMark()<CR>
	nnoremap <buffer> <unique> <Leader>ta :call utils#TodoAdd()<CR>
	inoremap <buffer> * **<Left>
endif

function! MarkdownLevel()
	if getline(v:lnum) =~ '^# .*$'
		return ">1"
	endif
	if getline(v:lnum) =~ '^## .*$'
		return ">2"
	endif
	if getline(v:lnum) =~ '^### .*$'
		return ">3"
	endif
	if getline(v:lnum) =~ '^#### .*$'
		return ">4"
	endif
	if getline(v:lnum) =~ '^##### .*$'
		return ">5"
	endif
	if getline(v:lnum) =~ '^###### .*$'
		return ">6"
	endif
	return "="
endfunction

let b:undo_ftplugin += "setl foldenable< foldexpr< foldmethod< spell< spelllang<" 
