" File:					markdown.vim
" Description:	After default ftplugin for markdown
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:			1.0.0
" Last Modified: Sat Jul 29 2017 07:44
" Created:					Wed Nov 30 2016 11:02

" Only do this when not done yet for this buffer
if exists("b:did_markdown_ftplugin")
	finish
endif

" Don't load another plugin for this buffer
let b:did_markdown_ftplugin = 1

setlocal foldenable
setlocal spell
setlocal spelllang=en_us
setlocal complete+=kspell
setlocal ts=2
setlocal sw=2
setlocal sts=2

if !exists("no_plugin_maps") && !exists("no_markdown_maps")
	" Encapsulate in markdown file from current line until end of file in ```
	nnoremap <buffer> <unique> <Leader>l` :normal o````cpp<CR>```<Esc>
	" Markdown fix _ showing red
	nnoremap <buffer> <unique> <Leader>ld :call utils#TodoCreate()<CR>
	nnoremap <buffer> <unique> <Leader>lm :call utils#TodoMark()<CR>
	nnoremap <buffer> <unique> <Leader>lM :call utils#TodoClearMark()<CR>
	inoremap <buffer> * **<Left>
	inoremap <buffer> [ [ ]<Space>

	if exists(':FocusModeToggle')
		nmap <buffer> <Leader>lf <Plug>FocusModeToggle
	endif

	if exists(':InsertNewBullet')
		inoremap <buffer> <expr> <cr> pumvisible() ? "\<c-y>" : "<cr>"
		nnoremap <buffer> o :InsertNewBullet<cr>
	endif

	if exists(':Toc')
		nnoremap <buffer> <Leader>lt :Toc<cr>
	endif

	if exists(':NextWordy')
		nnoremap <buffer> <Leader>ls :NextWordy<cr>
	endif

	if exists(':OnlineThesaurusCurrentWord')
		nnoremap <buffer> <Leader>la :OnlineThesaurusCurrentWord<cr>
	endif
endif

function! s:markdownLevel()
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

function! s:preview_markdown() abort
	if has('win32') || has('win64')
		if exists('Dispatch') && exists('g:browser_cmd') && executable(g:browser_cmd)
			execute "Dispatch " . g:browser_cmd . " %"
		else
			echomsg 'vim-dispatch not available or browser_cmd not executable/found'
		endif
	else
		execute $BROWSER . " %"
	endif
endfunction

command! -buffer UtilsWeeklyReportCreate call utils#ConvertWeeklyReport()
command! -buffer UtilsFixUnderscore execute("%s/_/\\_/gc<CR>")
" TODO.RM-Thu May 18 2017 12:17: This should be changed to opera  
command! -buffer UtilsPreviewMarkdown call s:preview_markdown()

let b:undo_ftplugin = "setl foldenable< spell< complete< ts< sw< sts<" 
