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

	nnoremap <buffer> <Leader>ls :call MdCheckSpelling()<cr>

	if exists(':OnlineThesaurusCurrentWord')
		nnoremap <buffer> <Leader>la :OnlineThesaurusCurrentWord<cr>
	endif
endif

if exists('*AutoCorrect')
	call AutoCorrect()
endif

" Advanced spelling checks for when writting documents and such
" Other tools should be enabled and disabled here
function! MdCheckSpelling() abort
	if exists('b:spelling_toggle') || b:spelling_toggle == 0
		if exists(':DittoOn')
			execute "DittoOn"
		endif

		if exists(':LanguageToolCheck')
			execute "LanguageToolCheck"
		endif
		let b:spelling_toggle = 1
	else
		if exists(':DittoOff')
			execute "DittoOff"
		endif

		if exists(':LanguageToolClear')
			execute "LanguageToolClear"
		endif
		let b:spelling_toggle = 0
	endif
endfunction

function! MdInstallTemplate() abort
	if has('win32')
		if !exists('g:std_config_path')
			echomsg 'MdInstallTemplate(): g:std_config_path doesnt exist'
			return
		else
			let template_path = g:std_config_path . "\\pandoc\\templates\\eisvogel.latex"
		endif
	else
		let template_path = '~/.pandoc/templates/eisvogel.latex'
	endif

	if executable('curl')
		" TODO-[RM]-(Fri Sep 15 2017 16:51): Make function out of this
		execute "silent !curl -kfLo " . template_path . " --create-dirs"
				\"https://raw.githubusercontent.com/Wandmalfarbe/pandoc-latex-template/master/eisvogel.latex"
	else
		echomsg 'curl not available. Cannot download templates'
	endif
endfunction

" TODO-[RM]-(Wed Sep 06 2017 17:22): Keep improving this here
function! MdPreview() abort
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
command! -buffer UtilsPreviewMarkdown call MdPreview()

let b:undo_ftplugin = "setl foldenable< spell< complete< ts< sw< sts<" 
