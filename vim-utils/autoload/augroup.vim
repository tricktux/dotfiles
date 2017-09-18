" File:					augroup.vim
" Description:	All autogroup should be group here. Unless it makes more sense
"								with some plugin
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:				0.0.0
" Last Modified: Aug 24 2017 16:25
" Created: Aug 24 2017 16:25

function! augroup#Set() abort
	" ALL_AUTOGROUP_STUFF
	" All of these options contain performance drawbacks but the most important
	" is foldmethod=syntax
	augroup Filetypes
		autocmd!
		" Nerdtree Fix
		autocmd FileType nerdtree setlocal relativenumber
		" Set omnifunc for all others 									" not showing
		autocmd FileType cs compiler msbuild
		" Latex
		autocmd FileType tex setlocal spell spelllang=en_us
		autocmd FileType tex compiler tex
		" Display help vertical window not split
		autocmd FileType help wincmd L
		autocmd FileType help nnoremap <buffer> q ZZ
		autocmd FileType help setlocal relativenumber
		" wrap syntastic messages
		autocmd FileType mail setlocal wrap
		autocmd FileType mail setlocal spell spelllang=es,en
		autocmd FileType mail setlocal omnifunc=muttaliases#CompleteMuttAliases
		" Python
		" autocmd FileType python setlocal foldmethod=syntax
	augroup END

	" To improve syntax highlight speed. If something breaks with highlight
	" increase these number below
	" augroup vimrc
	" autocmd!
	" autocmd BufWinEnter,Syntax * syn sync minlines=80 maxlines=80
	" augroup END


	if exists("g:plugins_loaded")
		augroup VimType
			autocmd!
			" Sessions
			" Note: Fri Mar 03 2017 14:13 - This never works.
			" autocmd VimEnter * call utils#LoadSession('default.vim')
			autocmd VimLeave * call utils#SaveSession('default.vim')
			" Keep splits normalize
			autocmd VimResized * call utils#NormalizeWindowSize()
		augroup END

		augroup BuffTypes
			autocmd!
			autocmd BufNewFile,BufReadPost * call utils#BufDetermine()
		augroup END

		augroup FluxLike
			autocmd!
			autocmd VimEnter,BufEnter * call utils#Flux()
		augroup END
	endif

	" Depends on autoread being set
	augroup AutoRead
		autocmd!
		autocmd CursorHold * silent! checktime
	augroup END

	if has('nvim')
		augroup Terminal
			autocmd!
			autocmd TermOpen * setlocal nonumber | setfiletype terminal
		augroup END
	endif
endfunction

" vim:tw=78:ts=2:sts=2:sw=2:
