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

if !exists("no_plugin_maps") && !exists("no_markdown_maps")
	" TODO-[RM]-(Fri Oct 20 2017 08:50): Fix this code commented here below
	" Encapsulate in markdown file from current line until end of file in ```
	" nnoremap <buffer> <unique> <LocalLeader>` :normal! o````<CR>```<Esc>
	nnoremap <silent> <buffer> <unique> <LocalLeader>n :call <SID>todo_mark()<CR>
	nnoremap <silent> <buffer> <unique> <LocalLeader>N :call <SID>todo_clear_mark()<CR>
	nmap <buffer> <localleader>f <plug>focus_toggle
	inoremap <buffer> * **<Left>
	" TODO-[RM]-(Fri Oct 20 2017 05:24): Fix this thing here
	" inoremap <buffer> [ [ ]<Space>

	if exists(':InsertNewBullet')
		inoremap <buffer> <expr> <cr> pumvisible() ? "\<c-y>" : "<cr>"
		nnoremap <buffer> o :InsertNewBullet<cr>
	endif

	if exists(':Toc')
		nnoremap <buffer> <Leader>tt :Toc<cr>
	elseif exists(':TOC')
		nnoremap <buffer> <Leader>tt :TOC<cr>
	endif

	if exists(':LanguageToolCheck')
		nnoremap <buffer> <LocalLeader>c :LanguageToolCheck<cr>
	endif

	if exists(':ThesaurusQueryReplaceCurrentWord')
		nnoremap <buffer> <LocalLeader>a :ThesaurusQueryReplaceCurrentWord<cr>
	endif

	if executable('qpdfview')
		nnoremap <silent> <buffer> <Plug>preview :!qpdfview --unique --quiet %:r.pdf&<cr>
	endif

	if executable('SumatraPDF')
		nnoremap <silent> <buffer> <Plug>preview :!SumatraPDF %:r.pdf<cr>
	endif
endif

if exists('*AutoCorrect')
	call AutoCorrect()
	iuna si
	iuna Si
endif

if exists('g:loaded_surround')
	let b:surround_95 = "_\r_"
endif

" Advanced spelling checks for when writting documents and such
" Other tools should be enabled and disabled here
let s:spelling_toggle = 0
function! MdCheckSpelling() abort
	if exists('spelling_toggle') && s:spelling_toggle == 0
		if exists(':DittoOn')
			execute "DittoOn"
		endif

		if exists(':LanguageToolCheck')
			execute "LanguageToolCheck"
		endif
		let spelling_toggle = 1
	else
		if exists(':DittoOff')
			execute "DittoOff"
		endif

		if exists(':LanguageToolClear')
			execute "LanguageToolClear"
		endif
		let s:spelling_toggle = 0
	endif
endfunction

function! s:install_template() abort
	if has('win32')
		if !exists('g:std_config_path')
			echomsg 's:install_template(): g:std_config_path doesnt exist'
			return
		else
			let template_path = g:std_config_path . "\\pandoc\\templates\\eisvogel.latex"
		endif
	else
		" Sat Sep 16 2017 18:16:
		" Keyword: latex, pandoc, markdown, pdf, templates, arch, linux, texlive, packages
		" Note: This is the list of packages that this specific pandoc template depends on. In arch
		" there is no need to install the packages individually just `install texlive-most` and you
		" are all set
		" xecjk filehook unicode-math ucharcat pagecolor babel-german ly1 mweights sourcecodepro sourcesanspro
		" In the super weird case that you are missing some packages install texlive-localmanager-git
		" then you can do: `tllocalmgr install <pkg-name>
		let template_path = '~/.pandoc/templates/eisvogel.latex'
	endif

	if executable('curl')
		" TODO-[RM]-(Fri Sep 15 2017 16:51): Make function out of this
		execute "!curl -kfLo " . template_path . " --create-dirs
				\ https://raw.githubusercontent.com/Wandmalfarbe/pandoc-latex-template/master/eisvogel.tex"
	else
		echomsg 'curl not available. Cannot download templates'
	endif
endfunction

function! s:preview_browser() abort
	if !executable(g:browser_cmd)
		echoerr '[s:preview_browser]: Browser: ' . g:browser_cmd . ' not executable/found'
		return -1
	endif

	if has('win32')
		if exists('Dispatch') && exists('g:browser_cmd')
			execute "Dispatch " . g:browser_cmd . " %"
		else
			echomsg 'vim-dispatch not available'
		endif
	else
		execute "!" . g:browser_cmd . " %&"
	endif
endfunction

function! s:todo_mark() abort
	execute "normal! ^f[lrx\<Esc>"
endfunction

function! s:todo_clear_mark() abort
	execute "normal! ^f[lr\<Space>\<Esc>"
endfunction

command! -buffer UtilsWeeklyReportCreate call utils#ConvertWeeklyReport()
" Markdown fix _ showing red
command! -buffer UtilsFixUnderscore execute("%s/_/\\_/gc<CR>")
" TODO.RM-Thu May 18 2017 12:17: This should be changed to opera
command! -buffer UtilsMarkdownPreviewInBrowser call s:preview_browser()
command! -buffer UtilsMarkdownInstallPreview call s:install_template()
command! -buffer UtilsMarkdownSetPandocPdfMaker call linting#SetNeomakePandocMaker('pdf')
command! -buffer UtilsMarkdownSetPandocDocxMaker call linting#SetNeomakePandocMaker('docx')
command! -buffer UtilsMarkdownSetPandocHtmlMaker call linting#SetNeomakePandocMaker('html')
