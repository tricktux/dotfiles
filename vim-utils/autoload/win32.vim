" File:win32.vim
" Description:Settings exclusive for Windows
" Author:Reinaldo Molina <rmolin88@gmail.com>
" Version:1.0.0
" Last modified:Nov 29 2016 23:21

function win32#Config()
	nnoremap <Leader>mr :Start! %<CR>
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
		let l:pyt3 = $userprofile . "\\AppData\\Local\\Programs\\Python\\Python36\\python.exe"
	else " Assume work pc
		let l:pyt3 = "C:\\Python36\\python.exe"
		let g:wiki_path =  'D:/wings-dev/OneWingsSupFiles/wiki'
		let g:wings_path =  'D:/wings-dev/'
		call utils#SetWingsPath(g:wings_path)

		" Load svnj branch, trunk, and tag settings
		if filereadable(g:wings_path . 'OneWingsSupFiles/branches.vim')
			exe 'source ' . g:wings_path . 'OneWingsSupFiles/branches.vim' 
		endif
	endif

	if has('nvim')
		let l:pyt2 = "C:\\Python27\\python.exe"
		if filereadable(l:pyt3)
			let g:python3_host_prog= l:pyt3
		endif
		if filereadable(l:pyt2)
			let g:python_host_prog= l:pyt2
		endif
	endif
endfunction

" vim:tw=78:ts=2:sts=2:sw=2:
