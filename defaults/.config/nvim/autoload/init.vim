" File:					init.vim
" Description:	Main file that call configuration functions
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:				0.0.0
" Last Modified: Aug 21 2017 16:15
" Created: Aug 21 2017 16:15

" Global variables used by configuration
" - g:loaded_plugins: Used to validate that we have found dotfiles and loaeded 
"   plugins
" - g:valid_device: Used to mark that is a device were we develop a lot and has 
"   fonts
"   for lightline to be pretty

function! init#vim() abort
	" Needs to be defined before the first <Leader>/<LocalLeader> is used
	" otherwise it goes to "\"
	let g:mapleader="\<Space>"
	let g:maplocalleader="g"
	" Mon Oct 30 2017 15:24: Patched fonts depend on this option. It also needs
	" to be here. Otherwise Alt mappings stop working
	set encoding=utf-8

	" OS_SETTINGS
	if has('unix') | call s:config_unix() | else | call s:config_win() | endif

	" PLUGINS_INIT
	if plugin#Config()
		let g:loaded_plugins = 1
	else
		echomsg 'No plugins were loaded'
	endif

  " Sun Aug 30 2020 01:14: 
  "  Load lua modules. Commencement of lua awesomeness
  "  Lua plugin modules are not loaded until after plug#end(). See lua-require
  "  All lua configs are called from 'config/init.lua' which is sourced below
  if has('nvim-0.5')
    lua require('config')
  endif
	" Create required folders for storing usage data
	call utils#CheckDirWoPrompt(g:std_data_path . '/sessions')
	call utils#CheckDirWoPrompt(g:std_data_path . '/ctags')
	" Backups
	call utils#CheckDirWoPrompt(g:std_cache_path . '/backup')
	call utils#CheckDirWoPrompt(g:std_cache_path . '/swap')
	call utils#CheckDirWoPrompt(g:std_cache_path . '/undofiles')

  call mappings#Set()
  call options#Set()
  call augroup#Set()
  call commands#Set()
endfunction

function! s:config_win() abort
	if exists('$ChocolateyInstall')
		let l:languagetool_jar = findfile('languagetool-commandline.jar',
					\ expand('$ChocolateyInstall') . '\lib\languagetool\tools\**2')
		if !empty(l:languagetool_jar)
			let g:languagetool_jar = l:languagetool_jar
		endif
	endif

	if filereadable(expand('$ProgramFiles') . '\LLVM\share\clang\clang-format.py')
				\ && has('python') && executable('clang-format')
		let g:clang_format_py = expand('$ProgramFiles') .
					\ '\LLVM\share\clang\clang-format.py'
	endif

	" Set wiki_path
	let l:wikis = ['D:\Seafile\KnowledgeIsPower\wiki',
				\ 'D:\wiki',
				\ 'D:\Reinaldo\Documents\src\resilio\wiki']
	for l:wiki in l:wikis
		if !empty(glob(l:wiki))
			let g:wiki_path =  l:wiki
			" Fri Jul 27 2018 16:01: Gvim is the only one that sets this. Dont use 
			" cute symbols. No cute font support. 
			" let g:valid_device = 1
			break
		endif
	endfor

	" if executable('cmder') && has('terminal')
		" let &shell=fnameescape('cmd.exe /k c:\tools\cmder\vendor\init.bat')
	" endif

	if !empty(glob('D:/wings-dev/'))
		call s:set_wings_path('D:/wings-dev/')
	endif

  call s:find_python()

	if !has('nvim')
		set pyxversion=3
	endif

	let l:browsers = [ 'chrome.exe', 'launcher.exe', 'firefox.exe' ]
	let g:browser_cmd = ''
	for l:brow in l:browsers
		if executable(l:brow)
			let g:browser_cmd = l:brow
			break
		endif
	endfor

	" Thu Sep 20 2018 13:35:
	"		Sometimes I like to put extra executables inside this folder below.
	"		Check it for any easter eggs 
	let l:extra_path = glob($VIMRUNTIME . '\utils\*', 1, 1)
	" Look for MSBuild.exe. Pretty hard coded I know. But findfile didnt work.
	if filereadable("c:\\Program Files (x86)\\MSBuild\\14.0\\Bin\\MSBuild.exe")
		call add(l:extra_path, "c:\\Program Files (x86)\\MSBuild\\14.0\\Bin\\")
	endif
	if !empty(glob("C:\\Program Files\\Git\\usr\\bin"))
		call add(l:extra_path, "C:\\Program Files\\Git\\usr\\bin")
	endif

	for l:path in l:extra_path
		let $PATH .= ';' . l:path
	endfor	
endfunction

function! s:set_wings_path(path) abort
	execute "nnoremap <Leader>ew1 :call utils#PathFileFuzzer(\"" . 
				\ a:path . "src/\OneWings/\")<cr>"
	execute "nnoremap <Leader>ew2 :call utils#PathFileFuzzer(\"" . 
				\ a:path . "src/\OneWINGS2/\")<cr>"
	execute "nnoremap <Leader>ews :call utils#PathFileFuzzer(\"" . 
				\ a:path . "config/\OneWingsSupFiles/\")<cr>"
	execute "nnoremap <Leader>ewa :call utils#PathFileFuzzer(\"" . 
				\ a:path . "src\")<cr>"
	execute "nnoremap <silent> <plug>edit_todo :edit " . 
				\ (exists('g:wiki_path') ? g:wiki_path : '') .
				\ "/work/TODO.md<cr>"
endfunction

function! s:config_unix() abort
	" VIM_PATH includes
	let sys_name = system('uname -o') " Termux stuff

	if sys_name =~# 'Android'
		let g:android = 1
		let g:usr_path = $HOME . '/../usr'
	endif

	let l:wikis = [
        \ '~/Documents/wiki', 
        \ '~/External/reinaldo/resilio/wiki',
        \ '/mnt/samba/server/resilio/wiki',
        \ ]
	for l:wiki in l:wikis
		if !empty(glob(l:wiki))
			let g:wiki_path =  expand(l:wiki)
			" let g:valid_device = 1
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

	if executable('languagetool') && 
		\ !empty(glob('/usr/bin/languagetool'))
		let g:languagetool_jar = 
					\ '/usr/bin/languagetool'
	endif
	let g:browser_cmd = '/usr/bin/firefox'
endfunction

function! s:find_python() abort
  for l:ver in range(50, 33, -1)
    let l:ver = string(l:ver) 
    let l:loc = [
          \ $VIMRUNTIME . '\utils\python-' . l:ver . '-embed-amd64\python.exe',
          \ $LOCALAPPDATA . "\\Programs\\Python\\Python" . l:ver . "\\python.exe",
          \ "C:\\Python" . l:ver . "\\python.exe",
          \ ]

    for l:path in l:loc
      if filereadable(l:path)
        let g:python3_host_prog= l:path
        return
      endif
    endfor
  endfor
endfunction

