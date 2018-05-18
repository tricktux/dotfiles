" File:					init.vim
" Description:	Main file that call configuration functions
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:				0.0.0
" Last Modified: Aug 21 2017 16:15
" Created: Aug 21 2017 16:15

function! init#vim() abort
	" Needs to be defined before the first <Leader>/<LocalLeader> is used
	" otherwise it goes to "\"
	let g:mapleader="\<Space>"
	let g:maplocalleader="g"
	" Mon Oct 30 2017 15:24: Patched fonts depend on this option. It also needs
	" to be here. Otherwise Alt mappings stop working
	set encoding=utf-8

	" OS_SETTINGS
	execute 'call ' . (has('unix') ? 's:config_unix()' : 's:config_win()')

	" PLUGINS_INIT
	if plugin#Config()
		let g:loaded_plugins = 1
	else
		echomsg 'No plugins were loaded'
	endif

	" Create required folders for storing usage data
	call utils#CheckDirWoPrompt(g:std_data_path . '/sessions')
	call utils#CheckDirWoPrompt(g:std_data_path . '/ctags')

	call mappings#Set()
	call options#Set()
	call augroup#Set()
	call commands#Set()
endfunction

function! s:config_win()
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

function! s:config_unix() abort
	" VIM_PATH includes
	let hostname = system('hostname')
	let sys_name = system('uname -o') " Termux stuff

	if sys_name =~# 'Android'
		let g:android = 1
		let g:usr_path = $HOME . '/../usr'
	endif

	let wikis = ['~/Seafile/KnowledgeIsPower/wiki', '~/Documents/Seafile/KnowledgeIsPower/wiki']
	for wiki in wikis
		if !empty(glob(wiki))
			let g:wiki_path =  wiki
			break
		endif
	endfor

	" With this you can use gf to go to the #include <avr/io.h>
	" also this path below are what go into the .syntastic_avrgcc_config
	let g:usr_path = '/usr'
	let &path .= g:usr_path . '/local/include,'
	let &path .= g:usr_path . '/include,'
	if !empty(glob('/opt/unreal-engine/Engine/Source'))
		let &path .= '/opt/unreal-engine/Engine/Source'
	endif

	" Clang library location
	let clang_libs = ['/usr/lib/libclang.so', '/usr/lib/libclang.dll.a']
	for lib in clang_libs
		if !empty(glob(lib))
			let g:libclang_path = lib
			break
		endif
	endfor

	if executable('languagetool')
				\&& !empty(glob('/usr/share/java/languagetool/languagetool-commandline.jar'))
		let g:languagetool_jar = '/usr/share/java/languagetool/languagetool-commandline.jar'
	endif
	let g:browser_cmd = '/usr/bin/opera'
endfunction
