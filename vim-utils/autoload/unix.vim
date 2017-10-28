" File:unix.vim
" Description:Unix exclusive settings
" Author:Reinaldo Molina <rmolin88@gmail.com>
" Version:1.0.0
" Last modified:Nov 29 2016 23:26

function! unix#Config() abort
	" System paste
	nnoremap <Leader>p "+p=`]<C-o>
	vnoremap <Leader>p "+p=`]<C-o>

	nnoremap <Leader>y "+yy
	vnoremap <Leader>y "+y

	nnoremap <Leader>ec :call utils#DeniteRec(g:std_config_path)<CR>
	nnoremap  o<Esc>

	" VIM_PATH includes
	" With this you can use gf to go to the #include <avr/io.h>
	" also this path below are what go into the .syntastic_avrgcc_config
	let g:usr_path = '/usr'
	let hostname = system('hostname')
	let sys_name = system('uname -o') " Termux stuff

	if sys_name =~# 'Android'
		let g:android = 1
		let g:usr_path = $HOME . '/../usr'
	elseif sys_name =~# 'Cygwin'
		let g:system_name = 'cygwin'
		if exists('$USERNAME') && $USERNAME =~? '^h' " Assume work pc
			let g:wiki_path =  '/cygdrive/d/wiki'
			let g:wings_path =  '/cygdrive/d/wings-dev/'
			call utils#SetWingsPath(g:wings_path)
		endif
	elseif hostname =~ 'beast'
		let g:wiki_path=  $HOME . '/Seafile/OnServer/KnowledgeIsPower/wiki'
	elseif hostname =~ 'predator'
		let g:wiki_path=  $HOME . '/Seafile/KnowledgeIsPower/wiki'
	elseif hostname =~ 'guajiro'
		let g:wiki_path=  $HOME . '/Documents/Seafile/KnowledgeIsPower/wiki'
	else " Some default location
		let g:wiki_path=  $HOME . '/Documents/Seafile/KnowledgeIsPower/wiki'
	endif

	let &path .= g:usr_path . '/local/include,'
	let &path .= g:usr_path . '/include,'
	if !empty(glob('/opt/unreal-engine/Engine/Source'))
		let &path .= '/opt/unreal-engine/Engine/Source'
	endif

	" deoplete-clang settings
	if !empty(glob('/usr/lib/libclang.so'))
		let g:libclang_path = '/usr/lib/libclang.so'
	elseif !empty(glob('/usr/lib/libclang.dll.a'))
		let g:libclang_path = '/usr/lib/libclang.dll.a'
	endif
	if !empty(glob('/usr/lib/clang'))
		let g:clangheader_path = '/usr/lib/clang'
	endif

	if executable('languagetool') 
				\&& !empty(glob('/usr/share/java/languagetool/languagetool-commandline.jar'))
		let g:languagetool_jar = '/usr/share/java/languagetool/languagetool-commandline.jar'
	endif
	let g:browser_cmd = '/usr/bin/opera'

	" This mapping will load the journal from the most recent boot and highlight it for you
	command! UtilsLinuxReadJournal execute("read !journalctl -b<CR><bar>:setf messages<CR>")
	" Give execute permissions to current file
	command! UtilsLinuxExecReadPermissions execute("!chmod a+x %")
	" Save file with sudo permissions
	command! UtilsLinuxSudoPermissions execute("w !sudo tee % > /dev/null")
	command! UtilsLinuxExecuteCurrFile execute("silent !./%")
endfunction

" vim:tw=78:ts=2:sts=2:sw=2:
