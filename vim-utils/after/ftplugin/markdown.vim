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
" makes vim autocomplete - bullets
setlocal comments+=b:-,b:*
setlocal formatoptions+=aw

if !exists("no_plugin_maps") && !exists("no_markdown_maps")
	" TODO-[RM]-(Fri Oct 20 2017 08:50): Fix this code commented here below
	" Encapsulate in markdown file from current line until end of file in ```
	" nnoremap <buffer> <unique> <LocalLeader>` :normal! o````<CR>```<Esc>
	nnoremap <buffer> <unique> <LocalLeader>n :call utils#TodoMark()<CR>
	nnoremap <buffer> <unique> <LocalLeader>N :call utils#TodoClearMark()<CR>
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

	if exists(':OnlineThesaurusCurrentWord')
		nnoremap <buffer> <LocalLeader>a :OnlineThesaurusCurrentWord<cr>
	endif

	if executable('pandoc') && !has('unix')
		" nnoremap <buffer> <Plug>Make :!pandoc % -o %:r.pdf --from markdown --template eisvogel --listings<CR>
		nnoremap <buffer> <Plug>Make :!pandoc % -o %:r.docx -r markdown+simple_tables+table_captions+yaml_metadata_block -S -s <CR>
	endif

	if executable('zathura')
		nnoremap <buffer> <Plug>Preview :!zathura %:r.pdf&<CR>
	endif

	if exists(':Neomake')
		let b:neomake_markdown_enabled_makers = ['make']
		let b:neomake_markdown_make_args = ['%:t:r.pdf']
		let b:neomake_markdown_make_append_file = 0
	endif
endif

if exists('*AutoCorrect')
	call AutoCorrect()
	" Tue Dec 26 2017 16:40: These abbreviations are really annoying when typing in
	" spanish. Delete them.
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

function! MdInstallTemplate() abort
	if has('win32')
		if !exists('g:std_config_path')
			echomsg 'MdInstallTemplate(): g:std_config_path doesnt exist'
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

function! MdPreviewInBrowser() abort
	if !executable(g:browser_cmd)
		echoerr '[MdPreviewInBrowser]: Browser: ' . g:browser_cmd . ' not executable/found'
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

command! -buffer UtilsWeeklyReportCreate call utils#ConvertWeeklyReport()
" Markdown fix _ showing red
command! -buffer UtilsFixUnderscore execute("%s/_/\\_/gc<CR>")
" TODO.RM-Thu May 18 2017 12:17: This should be changed to opera
command! -buffer UtilsPreviewMarkdown call MdPreviewInBrowser()
command! -buffer UtilsInstallMarkdownPreview call MdInstallTemplate()

let b:undo_ftplugin = "setl foldenable< spell< complete< ts< sw< sts< comments< formatoptions<"
