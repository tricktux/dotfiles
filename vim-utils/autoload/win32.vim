" File:win32.vim
" Description:Settings exclusive for Windows
" Author:Reinaldo Molina <rmolin88@gmail.com>
" Version:1.0.0
" Last modified:Nov 29 2016 23:21

function win32#Config()
	nnoremap <Leader>mr :!%<CR>
	" Copy and paste into system wide clipboard
	nnoremap <Leader>jp "*p=`]<C-o>
	vnoremap <Leader>jp "*p=`]<C-o>

	nnoremap <Leader>jy "*yy
	vnoremap <Leader>jy "*y

	nnoremap  o<Esc>

	" Mappings to execute programs
	" Do not make a ew1 mapping. reserved for when issues get to #11, 12, etc
	nnoremap <Leader>ewd :Start! WINGS.exe 3 . default.ini<CR>
	nnoremap <Leader>ewc :Start! WINGS.exe 3 . %<CR>
	nnoremap <Leader>ews :execute("Start! WINGS.exe 3 . " . input("Config file:", "", "file"))<CR>

	" e1 reserved for vimrc
	" Switch Wings mappings for SWTestbed
	nnoremap <Leader>es :call utils#SetWingsPath('D:/Reinaldo/')<CR>

	call utils#SetWingsPath('~/Documents/1.WINGS/')

	" Time runtime of a specific program
	nnoremap <Leader>mt :Dispatch powershell -command "& {&'Measure-Command' {.\sep_calc.exe seprc}}"<CR>
	nnoremap <Leader>mu :call utils#UpdateBorlandMakefile()<CR>

	if isdirectory('C:\maxapi')
		let &path .= 'C:\maxapi,'
	endif
endfunction

" vim:tw=78:ts=2:sts=2:sw=2:
