" File:unix.vim
" Description:Unix exclusive settings
" Author:Reinaldo Molina <rmolin88@gmail.com>
" Version:1.0.0
" Last modified:Nov 29 2016 23:26

function! unix#Config() abort
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
