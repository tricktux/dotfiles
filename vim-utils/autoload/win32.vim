" File:win32.vim
" Description:Settings exclusive for Windows
" Author:Reinaldo Molina <rmolin88@gmail.com>
" Version:1.0.0
" Last modified:Nov 29 2016 23:21

function! win32#Config()
	if exists('$ChocolateyInstall')
		let languagetool_jar = findfile('languagetool-commandline.jar', $ChocolateyInstall . '\lib\languagetool\tools\**2')
		if !empty('languagetool_jar')
			let g:languagetool_jar = languagetool_jar
		endif
	endif

	if filereadable('C:\Program Files\LLVM\share\clang\clang-format.py')
				\ && has('python') && executable('clang-format')
		let g:clang_format_py = 'C:\Program Files\LLVM\share\clang\clang-format.py'
	endif

	" Set wiki_path
	let wikis = ['D:\Seafile\KnowledgeIsPower\wiki', 'D:/wiki']
	for wiki in wikis
		if !empty(glob(wiki))
			let g:wiki_path =  wiki
			break
		endif
	endfor

	if !empty(glob('D:/wings-dev/'))
		call s:set_wings_path('D:/wings-dev/')
	endif

	" Fri Jan 05 2018 16:40: Many plugins use this now. Making these variables available
	" all the time.
	let pyt2 = "C:\\Python27\\python.exe"
	let pyt3 = [$LOCALAPPDATA . "\\Programs\\Python\\Python36\\python.exe", "C:\\Python36\\python.exe"]

	if filereadable(pyt2)
		let g:python_host_prog= pyt2
	endif

	for loc in pyt3
		if filereadable(loc)
			let g:python3_host_prog= loc
			break
		endif
	endfor

	let browsers = [ 'chrome.exe', 'launcher.exe', 'firefox.exe' ]
	let g:browser_cmd = ''
	for brow in browsers
		if executable(brow)
			let g:browser_cmd = brow
			break
		endif
	endfor
endfunction

function! s:set_wings_path(path) abort
	execute "nnoremap <Leader>ew1 :call utils#DeniteRec(\"" . a:path . "OneWings/\")<CR>"
	execute "nnoremap <Leader>ew2 :call utils#DeniteRec(\"" . a:path . "OneWINGSII/\")<CR>"
	execute "nnoremap <Leader>ews :call utils#DeniteRec(\"" . a:path . "OneWingsSupFiles/\")<CR>"
endfunction

