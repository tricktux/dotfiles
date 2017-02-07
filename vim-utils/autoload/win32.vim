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

	" Set wiki_path
	if system('hostname') =~ 'predator' " homepc
		let g:wiki_path =  'D:\Seafile\KnowledgeIsPower\wiki'
		nnoremap <Leader>eu :e D:/Reinaldo/Documents/UnrealProjects/
	else " Assume work pc
		let g:wiki_path =  'D:/wings-dev/OneWingsSupFiles/wiki'
		call utils#SetWingsPath('D:/wings-dev/')
	endif
endfunction

" vim:tw=78:ts=2:sts=2:sw=2:
