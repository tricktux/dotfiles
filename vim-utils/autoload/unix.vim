" File:unix.vim
" Description:Unix exclusive settings
" Author:Reinaldo Molina <rmolin88@gmail.com>
" Version:1.0.0
" Last modified:Nov 29 2016 23:26

function! unix#Config() abort
	" System paste
	nnoremap <Leader>jp "+p=`]<C-o>
	vnoremap <Leader>jp "+p=`]<C-o>

	nnoremap <Leader>jy "+yy
	vnoremap <Leader>jy "+y

	" edit android
	nnoremap <Leader>ea :silent e
				\ ~/Documents/seafile-client/Seafile/KnowledgeIsPower/udacity/android-projects/
	" edit odroid
	nnoremap <Leader>eo :silent e ~/.mnt/truck-server/Documents/NewBot_v3/
	" edit bot
	nnoremap <Leader>eb :silent e ~/Documents/NewBot_v3/
	" Edit HQ
	nnoremap <Leader>eh :silent e ~/.mnt/HQ-server/
	" Edit Copter
	nnoremap <Leader>ec :silent e ~/.mnt/copter-server/
	" Edit Truck
	nnoremap <Leader>et :silent e ~/.mnt/truck-server/
	nnoremap <CR> o<ESC>

	if !exists('g:portable_vim')
		let g:vimfile_path=  $XDG_CONFIG_HOME . '/vim/'
	endif

	let g:cache_path= $XDG_CACHE_HOME . '/'
	let g:plugged_path=  g:vimfile_path . 'plugged/'

	" VIM_PATH includes
	" With this you can use gf to go to the #include <avr/io.h>
	" also this path below are what go into the .syntastic_avrgcc_config
	let g:usr_path = '/usr'
	if system('uname -o') =~ 'Android' " Termux stuff
		let g:android = 1
		let g:usr_path = $HOME . '/../usr'
	endif
	let &path .= g:usr_path . '/local/include,'
	let &path .= g:usr_path . '/include,'
	if !empty(glob('/opt/unreal-engine/Engine/Source'))
		let &path .= '/opt/unreal-engine/Engine/Source'
	endif

	let l:hostname = system('hostname')
	if l:hostname =~ 'beast'
		let g:wiki_path=  $HOME . '/Seafile/OnServer/KnowledgeIsPower/wiki'
	elseif l:hostname =~ 'predator'
		let g:wiki_path=  $HOME . '/Seafile/KnowledgeIsPower/wiki'
	elseif l:hostname =~ 'guajiro'
		let g:wiki_path=  $HOME . '/Documents/Seafile/KnowledgeIsPower/wiki'
	else " Some default location
		let g:wiki_path=  $HOME . '/Documents/Seafile/KnowledgeIsPower/wiki'
	endif

	" deoplete-clang settings
	if !empty(glob('/usr/lib/libclang.so'))
		let g:libclang_path = '/usr/lib/libclang.so'
	endif
	if !empty(glob('/usr/lib/clang'))
		let g:clangheader_path = '/usr/lib/clang'
	endif

	" This mapping will load the journal from the most recent boot and highlight it for you
	command! UtilsLinuxReadJournal execute("read !journalctl -b<CR><bar>:setf messages<CR>")
	" Give execute permissions to current file
	command! UtilsLinuxExecReadPermissions execute("!chmod a+x %")
	" Save file with sudo permissions
	command! UtilsLinuxSudoPermissions execute("w !sudo tee % > /dev/null")
	command! UtilsLinuxExecuteCurrFile execute("silent !./%")
endfunction

" vim:tw=78:ts=2:sts=2:sw=2:
