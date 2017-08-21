
function augroup#Set() abort
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
		autocmd FileType help :nnoremap <buffer> q ZZ
		" wrap syntastic messages
		autocmd FileType mail setlocal wrap
		autocmd FileType mail setlocal spell spelllang=es,en
		autocmd FileType mail setlocal omnifunc=muttaliases#CompleteMuttAliases
		" Python
		" autocmd FileType python setlocal foldmethod=syntax
		autocmd FileType help setlocal relativenumber
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
	endif

	" vim -b : edit binary using xxd-format!
	" using let &l:option_name is the same as setlocal
	augroup Binary
		au!
		au BufReadPre  *.bin,*.hsr,*.pdf let &l:bin=1
		au BufReadPost *.bin,*.hsr,*.pdf if &bin | %!xxd
		au BufReadPost *.bin,*.hsr,*.pdf setlocal ft=xxd | endif
		au BufWritePre *.bin,*.hsr,*.pdf if &bin | %!xxd -r
		au BufWritePre *.bin,*.hsr,*.pdf endif
		au BufWritePost *.bin,*.hsr,*.pdf if &bin | %!xxd
		au BufWritePost *.bin,*.hsr,*.pdf setlocal nomod | endif
	augroup END

	" Depends on autoread being set
	augroup AutoRead
		autocmd!
		autocmd CursorHold * silent! checktime
	augroup END

	if has('nvim')
		augroup Terminal
			autocmd!
			autocmd TermOpen * setlocal nonumber
		augroup END
	endif
endfunction

" vim:tw=78:ts=2:sts=2:sw=2:
