" File:					markdown.vim
" Description:	After default ftplugin for markdown
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:			1.0.0
" Last Modified: Sat Jul 29 2017 07:44
" Created:					Wed Nov 30 2016 11:02

" Only do this when not done yet for this buffer
if exists("b:did_texftplugin")
	finish
endif

" Don't load another plugin for this buffer
let b:did_texftplugin = 1

if !exists("no_plugin_maps") && !exists("no_tex_maps")
	" TODO-[RM]-(Fri Oct 20 2017 08:50): Fix this code commented here below
	" Encapsulate in markdown file from current line until end of file in ```
	" nnoremap <buffer> <unique> <LocalLeader>` :normal! o````<CR>```<Esc>
	nmap <buffer> <localleader>f <plug>focus_toggle
	xnoremap <buffer> j gj
	xnoremap <buffer> k gk

	if (exists(':Neomake'))
		nnoremap <buffer> <plug>make_file :Neomake<cr>
	endif

	if exists(':ThesaurusQueryReplaceCurrentWord')
		nnoremap <buffer> <localLeader>a :ThesaurusQueryReplaceCurrentWord<cr>
	endif

	if executable('SumatraPDF')
		nnoremap <silent> <buffer> <plug>preview :!SumatraPDF %:r.pdf<cr>
	endif

	if executable('qpdfview')
		nnoremap <silent> <buffer> <plug>preview
					\ :!qpdfview --unique --quiet %:r.pdf&<cr>
	endif

endif

let b:tex_flavor = 'pdflatex'
let &l:makeprg='pdflatex -interaction=nonstopmode %'

if exists('*AutoCorrect')
	call AutoCorrect()
	iuna si
	iuna Si
endif
