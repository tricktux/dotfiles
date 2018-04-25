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
		autocmd FileType help nnoremap <buffer> q :helpc<cr>
		autocmd FileType help setlocal relativenumber
		" Python
		" autocmd FileType python setlocal foldmethod=syntax
	augroup END

	" To improve syntax highlight speed. If something breaks with highlight
	" increase these number below
	" augroup vimrc
	" autocmd!
	" autocmd BufWinEnter,Syntax * syn sync minlines=80 maxlines=80
	" augroup END


	if exists("g:loaded_plugins")
		augroup VimType
			autocmd!
			" Sessions
			" Note: Fri Mar 03 2017 14:13 - This never works.
			" autocmd VimEnter * call utils#LoadSession('default.vim')
			" Thu Oct 05 2017 22:22: Special settings that are only detected after vim is loaded
			autocmd VimEnter * call s:on_vim_enter()
			autocmd VimLeave * call utils#SaveSession('default.vim')
			" Keep splits normalize
			autocmd VimResized * call utils#NormalizeWindowSize()
		augroup END

		augroup BuffTypes
			autocmd!
			autocmd BufNewFile * call s:determine_buf_type()
			autocmd BufReadPost * call ctags#LoadCscopeDatabse()
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
			autocmd TermOpen * setfiletype terminal
		augroup END
	else
		augroup Terminal
			autocmd!
			autocmd BufWinEnter * if &buftype == 'terminal' | setfiletype terminal | endif
		augroup END
	endif
endfunction

" Things to do after everything has being loaded
function! s:on_vim_enter() abort
	call options#SetCli()
	call plugin#AfterConfig()
endfunction

function! s:determine_buf_type() abort
	let ext = expand('%:e')
	if ext ==# 'ino' || ext ==# 'pde'
		setfiletype arduino
	elseif ext ==# 'scp'
		setfiletype wings_syntax
		" elseif ext ==# 'log'
		" setfiletype unreal-log
	elseif ext ==# 'set' || ext ==# 'sum'
		setfiletype dosini
	elseif ext ==# 'bin' || ext ==# 'pdf' || ext ==# 'hsr'
		call s:set_bin_file_type()
	endif

	" Remember last cursor position
	if line("'\"") > 0 && line("'\"") <= line("$") |
		exe "normal g`\"" |
	endif
endfunction

function! s:set_bin_file_type() abort
	let &l:bin=1
	%!xxd
	setlocal ft=xxd
	%!xxd -r
	setlocal nomodified
endfunction

