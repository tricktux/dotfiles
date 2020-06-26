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

let b:ncm2_look_enabled = 1

if !exists('no_plugin_maps') && !exists('no_markdown_maps')
	" TODO-[RM]-(Fri Oct 20 2017 08:50): Fix this code commented here below
	" Encapsulate in markdown file from current line until end of file in ```
	" nnoremap <buffer> <unique> <LocalLeader>` :normal! o````<CR>```<Esc>
	nmap <buffer> <localleader>f <plug>focus_toggle
	inoremap <buffer> * **<Left>
	xnoremap <buffer> j gj
	xnoremap <buffer> k gk

	if (exists(':Neomake'))
		nnoremap <buffer> <plug>make_file :Neomake<cr>
	endif

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
		nnoremap <buffer> <localLeader>a :ThesaurusQueryReplaceCurrentWord<cr>
	endif

  if exists(':OnlineThesaurusCurrentWord')
    nnoremap <buffer> <localLeader>a :OnlineThesaurusCurrentWord<cr>
  endif

	if executable('SumatraPDF')
		nnoremap <silent> <buffer> <plug>preview :!SumatraPDF %:r.pdf<cr>
	endif

	if executable('qpdfview')
		nnoremap <silent> <buffer> <plug>preview :!qpdfview --unique --quiet %:r.pdf&<cr>
	endif

	nnoremap <buffer> <localleader>mp :UtilsMarkdownPandocPdfMaker<cr>
	nnoremap <buffer> <localleader>md :UtilsMarkdownPandocDocxMaker<cr>
	nnoremap <buffer> <localleader>mh :UtilsMarkdownPandocHtmlMaker<cr>
	nnoremap <buffer> <localleader>ms :UtilsMarkdownPandocPdfSlidesMaker<cr>
	nnoremap <buffer> <localleader>mx :UtilsMarkdownPandocPptxSlidesMaker<cr>

  let b:AutoPairs = {'(':')', '{':'}',"'":"'",'"':'"', '`':'`', '<': '>'}
  inoremap [ [ ]

  " Super cool
	nmap <localleader>ti <plug>todo_insert
	nmap <localleader>tb <plug>todo_block
	nmap <localleader>tc <plug>todo_completed
	nmap <localleader>tw <plug>todo_wont_do
	nmap <localleader>td <plug>todo_delete_mark

	nnoremap <buffer> <plug>todo_insert      :call <sid>todo_mark('o')<bar>
				\ silent! call repeat#set("\<lt>Plug>todo_insert")<cr>
	nnoremap <buffer> <plug>todo_block       :call <sid>todo_mark('x')<bar>
				\ silent! call repeat#set("\<lt>Plug>todo_block")<cr>
	nnoremap <buffer> <plug>todo_completed   :call <sid>todo_mark('+')<bar>
				\ silent! call repeat#set("\<lt>Plug>todo_completed")<cr>
	nnoremap <buffer> <plug>todo_wont_do     :call <sid>todo_mark('-')<bar>
				\ silent! call repeat#set("\<lt>Plug>todo_wont_do")<cr>
	nnoremap <buffer> <plug>todo_delete_mark :call <sid>todo_mark(' ')<bar>
				\ silent! call repeat#set("\<lt>Plug>todo_delete_mark")<cr>

	nmap <localleader>b <plug>todo_block
	nnoremap <buffer> <plug>bold_current_word_si :call <sid>bold_current_word()<bar>
				\ silent! call repeat#set("\<lt>Plug>bold_current_word_si")<cr>

	vmap <localleader>b <plug>bold_visual_word
	vnoremap <buffer> <plug>bold_visual_word :call <sid>bold_word()<bar>
				\ silent! call repeat#set("\<lt>Plug>bold_visual_word", v:count)<cr>

	nnoremap ]f <Plug>Markdown_EditUrlUnderCursor
endif

function! s:bold_current_word() abort
	execute "normal viwS*"
	execute "normal gvS*"
endfunction

function! s:bold_word() abort
	execute "normal gvS*"
	execute "normal gvS*"
endfunction

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
function! s:mdcheckspelling() abort
	if exists('spelling_toggle') && s:spelling_toggle == 0
		if exists(':DittoOn')
			execute 'DittoOn'
		endif

		if exists(':LanguageToolCheck')
			execute 'LanguageToolCheck'
		endif
		let spelling_toggle = 1
	else
		if exists(':DittoOff')
			execute 'DittoOff'
		endif

		if exists(':LanguageToolClear')
			execute 'LanguageToolClear'
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
			let template_path = g:std_config_path . "\\..\\pandoc\\templates\\eisvogel.latex"
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

	let l:link = 'https://raw.githubusercontent.com/Wandmalfarbe/pandoc-latex-template/master/eisvogel.tex'
	if utils#CurlDown(template_path, l:link) != 1
		echomsg 'Failed to download templates'
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

function! s:todo_mark(mark) abort
	let save_cursor = getcurpos()
	execute "normal! ^f[lr" . a:mark . "\<Esc>"
	return setpos('.', save_cursor)
endfunction

" function! s:todo_clear_mark() abort
	" execute "normal! ^f[lr\<Space>\<Esc>"
" endfunction

" Wed Dec 12 2018 17:13:
" By default the pdf maker is enabled.
" This is not optimal since sometimes you dont want a pdf
" From now on since we have easier mappings, just enable whatever maker you need
" You can do this by calling one of the commands.
" call linting#SetNeomakePandocMaker('pdf')

command! -buffer UtilsWeeklyReportCreate call utils#ConvertWeeklyReport()
" Markdown fix _ showing red
command! -buffer UtilsFixUnderscore execute("%s/_/\\_/gc<CR>")
" TODO.RM-Thu May 18 2017 12:17: This should be changed to opera
command! -buffer UtilsMarkdownPreviewInBrowser call s:preview_browser()
command! -buffer UtilsMarkdownInstallTemplate call s:install_template()
command! -buffer UtilsMarkdownPandocPdfMaker call linting#SetNeomakePandocMaker('pdf')
command! -buffer UtilsMarkdownPandocDocxMaker call linting#SetNeomakePandocMaker('docx')
command! -buffer UtilsMarkdownPandocHtmlMaker call linting#SetNeomakePandocMaker('html')
command! -buffer UtilsMarkdownPandocPdfSlidesMaker call linting#SetNeomakePandocMaker('pdf_slides')
command! -buffer UtilsMarkdownPandocPptxSlidesMaker call linting#SetNeomakePandocMaker('pptx_slides')
