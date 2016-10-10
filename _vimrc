" File:					_vimrc
" Description:  Vim/Neovim configuration file
" Author:				Reinaldo Molina
" Version:			2.1.0
" Date:					Wed Oct 05 2016 10:58 	
" Improvements:
"		" - Figure out how to handle Doxygen
		" - [ ] Markdown tables
		" - [ ] make mail ft grab autocomplete from alias.sh
		" - [ ] Fix GlobalSearch()
		" - [ ] Customize Doxygen options or find replacement
		" - [ ] Customize and install vim-formatter
		
" REQ AND LEADER
	set nocompatible
	syntax on
	filetype plugin indent on
	" moved here otherwise conditional mappings get / instead ; as leader
	let mapleader="\<Space>"
	let maplocalleader="\<Space>"

" WINDOWS_SETTINGS
	if has('win32')
		" Path variables
		let s:cache_path= $HOME . '\.cache\'
		let s:plugged_path=  $HOME . '\vimfiles\plugged\'
		let s:vimfile_path=  $HOME . '\vimfiles\'
		let s:wiki_path =  $HOME . '\Documents\1.WINGS\NeoWingsSupportFiles\wiki'
		let s:custom_font =  'consolas:h8'

		if !has('gui_running')
			set term=xterm
			let &t_AB="\e[48;5;%dm"
			let &t_AF="\e[38;5;%dm"
		endif

		" update cscope and ctags
		noremap <Leader>tu :cs kill -1<CR>
		\:silent !del /F cscope.files cscope.in.out cscope.po.out cscope.out<CR>
		\:silent !dir /b /s *.cpp *.h *.hpp *.c *.cc > cscope.files<CR>
		\:!cscope -b -q -i cscope.files<CR>
		\:silent !ctags -R -L cscope.files -f tags<CR>
		\:cs add cscope.out<CR>

		noremap <Leader>mr :!%<CR>
		" Copy and paste into system wide clipboard
		nnoremap <Leader><Space>v "*p
		nnoremap <Leader><Space>y "*y
		vnoremap <Leader><Space>y "*y

		nnoremap <Leader><Space>= :silent! let &guifont = substitute(
		\ &guifont,
		\ ':h\zs\d\+',
		\ '\=eval(submatch(0)+1)',
		\ '')<CR>
		nnoremap <Leader><Space>- :silent! let &guifont = substitute(
		\ &guifont,
		\ ':h\zs\d\+',
		\ '\=eval(submatch(0)-1)',
		\ '')<CR>

		nnoremap  o<Esc>

		" Mappings to execute programs
		" Do not make a ew1 mapping. reserved for when issues get to #11, 12, etc
		nnoremap <Leader>ewd :Start! WINGS.exe 3 . default.ini<CR>
		nnoremap <Leader>ewc :Start! WINGS.exe 3 . %<CR>
		nnoremap <Leader>ews :execute("Start! WINGS.exe 3 . " . input("Config file:", "", "file"))<CR>
		nnoremap <Leader>ewl :silent !del default.ini<CR>
							\:!mklink default.ini

		" e1 reserved for vimrc
		function! s:SetWingsPath(sPath) abort
			execute "nnoremap <Leader>e21 :silent e " . a:sPath . "NeoOneWINGS/"
			execute "nnoremap <Leader>e22 :silent e " . a:sPath
			execute "nnoremap <Leader>ed :silent e ". a:sPath . "NeoOneWINGS/default.ini<CR>"
		endfunction

		" Switch Wings mappings for SWTestbed
		nnoremap <Leader>es :call <SID>SetWingsPath('D:/Reinaldo/')<CR>
		" Default Wings mappings are for laptop
		call <SID>SetWingsPath('~/Documents/1.WINGS/')

		" Time runtime of a specific program
		nnoremap <Leader>mt :Dispatch powershell -command "& {&'Measure-Command' {.\sep_calc.exe seprc}}"<CR>

		nnoremap <Leader>ep :e ~/vimfiles/plugged/
		nnoremap <Leader>ma :Make


		" call <SID>AutoCreateWinCtags()

		" Windows specific plugins options
			" Plugin 'ctrlpvim/ctrlp.vim' " quick file searchh"
				set wildignore+=*\\.git\\*,*\\.hg\\*,*\\.svn\\*  " Windows ('noshellslash')
				let g:ctrlp_custom_ignore = {
					\ 'dir':  '\v[\/]\.(git|hg|svn)$',
					\ 'file': '\v\.(tlog|log|db|obj|o|exe|so|dll|dfm)$',
					\ 'link': 'SOME_BAD_SYMBOLIC_LINKS',
					\ }

			" Vim-Clang " not being used currently but this below fixes
			" clang using mscv for target instead of mingw64
				let g:clang_cpp_options = '-target x86_64-pc-windows-gnu -std=c++17 -pedantic -Wall'
				let g:clang_c_options = '-target x86_64-pc-windows-gnu -std=gnu11 -pedantic -Wall'

			" MaxT Path
				if isdirectory('C:\maxapi')
					set path+=C:\maxapi
				endif

			" //////////////7/28/2016 4:09:23 PM////////////////
			" Tried using shell=bash on windows didnt work got all kinds of issues
			" with syntastic and other things.
		" Airline 
			set encoding=utf-8

			if !exists('g:airline_symbols')
				let g:airline_symbols = {}
			endif

			" If you ever try a new font and want see if symbols work just go to h
			" airline and check if the symbols display properly there. If they do they
			" will display properly in the bar
			" let g:airline_left_sep = '»'
			let g:airline_left_sep = ''
			" let g:airline_right_sep = '«'
			let g:airline_right_sep = ''
			" let g:airline_symbols.linenr = '¶'
			let g:airline_symbols.linenr = ''
			let g:airline_symbols.maxlinenr = '☰'
			" let g:airline_symbols.maxlinenr = ''
			let g:airline_symbols.paste = 'ρ'
			" let g:airline_symbols.paste = 'Þ'
			" let g:airline_symbols.paste = '∥'
			let g:airline_symbols.whitespace = 'Ξ'
			let g:airline_symbols.crypt = ''
			let g:airline_symbols.branch = ''
			let g:airline_symbols.notexists = ''
			let g:airline_symbols.readonly = ''

" UNIX_SETTINGS
	elseif has('unix')
		" Path variables
		if has('nvim')
			let s:cache_path= $HOME . '/.cache/'
			let s:plugged_path=  $HOME . '/.config/nvim/plugged/'
			let s:vimfile_path=  $HOME . '/.config/nvim/'
		else
			let s:cache_path= $HOME . '/.cache/'
			let s:plugged_path=  $HOME . '/.vim/plugged/'
			let s:vimfile_path=  $HOME . '/.vim/'
		endif
		let s:wiki_path=  $HOME . '/Documents/seafile-client/Seafile/KnowledgeIsPower/wiki'

		let s:custom_font = 'Andale Mono 8'

		" this one below DOES WORK in linux just make sure is ran at root folder
		noremap <Leader>tu :cs kill -1<CR>
		\:!rm cscope.files cscope.out cscope.po.out cscope.in.out<CR>
		\:!find . -iname '*.c' -o -iname '*.cpp' -o -iname '*.java' -o -iname '*.cc'  -o -iname '*.h' -o -iname '*.hpp' > cscope.files<CR>
		\:!cscope -b -q -i cscope.files<CR>
		\:cs add cscope.out<CR>
		\:silent !ctags -R -L cscope.files<CR>

		nnoremap <Leader>mr :silent !./%<CR>

		" System paste
		nnoremap <Leader><Space>v "+p
		nnoremap <Leader><Space>y "+y
		vnoremap <Leader><Space>y "+y

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
		" Edit plugin
		if has('nvim')
			nnoremap <Leader>ep :e ~/.config/nvim/plugged/
		else
			nnoremap <Leader>ep :e ~/.vim/plugged/
		endif


		nnoremap <Leader><Space>= :silent! let &guifont = substitute(
		\ &guifont,
		\ '\ \zs\d\+',
		\ '\=eval(submatch(0)+1)',
		\ '')<CR>
		nnoremap <Leader><Space>- :silent! let &guifont = substitute(
		\ &guifont,
		\ '\ \zs\d\+',
		\ '\=eval(submatch(0)-1)',
		\ '')<CR>

		nnoremap <CR> o<ESC>
		" Save file with sudo permissions
		nnoremap <Leader>su :w !sudo tee %<CR>

		" Give execute permissions to current file
		nnoremap <Leader>cp :!chmod a+x %<CR>
		nnoremap <Leader>ma :make 
		" Experimenting substitute for ctrl-p
		nnoremap <C-p> :FZF<ENTER>
		let g:ctrlp_map = ''

		augroup UnixMD
			autocmd!
			autocmd FileType markdown nnoremap <buffer> <Leader>mr :!google-chrome %<CR>
		augroup END

		" TODO|
		"    \/
		" call <SID>AutoCreateUnixCtags()

		" Unix Specific Plugin Options
			"Plugin 'ctrlpvim/ctrlp.vim' " quick file searchh"
				set wildignore+=*/.git/*,*/.hg/*,*/.svn/*        " Linux/MacOSX
				let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'

			" VIM_PATH includes
				" With this you can use gf to go to the #include <avr/io.h>
				" also this path below are what go into the .syntastic_avrgcc_config
				set path+=/usr/local/include
				set path+=/usr/include

				set tags+=~/.vim/ctags/tags_sys
				set tags+=~/.vim/ctags/tags_sys2
				set tags+=~/.vim/ctags/tags_android

			" Vim-clang
				let g:clang_library_path='/usr/lib/llvm-3.8/lib'

			" Vim-Man
				runtime! ftplugin/man.vim
				" Sample use: Man 3 printf
				" Potential plug if you need more `vim-utils/vim-man` but this should be
				" enough
				
			" Airline
				if !exists('g:airline_symbols')
					let g:airline_symbols = {}
				endif
				" TODO: Fix this here
				" let g:airline_left_sep = ''
				" let g:airline_left_alt_sep = ''
				" let g:airline_right_sep = ''
				" let g:airline_right_alt_sep = ''
				" let g:airline_symbols.branch = ''
				" let g:airline_symbols.readonly = ''
				" let g:airline_symbols.linenr = ''

				" Todo fix here
				let g:airline_left_sep = '»'
				" let g:airline_left_sep = '▶'
				let g:airline_right_sep = '«'
				" let g:airline_right_sep = '◀'
				" let g:airline_symbols.crypt = '🔒'
				" let g:airline_symbols.linenr = '␊'
				" let g:airline_symbols.linenr = '␤'
				let g:airline_symbols.linenr = '¶'
				let g:airline_symbols.maxlinenr = '☰'
				" let g:airline_symbols.maxlinenr = ''
				" let g:airline_symbols.branch = '⎇'
				let g:airline_symbols.paste = 'ρ'
				" let g:airline_symbols.paste = 'Þ'
				" let g:airline_symbols.paste = '∥'
				" let g:airline_symbols.spell = 'Ꞩ'
				" let g:airline_symbols.notexists = '∄'
				let g:airline_symbols.whitespace = 'Ξ'
	endif

" FUNCTIONS
	function! s:SetGrep() abort
		" use option --list-file-types if in doubt
		" to specify a type of file just do `--cpp`
		" Add the --type-set=markdown:ext:md option to ucg for it to recognize
		" Use the -t option to search all text files; -a to search all files; and -u to search all, including hidden files.
		" md files
		if executable('ucg')
			set grepprg=ucg\ --nocolor\ --noenv
		elseif executable('ag')
			" ctrlp with ag
			" see :Man ag for help
			"Use the -t option to search all text files; -a to search all files; and -u to search all, including hidden files.
			set grepprg=ag\ --nogroup\ --nocolor\ --smart-case\ --vimgrep\ $*
			set grepformat=%f:%l:%c:%m
		endif
	endfunction 

	" Commits current buffer
	function! s:GitCommit() abort
		if <SID>CheckFileOrDir(1, ".git") > 0
			silent !git add .
			execute "silent !git commit -m \"" . input("Commit comment:") . "\""
			!git push origin master
		else
			echo "No .git directory was found"
		endif
	endfunction

	" Should be performed on root .svn folder
	function! s:SvnCommit() abort
		execute "!svn commit -m \"" . input("Commit comment:") . "\" ."
	endfunction

	" Special comment function {{{
	function! s:FindIf() abort
		while 1
			" jump to matching {
			normal %
			" check to see if there is another else
			if match(getline(line(".")-1, line(".")), "else") > -1
				" search curr and previous 2 lines for }
				if match(getline(line(".")-2, line(".")), "}") > -1
					" jump to it
					execute "normal ?}\<CR>"
					" if there is no } could be no braces else if
				else
					" go up to lines and see what happens
					normal kk
				endif
			else
				" if original if was found copy it to @7 and jump back to origin
				execute "normal k^\"7y$`m"
				break
			endif
		endwhile
	endfunction

	function! s:TruncComment(comment) abort
		" brute trunc at 46
		let l:strip = a:comment
		if strchars(l:strip) > 46
			let l:strip = strpart(l:strip,0,46)
			let l:strip .= "..."
		endif
		" if theres a comment get rid of it
		let l:com = match(l:strip, "/")
		if l:com > -1
			let l:strip = strpart(l:strip,0,l:com-1)
		endif
		return l:strip
	endfunction

	" Gotchas: Start from the bottom up commenting
	function! s:EndOfIfComment() abort
		" TDOD: Eliminate comments on lines very important
		" is there a } in this line?
		"let g:testa = 0  " Debugging variable
		let l:ref_col = match(getline("."), "}")
		if  l:ref_col > -1 " if it exists
			" Determine what kind of statement is this i.e: for, while, if, else if
			" jump to matchin {, mark it with m, copy previous line to @8, and jump back down to original }
			"execute "normal mm" . l:ref_col . "|%k^\"8y$j%"
			execute "normal mm" . l:ref_col . "|%"
			let l:upper_line = line(".")
			execute "normal k^\"8y$j%"
			" if original closing brace it is and else if || else
			if match(getline(line(".")-1, line(".")), "else") > -1
				let g:testa = 1
				" if { already contains closing if put it
				" TODO:fix this to make search for else not only in @8 line
				if match(getline(l:upper_line-1,l:upper_line), "else") > -1
					" search upwards until you find initial if and copy it to @7
					call <SID>FindIf()
					" truncate comment line in case too long
					let @7 = <SID>TruncComment(@7)
					" append // "initial if..." : "
					let l:end = "  // \""
					execute "normal a" . l:end . @7 . "\" : \"\<Esc>"
				else
					let l:end = "  // \""
					execute "normal a" . l:end . "\<Esc>"
				endif
				" search openning brace for else
			elseif match(getline(l:upper_line-1,l:upper_line), "else") > -1
				let g:testa = 2
				" search upwards until you find initial if and copy it to @7
				call <SID>FindIf()
				" truncate comment line in case too long
				let @7 = <SID>TruncComment(@7)
				" append // "initial if..." : "
				let l:end = "  // End of \""
				execute "normal a" . l:end . @7 . "\" : \"\<Esc>"
				" if not very easy
			else
				" Append // End of "..."
				let l:end = "  // End of \""
				execute "normal a" . l:end . "\<Esc>"
			endif
			" truncate comment line in case too long
			let @8 = <SID>TruncComment(@8)
			execute "normal a" . @8 . "\""
		else
			echo "EndOfIfComment(): Closing brace } needs to be present at the line"
		endif
	endfunction
	nnoremap <Leader>ce :call <SID>EndOfIfComment()<CR>
	" End of Special Comment function }}}

	function! s:CheckDirwPrompt(name) abort
		if !has('file_in_path')  " sanity check
			echo "CheckFileOrDir(): This vim install has no support for +find_in_path"
			return -10
		endif
		if a:type == 0  " use 0 for file, 1 for dir
			let l:func = findfile(a:name,",,")  " see :h cd for ,,
		else
			let l:func = finddir(a:name,",,")
		endif
		if !empty(l:func)
			return 1
		else
			execute "echo \"Folder " . escape(a:name, '\') . "does not exists.\n\""
			execute "echo \"Do you want to create it (y)es or (n)o\""
			let l:decision = nr2char(getchar())
			if l:decision == "y"
				if exists("*mkdir")
					if has('win32') " on win prepare name by escaping '\'
						let l:esc_name = escape(a:name, '\')
						execute "call mkdir(\"". l:esc_name . "\", \"p\")"
					else  " have to test check works fine on linux
						execute "call mkdir(\"". a:name . "\", \"p\")"
					endif
					return 1
				else
					return -1
				endif
			endif
			return -1
		endif
	endfunction

	" This function silently attemps to create the directory its checking if it
	" exists in case it doesnt find it.
	" Compatible with both Linux and Windows
	function! <SID>CheckDirwoPrompt(name) abort
		if !has('file_in_path')  " sanity check
			echo "CheckFileOrDir(): This vim install has no support for +find_in_path"
			return -10
		else
			if !empty(finddir(a:name,",,"))
				return 1
			else
				if exists("*mkdir")
					if has('win32') " on win prepare name by escaping '\'
						execute "call mkdir(\"". escape(a:name, '\') . "\", \"p\")"
					else  " have to test check works fine on linux
						execute "call mkdir(\"". a:name . "\", \"p\")"
					endif
					return 1
				else
					echomsg string("No +mkdir support. Can't create dir")
					return -1
				endif
			endif
		endif
	endfunction

	function! s:YankFrom() abort
		execute "normal :" . input("Yank From Line:") . "y\<CR>"
	endfunction

	function! s:DeleteLine() abort
		execute "normal :" . input("Delete Line:") . "d\<CR>``"
	endfunction

	function! s:ListsNavigation(cmd) abort
		try
			let l:list = 0
			if !empty(getloclist(0)) " if location list is not empty
				let l:list = 1
				execute "silent l" . a:cmd
			elseif !empty(getqflist()) " if quickfix list is not empty
				execute "silent c" . a:cmd
			else
				echohl ErrorMsg
				redraw " always use it to prevent msg from dissapearing
				echomsg "ListsNavigation(): Lists quickfix and location are empty"
				echohl None
			endif
		catch /:E553:/ " catch no more items error
			if l:list == 1
				silent .ll
			else
				silent .cc
			endif
		endtry
	endfunction

	function! s:SetDiff() abort
		" Make sure you run diffget and diffput from left window
		nnoremap <C-j> ]c
		nnoremap <C-k> [c
		nnoremap <C-h> :diffget<CR>
		nnoremap <C-l> :diffput<CR>
		windo diffthis
	endfunction

	function! s:UnsetDiff() abort
		nnoremap <C-j> zj
		nnoremap <C-k> zk
		nnoremap <C-h> :noh<CR>
		nunmap <C-l>
		diffoff!
	endfunction

	function! s:CheckVimPlug() abort
		let b:bLoadPlugins = 0
		if empty(glob(s:vimfile_path . 'autoload/plug.vim'))
			if executable('curl')
				" Create folder
				call <SID>CheckDirwoPrompt(s:vimfile_path . "autoload")
				echomsg "Master I am going to install all plugings for you"
				execute "silent !curl -fLo " . s:vimfile_path . "autoload/plug.vim --create-dirs"
					\" https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
				autocmd VimEnter * PlugInstall | source $MYVIMRC
				let b:bLoadPlugins = 1
				return 1
			else
				echomsg "Master I cant install plugins for you because you"
							\" do not have curl. Please fix this. Plugins"
							\" will not be loaded."
				let b:bLoadPlugins = 0
				return 0
			endif
		else
			let b:bLoadPlugins = 1
			return 1
		endif
	endfunction

	function! s:NormalizeWindowSize() abort
		execute "normal \<c-w>="
	endfunction

	function! s:FixPreviousWord() abort
		normal mm[s1z=`m
	endfunction

	function! s:SaveSession(...) abort
		" if session name is not provided as function argument ask for it
		if a:0 < 1
			execute "wall"
			execute "cd ". s:cache_path ."sessions/"
			let l:sSessionName = input("Enter
						\ save session name:", "", "file")
		else
			" Need to keep this option short and sweet
			let l:sSessionName = a:1
		endif
		execute "normal :mksession! " . s:cache_path . "sessions/". l:sSessionName  . "\<CR>"
		execute "cd -"
	endfunction

	function! s:LoadSession(...) abort
		" save all work
		execute "cd ". s:cache_path ."sessions/"
		" Logic path when not called at startup
		if a:0 < 1
			execute "wall"
			echo "Save Current Session before deleting all buffers: (y)es (any)no"
			let l:iResponse = getchar()
			if l:iResponse == 121 " y
				call <SID>SaveSession()
			endif
			let l:sSessionName = input("Enter
						\ load session name:", "", "file")
		else
			let l:sSessionName = a:1
			echo "Reload Last Session: (y)es (d)ifferent session or (any)nothing"
			let l:iResponse = getchar()
			if l:iResponse == 100 " different session
				let l:sSessionName = input("Enter
							\load session name:", "", "file")
			elseif l:iResponse == 121 " reload last session
				" continue to end of if
			else
				" execute "normal :%bdelete\<CR>" " do not delete old buffers
				return
			endif
		endif
		execute "normal :%bdelete\<CR>"
		silent execute "normal :so " . s:cache_path . "sessions/". l:sSessionName . "\<CR>"
		execute "cd -"
	endfunction

	function! s:TodoCreate() abort
		execute "normal Blli\<Space>[ ]\<Space>\<Esc>"
	endfunction

	function! s:TodoMark() abort
		execute "normal Bf[lrX\<Esc>"
	endfunction

	function! s:TodoClearMark() abort
		execute "normal Bf[lr\<Space>\<Esc>"
	endfunction

	function! s:TodoAdd() abort
		execute "normal aTODO.RM-\<F5>: "
	endfunction

	function! s:CommentDelete() abort
		execute "normal Bf/D"
	endfunction

	function! s:CommentIndent() abort
		execute "normal Bf/i\<Tab>\<Tab>\<Esc>"
	endfunction

	function! s:CommentReduceIndent() abort
		execute "normal Bf/hxhx"
	endfunction

	function! s:CommentLine() abort
		if exists("*NERDComment")
			execute "normal mm:" . input("Comment Line:") . "\<CR>"
			execute "normal :call NERDComment(\"n\", \"Toggle\")\<CR>`m"
		else
			echo "Please install NERDCommenter"
		endif
	endfunction

	" To update ctags simply delete the ctags folder
	" Note: There is also avr tags created by vimrc/scripts/maketags.sh
	" let &tags= s:cache_path . 'ctags/tags'
	function! s:AutoCreateCtags() abort
		if empty(finddir(s:cache_path . "ctags",",,"))
			" Go ahead and create the ctags
			if !executable('ctags')
				echomsg string("Please install ctags")
			else
				" Create folder
				if !<SID>CheckDirwoPrompt(s:cache_path . "ctags")
					echoerr string("Failed to create ctags dir")
				endif
				" Create ctags
				if has('unix')
					!ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ -f ~/.vim/personal/ctags/tags_sys /usr/include
					!ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ -f ~/.vim/personal/ctags/tags_sys2 /usr/local/include
					if isdirectory('/opt/avr8-gnu-toolchain-linux_x86_64/avr/include')
						set path+=/opt/avr8-gnu-toolchain-linux_x86_64/avr/include
						!ctags -R --sort=yes --fields=+iaS --extra=+q --language-force=C -f ~/.vim/personal/ctags/tags_avr /opt/avr8-gnu-toolchain-linux_x86_64/avr/include
						set tags+=~/.vim/personal/ctags/tags_avr
					endif
					if isdirectory('/opt/avr8-gnu-toolchain-linux_x86_64/include')
						set path+=/opt/avr8-gnu-toolchain-linux_x86_64/include
						!ctags -R --sort=yes --fields=+iaS --extra=+q --language-force=C -f ~/.vim/personal/ctags/tags_avr2 /opt/avr8-gnu-toolchain-linux_x86_64/include
						set tags+=~/.vim/personal/ctags/tags_avr2
					endif
				elseif has('win32') && isdirectory('c:/MinGW')
					set path+=c:/MinGW/include
					execute "!ctags -R --verbose --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q
								\ --language-force=C++ -f " . expand('~/vimfiles/personal/ctags/tags_sys') . " C:\\MinGW\\include"
				else
					echomsg string("Please install MinGW")
				endif
			endif
		elseif has('unix')
			if isdirectory('/opt/avr8-gnu-toolchain-linux_x86_64/avr/include')
				set path+=/opt/avr8-gnu-toolchain-linux_x86_64/avr/include
			endif
			set tags+=~/.vim/personal/ctags/tags_sys
			set tags+=~/.vim/personal/ctags/tags_sys2
		else
			set tags+=~/vimfiles/personal/ctags/tags_sys
		endif
	endfunction

	" Finish all this crap
	function! s:AutoCreateUnixCtags() abort
		if empty(finddir(s:cache_path . "ctags",",,"))
			" Go ahead and create the ctags
			if !executable('ctags')
				echomsg string("Please install ctags")
				return 0
			else
				" Create folder
				if !<SID>CheckDirwoPrompt(s:cache_path . "ctags")
					echoerr string("Failed to create ctags dir")
					return 0
				endif
				let l:ctags_cmd = "!ctags -R --sort=yes --fields=+iaS --extra=+q -f "
				" Ordered list that contains folder where tag is and where tag file
				" goes
				let l:list_folders = [
							\"/usr/include",
							\"~/.vim/personal/ctags/tags_sys",
							\"/usr/local/include",
							\"~/.vim/personal/ctags/tags_sys2",
							\'/opt/avr8-gnu-toolchain-linux_x86_64/avr/include',
							\"~/.vim/personal/ctags/tags_avr",
							\'/opt/avr8-gnu-toolchain-linux_x86_64/include',
							\"~/.vim/personal/ctags/tags_avr2",
							\]

				" Create ctags
					" if isdirectory(l:list_folders
					!ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ -f ~/.vim/personal/ctags/tags_sys /usr/include
					!ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ -f ~/.vim/personal/ctags/tags_sys2 /usr/local/include
					if isdirectory('/opt/avr8-gnu-toolchain-linux_x86_64/avr/include')
						set path+=/opt/avr8-gnu-toolchain-linux_x86_64/avr/include
						!ctags -R --sort=yes --fields=+iaS --extra=+q --language-force=C -f ~/.vim/personal/ctags/tags_avr /opt/avr8-gnu-toolchain-linux_x86_64/avr/include
						set tags+=~/.vim/personal/ctags/tags_avr
					endif
					if isdirectory('/opt/avr8-gnu-toolchain-linux_x86_64/include')
						set path+=/opt/avr8-gnu-toolchain-linux_x86_64/include
						!ctags -R --sort=yes --fields=+iaS --extra=+q --language-force=C -f ~/.vim/personal/ctags/tags_avr2 /opt/avr8-gnu-toolchain-linux_x86_64/include
						set tags+=~/.vim/personal/ctags/tags_avr2
					endif
				elseif has('win32') && isdirectory('c:/MinGW')
					set path+=c:/MinGW/include
					execute "!ctags -R --verbose --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q
								\ --language-force=C++ -f " . expand('~/vimfiles/personal/ctags/tags_sys') . " C:\\MinGW\\include"
				else
					echomsg string("Please install MinGW")
				endif
			endif
		elseif has('unix')
			if isdirectory('/opt/avr8-gnu-toolchain-linux_x86_64/avr/include')
				set path+=/opt/avr8-gnu-toolchain-linux_x86_64/avr/include
			endif
			set tags+=~/.vim/personal/ctags/tags_sys
			set tags+=~/.vim/personal/ctags/tags_sys2
		else
			set tags+=~/vimfiles/personal/ctags/tags_sys
		endif
	endfunction

	function! s:LastCommand() abort
		execute "normal :\<Up>\<CR>"
	endfunction

	function! s:ListFiles(dir) abort
		let l:directory = globpath(a:dir, '*')
		if empty(l:directory)
			echohl ErrorMsg | echom a:dir . " is not a valid directory name" | echohl None
		endif
		return map(split(l:directory,'\n'), "fnamemodify(v:val, ':t')")
	endfunction

	" Vim-Wiki
		" Origin: Wang Shidong <wsdjeg@outlook.com>
						" vim-cheat
		func! CheatCompletion(ArgLead, CmdLine, CursorPos)
			echom "arglead:[".a:ArgLead ."] cmdline:[" .a:CmdLine ."] cursorpos:[" .a:CursorPos ."]"
			if a:ArgLead =~ '^-\w*'
				echohl WarningMsg | echom a:ArgLead . " is not a valid wiki name" | echohl None
			endif
			return join(<SID>ListFiles(s:wiki_path . '//'),"\n")
		endfunction

		function! s:OpenWiki(...) abort
			if a:0 > 0
				execute "vs " . s:wiki_path . '/'.  a:1
				return
			endif
			execute "vs " . fnameescape(s:wiki_path . '//' . input('Wiki Name: ', '', 'custom,CheatCompletion'))
		endfunction

" PLUGINS_FOR_BOTH_SYSTEMS
	" Attempt to install vim-plug and all plugins in case of first use
	if <SID>CheckVimPlug()
		" Call Vim-Plug Plugins should be from here below
		call plug#begin(s:plugged_path)
		if has('nvim')
			" Neovim exclusive plugins
			" Currently not working
			" Plug 'DonnieWest/VimStudio'
			Plug 'neomake/neomake'
			Plug 'Shougo/deoplete.nvim'
		else
			" Vim exclusive plugins
			Plug 'Shougo/neocomplete'
			Plug 'tpope/vim-dispatch'
			Plug 'scrooloose/syntastic', { 'on' : 'SyntasticCheck' }
		endif
		" Plugins for both
		" misc
		Plug 'chrisbra/vim-diff-enhanced', { 'on' : 'SetDiff' }
		Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
		Plug 'scrooloose/nerdcommenter'
		Plug 'ctrlpvim/ctrlp.vim'
		Plug 'chrisbra/Colorizer'
		Plug 'tpope/vim-repeat'
		Plug 'tpope/vim-surround'
		Plug 'Konfekt/FastFold'
		Plug 'airblade/vim-rooter'
		Plug 'Raimondi/delimitMate'
		if has('unix') && !has('gui_running')
			Plug 'jamessan/vim-gnupg'
		endif
		" TODO: Configure
			" Plug 'Chiel92/vim-autoformat'
		" Search
		if has('unix') " Potential alternative to ctrlp
			Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
		endif
		" cpp
		Plug 'Tagbar', { 'on' : 'TagbarToggle' }
		Plug 'Rip-Rip/clang_complete', { 'for' : ['c' , 'cpp'] }
		Plug 'octol/vim-cpp-enhanced-highlight', { 'for' : [ 'c' , 'cpp' ] }
		Plug 'justinmk/vim-syntax-extra'
		Plug 'junegunn/rainbow_parentheses.vim', { 'on' : 'RainbowParentheses' }
		" cpp/java
		" Plug 'mattn/vim-javafmt', { 'for' : 'java' }
		Plug 'tfnico/vim-gradle', { 'for' : 'java' }
		Plug 'artur-shaik/vim-javacomplete2', { 'branch' : 'master' }
		Plug 'nelstrom/vim-markdown-folding'
		" Autocomplete
		Plug 'Shougo/neosnippet'
		Plug 'Shougo/neosnippet-snippets'
		Plug 'honza/vim-snippets'
		" version control
		Plug 'tpope/vim-fugitive'
		" aesthetic
		Plug 'morhetz/gruvbox' " colorscheme gruvbox
		Plug 'NLKNguyen/papercolor-theme'
		Plug 'vim-airline/vim-airline'
		Plug 'vim-airline/vim-airline-themes'
		" radical
		Plug 'glts/vim-magnum' " required by radical
		Plug 'glts/vim-radical' " use with gA

		" All of your Plugins must be added before the following line
		call plug#end()            " required
	endif

" GUI_SETTINGS
	if has('gui_running')
		let &guifont = s:custom_font " OS dependent font
		set guioptions-=T  " no toolbar
		set guioptions-=m  " no menu bar
		set guioptions-=r  " no right scroll bar
		set guioptions-=l  " no left scroll bar
		set guioptions-=L  " no side scroll bar
		nnoremap <S-CR> O<Esc>
	else " common cli options to both systems
		" TODO maybe set font for terminal instead of accepting terminal font
		set t_Co=256
		" fixes colorscheme not filling entire backgroud
		set t_ut=
		" Set blinking cursor shape everywhere
		if has('nvim')
			let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1
		elseif exists('$TMUX')
			let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
			let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
		else
			let &t_SI = "\<Esc>[5 q"
			let &t_EI = "\<Esc>[1 q"
		endif
	endif

" PERFORMANCE_SETTINGS
	" see :h slow-terminal
	hi NonText cterm=NONE ctermfg=NONE
	set showcmd " use noshowcmd if things are really slow
	set scrolljump=5
	set sidescroll=15 " see help for sidescroll
	if !has('nvim') " this option was deleted in nvim
		set ttyscroll=3
	endif
	set lazyredraw " Had to addit to speed up scrolling
	set ttyfast " Had to addit to speed up scrolling
	" set cursorline
	" let g:tex_fast= "" " on super slow activate this, price: no syntax
	" highlight
	" set fsync " already had problems with it. lost an entire file. dont use it

" Create personal folders
	" TMP folder
	if <SID>CheckDirwoPrompt(s:cache_path . "tmp")
		let $TMP= s:cache_path . "tmp"
	else
		echomsg string("Failed to create tmp dir")
	endif

	if !<SID>CheckDirwoPrompt(s:cache_path . "sessions")
		echoerr string("Failed to create sessions dir")
	endif

	" We assume wiki folder is there. No creation of this wiki folder

	if !<SID>CheckDirwoPrompt(s:cache_path . "java")
		echoerr string("Failed to create java dir")
	endif

	if has('persistent_undo')
		if <SID>CheckDirwoPrompt(s:cache_path . 'undofiles')
			let &undodir= s:cache_path . 'undofiles'
			set undofile
			set undolevels=1000      " use many muchos levels of undo
		endif
	endif

" SET_OPTIONS
	"set spell spelllang=en_us
	"omnicomplete menu
	" save marks
	set viminfo='1000,f1,<800,%1024
	set showtabline=1 " always show tabs in gvim, but not vim"
	set backspace=indent,eol,start
						" allow backspacing over everything in insert mode
	" indents defaults. Custom values are changes in after/indent
		" When 'sts' is negative, the value of 'shiftwidth' is used.
	set softtabstop=-8
	set smarttab      " insert tabs on the start of a line according to
	" shiftwidth, not tabstop

	set showmatch     " set show matching parenthesis
	set smartcase     " ignore case if search pattern is all lowercase,
										"    case-sensitive otherwise
	set ignorecase
	set hlsearch      " highlight search terms
	set number
	set relativenumber
	set incsearch     " show search matches as you type
	set history=1000         " remember more commands and search history
	" ignore these files to for completion
	set wildignore+=*.o,*.obj,*.bak,*.exe,*.py[co],*.swp,*~,*.pyc,.svn,.git
	set completeopt=menuone,menu,longest,preview
	" set complete+=kspell " currently not working
	set wildmenu
	set wildmode=list:longest
	set title                " change the terminal's title
	set visualbell           " don't beep
	set noerrorbells         " don't beep
	set nobackup " no backup files
	set noswapfile
	"set autochdir " working directory is always the same as the file you are editing
	" Took out options from here. Makes the session script too long and annoying
	set sessionoptions=buffers,curdir,folds,localoptions,options,tabpages,resize,winsize,winpos,help
	set hidden
	" see :h timeout this was done to make use of ' faster and keep the other
	" timeout the same
	set notimeout
	set nottimeout
	" cant remember why I had a timeout len I think it was
	" in order to use <c-j> in cli vim for esc
	" removing it see what happens
	" set timeoutlen=1000
	" set ttimeoutlen=0
	set nowrap        " wrap lines
	set nowrapscan        " do not wrap search at EOF
	" will look in current directory for tags
	" THE BEST FEATURE I'VE ENCOUNTERED SO FAR OF VIM
	" CAN BELIEVE I DIDNT DO THIS BEFORE
	set tags+=.\tags;\

	if has('cscope')
		set cscopetag cscopeverbose
		if has('quickfix')
			set cscopequickfix=s+,c+,d+,i+,t+,e+
		endif
	endif
	set matchpairs+=<:>
	set autoread " autoload files written outside of vim
	" Display tabs and trailing spaces visually
	"set list listchars=tab:\ \ ,trail:?
	set linebreak    "Wrap lines at convenient points
	" Open and close folds Automatically
	set foldenable
	" global fold indent
	set foldmethod=indent
	set foldnestmax=18      "deepest fold is 18 levels
	set foldlevel=0
	set foldlevelstart=0
	" use this below option to set other markers
	"'foldmarker' 'fmr'	string (default: "{{{,}}}")
	set viewoptions=folds,options,cursor,unix,slash " better unix /
	" For conceal markers.
	if has('conceal')
		set conceallevel=2 concealcursor=nv
	endif

	set noesckeys " No mappings that start with <esc>
	set noshowmode
	" no mouse enabled
	set mouse=""
	set laststatus=2
	set formatoptions=croqt " this is textwidth actually breaks the lines
	set textwidth=80
	" makes vim autocomplete - bullets
	set comments+=b:-,b:*
	set nolist " Do not display extra characters
	set scroll=8
	set modeline
	set modelines=1
	" Set omni for all filetypes
	set omnifunc=syntaxcomplete#Complete
	call <SID>SetGrep()

" ALL_AUTOGROUP_STUFF
	" All of these options contain performance drawbacks but the most important
	" is foldmethod=syntax
	augroup Filetypes
		autocmd!
		" TODO convert each of these categories into its own augroup
		" C/Cpp
		autocmd FileType c,cpp setlocal omnifunc=ClangComplete
	 	" Rainbow cannot be enabled for help file. It breaks syntax highlight
		autocmd FileType c,cpp,java RainbowParentheses
		" autocmd FileType c,cpp setlocal foldmethod=syntax
		" Indent options
		autocmd FileType c,cpp setlocal shiftwidth=4 tabstop=4
		autocmd FileType tex,vim,java,markdown setlocal shiftwidth=2 tabstop=2
		" Java
		autocmd FileType java setlocal omnifunc=javacomplete#Complete
		autocmd FileType java compiler gradlew
		" Nerdtree Fix
		autocmd FileType nerdtree setlocal relativenumber
		" Set omnifunc for all others 									" not showing
		autocmd FileType cs compiler msbuild
		" Latex
		autocmd FileType tex setlocal spell spelllang=en_us
		autocmd FileType tex setlocal fdm=indent
		autocmd FileType tex compiler tex
		" Display help vertical window not split
		autocmd FileType help wincmd L
		" wrap syntastic messages
		autocmd FileType qf setlocal wrap
		" Open markdown files with Chrome.
		autocmd FileType markdown setlocal spell spelllang=en_us
		autocmd FileType mail setlocal wrap
		autocmd FileType mail setlocal spell spelllang=es,en
	augroup END

	augroup BuffTypes
	autocmd!
		" Arduino
		autocmd BufNewFile,BufReadPost *.ino,*.pde setf arduino
		" automatic syntax for *.scp
		autocmd BufNewFile,BufReadPost *.scp setf wings_syntax
		autocmd BufNewFile,BufReadPost *.set,*.sum setf dosini
		autocmd BufWritePost *.java Neomake
		"Automatically go back to where you were last editing this file
		autocmd BufReadPost *
			\ if line("'\"") > 0 && line("'\"") <= line("$") |
			\ exe "normal g`\"" |
			\ endif

	augroup VimType
		autocmd!
		" Sessions
		" autocmd VimEnter * call <SID>LoadSession('default.vim')
		autocmd VimLeave * call <SID>SaveSession('default.vim')
		" Keep splits normalize
		autocmd VimResized * call <SID>NormalizeWindowSize()
	augroup END

	" vim -b : edit binary using xxd-format!
	" using let &l:option_name is the same as setlocal
	augroup Binary
		au!
		au BufReadPre  *.bin,*.hsr,*.pdf let &l:bin=1
		au BufReadPost *.bin,*.hsr,*.pdf if &bin | %!xxd
		au BufReadPost *.bin,*.hsr,*.pdf setlocal ft=xxd | endif
		au BufWritePre *.bin,*.hsr,*.pdf if &bin | %!xxd -r
		au BufWritePre *.bin,*.hsr,*.pdf endif
		au BufWritePost *.bin,*.hsr,*.pdf if &bin | %!xxd
		au BufWritePost *.bin,*.hsr,*.pdf setlocal nomod | endif
	augroup END

" CUSTOM MAPPINGS
	" List of super useful mappings
	" ga " prints ascii of char under cursor
	" = fixes indentantion
	" gq formats code

	" Quickfix and Location stuff
		" Description:
		" C-Arrow forces movement on quickfix window
		" Arrow moves on whichever window open (qf || ll)
		" if both opened favors location window

		" Quickfix only mappings
		nnoremap <C-Down> :cn<CR>
		nnoremap <C-Up> :cp<CR>
		nnoremap <C-Right> :cnf<CR>
		nnoremap <C-Left> :cpf<CR>
		" noremap <Leader>qO :Copen!<CR>
		noremap <Leader>qO :lopen 20<CR>
		noremap <Leader>qo :copen 20<CR>
		noremap <Leader>qc :cc<CR>

		nnoremap <Down> :call <SID>ListsNavigation("next")<CR>
		nnoremap <Up> :call <SID>ListsNavigation("previous")<CR>
		nnoremap <Right> :call <SID>ListsNavigation("nfile")<CR>
		nnoremap <Left> :call <SID>ListsNavigation("pfile")<CR>

		noremap <Leader>ql :ccl<CR>
					\:lcl<CR>

	" Miscelaneous Mappings
		" edit vimrc on a new tab
		noremap <Leader>mv :e $MYVIMRC<CR>
		noremap <Leader>ms :so %<CR>
		nnoremap <C-s> :wa<CR>
		nnoremap <C-h> :noh<CR>
		nnoremap <C-Space> i<Space><Esc>
		" move current line up
		nnoremap <Leader>K ddkk""p
		" move current line down
		noremap <Leader>J dd""p
		" These are only for command line
		" insert in the middle of whole word search
		cnoremap <C-w> \<\><Left><Left>
		" insert visual selection search
		cnoremap <C-u> <c-r>=expand("<cword>")<cr>
		cnoremap <C-s> %s/
		" refactor
		nnoremap <Leader>r :%s/\<<c-r>=expand("<cword>")<cr>\>//gc<Left><Left><Left>
		vnoremap <Leader>r "hy:%s/<C-r>h//gc<left><left><left>
		"vnoremap <Leader>r :%s///gc<Left><Left><Left>
		cnoremap <C-p> <c-r>0
		cnoremap <C-o> <Up>
		cnoremap <C-k> <Down>
		cnoremap <C-j> <Left>
		cnoremap <C-l> <Right>
		"noremap <Leader>mn :noh<CR>
		" duplicate current char
		nnoremap <Leader>mp ylp
		vnoremap <Leader>mp ylp
		"noremap <Leader>mt :set relativenumber!<CR>
		noremap <Leader>md :Dox<CR>
		" not paste the deleted word
		nnoremap <Leader>p "0p
		vnoremap <Leader>p "0p
		" Switch back and forth between header file
		nnoremap <Leader>moh :e %:p:s,.h$,.X123X,:s,.cpp$,.h,:s,.X123X$,.cpp,<CR>"
		noremap <S-q> yyp
		" move to the beggning of line
		noremap <S-w> $
		" move to the end of line
		noremap <S-b> ^
		" jump to corresponding item<Leader> ending {,(, etc..
		nnoremap <S-t> %
		vnoremap <S-t> %
		" Automatically insert date
		nnoremap <F5> i<Space><ESC>"=strftime("%a %b %d %Y %H:%M")<CR>P
		" Designed this way to be used with snippet md header
		vnoremap <F5> s<Space><ESC>"=strftime("%a %b %d %Y %H:%M")<CR>Pa
		inoremap <F5> <Space><ESC>"=strftime("%a %b %d %Y %H:%M")<CR>Pa
		" Auto indent pasted text
		nnoremap p p=`]<C-o>
		nnoremap P P=`]<C-o>
		" Visual shifting (does not exit Visual mode)
		vnoremap < <gv
		vnoremap > >gv

		" see :h <c-r>
		nnoremap <Leader>nl :bro old<CR>
		" decrease number
		nnoremap <Leader>A <c-x>
		" delete key
		inoremap <c-l> <c-o>x
		" math on insert mode
		inoremap <C-A> <C-O>yiW<End>=<C-R>=<C-R>0<CR>
		" Count occurrances of last search
		nnoremap <Leader>cs :%s///gn<CR>
		" Reload syntax
		" Force wings_syntax on a file
		nnoremap <Leader>sl :set filetype=wings_syntax<CR>
		" Remove Trailing Spaces
		nnoremap <Leader>c<Space> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>
		nnoremap <Leader>cl :call <SID>LastCommand()<CR>
		nnoremap <Leader>gf :e <cfile><CR>
		" Indent file
		nnoremap <Leader>I ggvG=
		" Get vim help on current word
		nnoremap <Leader>He :h <c-r>=expand("<cword>")<CR><CR>
		" Markdown fix _ showing red
		nnoremap <Leader>mf :s%/_/\\_/g<CR>

	" Edit local
		nnoremap <Leader>el :silent e ~/
		" cd into current dir path and into dir above current path
		nnoremap <Leader>e1 :e ~/vimrc/
		" Edit Vimruntime
		nnoremap <Leader>ev :e $VIMRUNTIME/

	" CD
		nnoremap <Leader>cd :cd %:p:h<CR>
					\:pwd<CR>
		nnoremap <Leader>cu :cd ..<CR>
					\:pwd<CR>
		" cd into dir. press <Tab> after ci to see folders
		nnoremap <Leader>ci :cd 
		nnoremap <Leader>cc :pwd<CR>
		nnoremap <Leader>ch :cd ~<CR>
					\pwd<CR>

	" Folding
		" Folding select text then S-f to fold or just S-f to toggle folding
		nnoremap <C-j> zj
		nnoremap <C-k> zk
		nnoremap <C-z> zz
		nnoremap <C-c> zM
		nnoremap <C-n> zR
		nnoremap <C-x> za
		" dont use <C-a> it conflicts with tmux prefix

	" Window movement
		" move between windows
		nnoremap <Leader>h <C-w>h
		nnoremap <Leader>j <C-w>j
		nnoremap <Leader>k <C-w>k
		nnoremap <Leader>l <C-w>l

	" Diff Sutff
		command! SetDiff call <SID>SetDiff()
		noremap <Leader>do :SetDiff<CR>
		nnoremap <Leader>dl :call <SID>UnsetDiff()<CR>

	" Spell Check
		" search forward
		noremap <Leader>sN ]s
		" search backwards
		noremap <Leader>sP [s
		" suggestion
		noremap <Leader>sC z=1<CR><CR>
		noremap <Leader>sc z=
		" toggle spelling
		noremap <Leader>st :setlocal spell! spelllang=en_us<CR>

		noremap <Leader>sf :call <SID>FixPreviousWord()<CR>

		" add to dictionary
		noremap <Leader>sa zg
		" mark wrong
		noremap <Leader>sw zw
		" repeat last spell correction
		noremap <Leader>sr :spellr<CR>

	" Search
		" Tried ack.vim. Discovered that nothing is better than grep with ag.
		" search all type of files
		nnoremap <Leader>S :grep --cpp 
		" " " search cpp files
		" nnoremap <Leader>Sc :call <SID>GlobalSearch(2)<CR>
		nnoremap <Leader>w /\<<c-r>=expand("<cword>")<cr>\>
		nnoremap <Leader>W :%s/\<<c-r>=expand("<cword>")<cr>\>/
		" This is a very good to show and search all current but a much better is
		" remaped search to f
		noremap <S-s> #<C-o>
		vnoremap // y/<C-R>"<CR>

	" Substitute for ESC
		inoremap <C-j> <Esc>
		vnoremap <C-j> <Esc>
		" cnoremap <C-j> <Esc>

	" Buffers Stuff
		noremap <S-j> :b#<CR>
		noremap <Leader>bd :bp\|bd #<CR>
		" deletes all buffers
		noremap <Leader>bD :%bd<CR>
		noremap <Leader>bs :buffers<CR>:buffer<Space>
		noremap <Leader>bS :bufdo
		" move tab to the left
		nnoremap <silent> <A-Left> :execute 'silent! tabmove ' . (tabpagenr()-2)<CR>
		" move tab to the right
		noremap <silent> <A-Right> :execute 'silent! tabmove ' . (tabpagenr()+1)<CR>
		noremap <Leader>be :enew<CR>
		" open new to tab to explorer
		nnoremap <S-Tab> gT
		nnoremap <S-e> :tab split<CR>
		nnoremap <S-x> :tabclose<CR>

	" Make
		" nnoremap <Leader>ma :make clean<CR>
					" \:make all<CR>
		nnoremap <Leader>mc :make clean<CR>
		" nnoremap <Leader>mf ::!sudo dfu-programmer atxmega128a4u erase<CR>
					" \:!sudo dfu-programmer atxmega128a4u flash atxmega.hex<CR>
					" \:!sudo dfu-programmer atxmega128a4u start<CR>
		" super custom compile and run command
		nnoremap <Leader>mu :make all<CR>
					\:!sep_calc.exe seprc<CR>
					" \:!sep_calc.exe test.csv WINGS_EGI_GCORE_S3.mod.ini<CR>
		nnoremap <Leader>mi :make all<CR>
					\:!sep_calc.exe some.csv<CR>
		nnoremap <Leader>mo :make all<CR>
					\:!sep_calc.exe nada.csv<CR>

	" Sessions
		nnoremap <Leader>sS :call <SID>SaveSession()<CR>
		nnoremap <Leader>sL :call <SID>LoadSession()<CR>

	" Version Control
		" For all this commands you should be in the svn root folder
		" Add all files
		nnoremap <Leader>vA :!svn add * --force<CR>
		" Add specific files
		nnoremap <Leader>va :!svn add --force
		" Commit using typed message
		nnoremap <Leader>vc :call <SID>SvnCommit()<CR>
		" Commit using File for commit content
		nnoremap <Leader>vC :!svn commit --force-log -F %<CR>
		nnoremap <Leader>vdl :!svn rm --force Log\*<CR>
		nnoremap <Leader>vda :!svn rm --force
		" revert previous commit
		" dangerous key TODO: warn before
		"noremap <Leader>vr :!svn revert -R .<CR>
		nnoremap <Leader>vl :!svn cleanup .<CR>
		" use this command line to delete unrevisioned or "?" svn files
		"noremap <Leader>vL :!for /f "tokens=2*" %i in ('svn status ^| find "?"') do del %i<CR>
		nnoremap <Leader>vs :!svn status .<CR>
		nnoremap <Leader>vu :!svn update .<CR>
		nnoremap <Leader>vo :!svn log .<CR>
		nnoremap <Leader>vi :!svn info<CR>
		" fugitive
			nnoremap <Leader>gs :Gstatus<CR>
			nnoremap <Leader>gp :Gpush<CR>
			nnoremap <Leader>gu :Gpull<CR>
			nnoremap <Leader>ga :!git add
			nnoremap <Leader>gl :silent Glog<CR>
							\:copen 20<CR>

	" Todo mappings
		nnoremap <Leader>td :call <SID>TodoCreate()<CR>
		nnoremap <Leader>tm :call <SID>TodoMark()<CR>
		nnoremap <Leader>tM :call <SID>TodoClearMark()<CR>
		nnoremap <Leader>ta :call <SID>TodoAdd()<CR>
		" pull up todo/quick notes list
		nnoremap <Leader>wt :call <SID>OpenWiki('TODO.md')<CR>
		nnoremap <Leader>wo :call <SID>OpenWiki()<CR>

	" Comments
		nnoremap <Leader>cD :call <SID>CommentDelete()<CR>
		" Comment Indent Increase/Reduce
		nnoremap <Leader>cIi :call <SID>CommentIndent()<CR>
		nnoremap <Leader>cIr :call <SID>CommentReduceIndent()<CR>
		nnoremap cl :call <SID>CommentLine()<CR>

	" Indenting
		nnoremap <Leader>t2 :setlocal ts=2 sw=2 sts=2<CR>
		nnoremap <Leader>t4 :setlocal ts=4 sw=4 sts=4<CR>
		nnoremap <Leader>t8 :setlocal ts=8 sw=8 sts=8<CR>

	" Compiler
		nnoremap <Leader>Cb :compiler borland<CR>
		" msbuild errorformat looks horrible resetting here
		nnoremap <Leader>Cv :compiler msbuild<CR>
									\:set errorformat&<CR>
		nnoremap <Leader>Cg :compiler gcc<CR>
					\:setlocal makeprg=mingw32-make<CR>
		" Note: The placeholder "$*" can be given (even multiple times) to specify
		" where the arguments will be included,

" STATUS_LINE
	" set statusline =
	" set statusline+=\[%n]                                  "buffernr
	" set statusline+=\ %<%F\ %m%r%w                         "File+path
	" set statusline+=\ %y\                                  "FileType
	" set statusline+=\ %{''.(&fenc!=''?&fenc:&enc).''}      "Encoding
	" set statusline+=\ %{(&bomb?\",BOM\":\"\")}\            "Encoding2
	" set statusline+=\ %{&ff}\                              "FileFormat (dos/unix..)
	" set statusline+=\ %=\ row:%l/%L\ (%03p%%)\             "Rownumber/total (%)
	" set statusline+=\ col:%03c\                            "Colnr
	" set statusline+=\ \ %m%r%w\ %P\ \                      "Modified? Readonly? Top/bot.
	" if you want to put color to status line needs to be after command
	" colorscheme. Otherwise this commands clears it the color

" PLUGIN_OPTIONS/MAPPINGS
  " Only load plugin options in case they were loaded
  if b:bLoadPlugins == 1
    "Vim-Plug
      noremap <Leader>Pi :PlugInstall<CR>
      noremap <Leader>Pu :PlugUpdate<CR>
                \:PlugUpgrade<CR>
      " installs plugins; append `!` to update or just :PluginUpdate
      noremap <Leader>Ps :PlugSearch<CR>
      " searches for foo; append `!` to refresh local cache
      noremap <Leader>Pl :PlugClean<CR>
      " confirms removal of unused plugins; append `!` to auto-approve removal

    "Plugin 'scrooloose/nerdcommenter'"
      let NERDUsePlaceHolders=0 " avoid commenter doing weird stuff
      let NERDCommentWholeLinesInVMode=2
      let NERDCreateDefaultMappings=0 " Eliminate default mappings
      let NERDRemoveAltComs=1 " Remove /* comments
      let NERD_c_alt_style=0 " Do not use /* on C nor C++
      let NERD_cpp_alt_style=0
      let NERDMenuMode=0 " no menu
      let g:NERDCustomDelimiters = {
        \ 'vim': { 'left': '"', 'right': '' },
				\ 'wings_syntax': { 'left': '//', 'right': '' }}
        "\ 'vim': { 'left': '"', 'right': '' }
        "\ 'grondle': { 'left': '{{', 'right': '}}' }
      "\ }
      let NERDSpaceDelims=1  " space around comments

      nmap - <plug>NERDCommenterToggle
      nmap <Leader>ct <plug>NERDCommenterAltDelims
      vmap - <plug>NERDCommenterToggle
      imap <C-c> <plug>NERDCommenterInsert
      nmap <Leader>ca <plug>NERDCommenterAppend
      vmap <Leader>cs <plug>NERDCommenterSexy

    "Plugin 'scrooloose/NERDTree'
      noremap <Leader>nb :Bookmark
      let NERDTreeShowBookmarks=1  " B key to toggle
      noremap <Leader>no :NERDTree<CR>
      let NERDTreeShowLineNumbers=1
      let NERDTreeShowHidden=1 " i key to toggle
      let NERDTreeQuitOnOpen=1 " AutoClose after openning file

    " Plugin 'Tagbar' {{{
      let g:tagbar_autofocus = 1
      let g:tagbar_show_linenumbers = 2
      let g:tagbar_map_togglesort = "r"
      let g:tagbar_map_nexttag = "<c-j>"
      let g:tagbar_map_prevtag = "<c-k>"
      let g:tagbar_map_openallfolds = "<c-n>"
      let g:tagbar_map_closeallfolds = "<c-c>"
      let g:tagbar_map_togglefold = "<c-x>"
      noremap <Leader>tt :TagbarToggle<CR>
      noremap <Leader>tk :cs kill -1<CR>
      noremap <silent> <Leader>tj <C-]>
      noremap <Leader>tr <C-t>
      noremap <Leader>tn :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
      " ReLoad cscope database
      noremap <Leader>tl :cs add cscope.out<CR>
      " Find functions calling this function
      noremap <Leader>tc :cs find c <C-R>=expand("<cword>")<CR><CR>
      " Find functions definition
      noremap <Leader>tg :cs find g <C-R>=expand("<cword>")<CR><CR>
      " Find functions called by this function not being used
      " noremap <Leader>td :cs find d <C-R>=expand("<cword>")<CR><CR>
      noremap <Leader>ts :cs show<CR>

    " Plugin 'ctrlpvim/ctrlp.vim' " quick file searchh
			if executable('ag')
        let g:ctrlp_user_command = 'ag -Q -l --smart-case --nocolor --hidden -g "" %s'
      else
        echomsg string("You should install silversearcher-ag. Now you have a slow ctrlp")
      endif
      nnoremap <S-k> :CtrlPBuffer<CR>
      let g:ctrlp_cmd = 'CtrlPMixed'
      " submit ? in CtrlP for more mapping help.
      let g:ctrlp_lazy_update = 1
      let g:ctrlp_show_hidden = 1
      let g:ctrlp_match_window = 'bottom,order:btt,min:1,max:10,results:10'
      let g:ctrlp_cache_dir = s:cache_path . 'ctrlp'
      let g:ctrlp_working_path_mode = 'wra'
      let g:ctrlp_max_history = &history
      let g:ctrlp_clear_cache_on_exit = 0

    " Doxygen.vim
      nnoremap <Leader>cf :Dox<CR>
			" Other commands
			" command! -nargs=0 DoxLic :call <SID>DoxygenLicenseFunc()
			" command! -nargs=0 DoxAuthor :call <SID>DoxygenAuthorFunc()
			" command! -nargs=1 DoxUndoc :call <SID>DoxygenUndocumentFunc(<q-args>)
			" command! -nargs=0 DoxBlock :call <SID>DoxygenBlockFunc()
			let g:DoxygenToolkit_briefTag_pre = "Brief:			"
      let g:DoxygenToolkit_paramTag_pre=	"	"
      let g:DoxygenToolkit_returnTag=			"Returns:   "
      let g:DoxygenToolkit_blockHeader=""
      let g:DoxygenToolkit_blockFooter=""
      let g:DoxygenToolkit_authorName="Reinaldo Molina <rmolin88@gmail.com>"
			let g:DoxygenToolkit_authorTag =	"Author:				"
			let g:DoxygenToolkit_fileTag =		"File:					"
			let g:DoxygenToolkit_briefTag_pre="Description:		"
			let g:DoxygenToolkit_dateTag =		"Date:					"
			let g:DoxygenToolkit_versionTag = "Version:				"
			let g:DoxygenToolkit_commentType = "C++"
			" See :h doxygen.vim this vim related. Not plugin related
			let g:load_doxygen_syntax=1

    " Plugin 'scrooloose/syntastic'
			if exists(':SyntasticCheck')
				nnoremap <Leader>so :SyntasticToggleMode<CR>
				nnoremap <Leader>sn :call <SID>ListsNavigation("next")<CR>
				nnoremap <Leader>sp :call <SID>ListsNavigation("previous")<CR>
				nnoremap <Leader>ss :SyntasticCheck<CR>
				" set statusline+=%#warningmsg#
				" set statusline+=%{SyntasticStatuslineFlag()}
				" set statusline+=%*
				let g:syntastic_always_populate_loc_list = 1
				let g:syntastic_auto_loc_list = 1
				let g:syntastic_check_on_open = 0
				let g:syntastic_check_on_wq = 0
				let g:syntastic_cpp_compiler_options = '-std=c++17 -pedantic -Wall'
				let g:syntastic_c_compiler_options = '-std=c11 -pedantic -Wall'
				let g:syntastic_auto_jump = 3
			endif

    "/Plug 'octol/vim-cpp-enhanced-highlight'
      let g:cpp_class_scope_highlight = 1
      " turning this option breaks comments
      "let g:cpp_experimental_template_highlight = 1

    " Plugin 'morhetz/gruvbox' " colorscheme gruvbox
			colorscheme gruvbox
			set background=dark    " Setting dark mode
			" set background=light
			" colorscheme PaperColor

    " Plug Neocomplete/Deoplete
      if !has('nvim')
        if has('lua')
          " All new stuff
					let g:neocomplete#enable_at_startup = 1
          let g:neocomplete#enable_cursor_hold_i=1
          let g:neocomplete#skip_auto_completion_time="1"
          let g:neocomplete#sources#buffer#cache_limit_size=5000000000
          let g:neocomplete#max_list=8
          let g:neocomplete#auto_completion_start_length=2
          " TODO: need to fix this i dont like the way he does it need my own for now is good I guess
          let g:neocomplete#enable_auto_close_preview=1

          let g:neocomplete#enable_smart_case = 1
          let g:neocomplete#data_directory = s:cache_path . 'neocomplete'
          " Define keyword.
          if !exists('g:neocomplete#keyword_patterns')
            let g:neocomplete#keyword_patterns = {}
          endif
          let g:neocomplete#keyword_patterns['default'] = '\h\w*'
          " Recommended key-mappings.
          " <CR>: close popup and save indent.
          inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
          function! s:my_cr_function()
            return (pumvisible() ? "\<C-y>" : "" ) . "\<CR>"
          endfunction
          " <TAB>: completion.
          inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
          " <C-h>, <BS>: close popup and delete backword char.
          inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
          " Enable heavy omni completion.
          if !exists('g:neocomplete#sources#omni#input_patterns')
            let g:neocomplete#sources#omni#input_patterns = {}
          endif
          let g:neocomplete#sources#omni#input_patterns.tex =
            \ '\v\\%('
            \ . '\a*cite\a*%(\s*\[[^]]*\]){0,2}\s*\{[^}]*'
            \ . '|\a*ref%(\s*\{[^}]*|range\s*\{[^,}]*%(}\{)?)'
            \ . '|includegraphics\*?%(\s*\[[^]]*\]){0,2}\s*\{[^}]*'
            \ . '|%(include%(only)?|input)\s*\{[^}]*'
            \ . ')'
          let g:neocomplete#sources#omni#input_patterns.php =
          \ '[^. \t]->\%(\h\w*\)\?\|\h\w*::\%(\h\w*\)\?'
          let g:neocomplete#sources#omni#input_patterns.perl =
          \ '[^. \t]->\%(\h\w*\)\?\|\h\w*::\%(\h\w*\)\?'
          let g:neocomplete#sources#omni#input_patterns.java = '\h\w*\.\w*'

          if !exists('g:neocomplete#force_omni_input_patterns')
            let g:neocomplete#force_omni_input_patterns = {}
          endif
          let g:neocomplete#force_omni_input_patterns.c =
                \ '[^.[:digit:] *\t]\%(\.\|->\)\w*'
          let g:neocomplete#force_omni_input_patterns.cpp =
                \ '[^.[:digit:] *\t]\%(\.\|->\)\w*\|\h\w*::\w*'
          let g:neocomplete#force_omni_input_patterns.objc =
                \ '\[\h\w*\s\h\?\|\h\w*\%(\.\|->\)'
          let g:neocomplete#force_omni_input_patterns.objcpp =
                \ '\[\h\w*\s\h\?\|\h\w*\%(\.\|->\)\|\h\w*::\w*'
          " all new stuff
          if !exists('g:neocomplete#delimiter_patterns')
            let g:neocomplete#delimiter_patterns= {}
          endif
          let g:neocomplete#delimiter_patterns.vim = ['#']
          let g:neocomplete#delimiter_patterns.cpp = ['::']
        else
          echoerr "No lua installed = No Neocomplete."
          " let g:neocomplete#enable_at_startup = 0 " default option
        endif
      elseif has('python3')
        " if it is nvim deoplete requires python3 to work
        let g:deoplete#enable_at_startup = 1
				" New settings
				let g:deoplete#enable_ignore_case = 1
				let g:deoplete#enable_smart_case = 1
				let g:deoplete#enable_camel_case = 1
				let g:deoplete#enable_refresh_always = 1
				let g:deoplete#max_abbr_width = 0
				let g:deoplete#max_menu_width = 0
				let g:deoplete#omni#input_patterns = get(g:,'deoplete#omni#input_patterns',{})
				let g:deoplete#omni#input_patterns.java = [
						\'[^. \t0-9]\.\w*',
						\'[^. \t0-9]\->\w*',
						\'[^. \t0-9]\::\w*',
						\]
				let g:deoplete#omni#input_patterns.jsp = ['[^. \t0-9]\.\w*']
				let g:deoplete#omni#input_patterns.php = '\h\w*\|[^. \t]->\%(\h\w*\)\?\|\h\w*::\%(\h\w*\)\?'
				let g:deoplete#ignore_sources = {}
				let g:deoplete#ignore_sources.java = ['omni']
				call deoplete#custom#set('javacomplete2', 'mark', '')
				call deoplete#custom#set('_', 'matchers', ['matcher_full_fuzzy'])
				"call deoplete#custom#set('omni', 'min_pattern_length', 0)
				inoremap <expr><C-h> deoplete#mappings#smart_close_popup()."\<C-h>"
				inoremap <expr><BS> deoplete#mappings#smart_close_popup()."\<C-h>"
				" Old settings
				" Settings for javacomplete2
				" let g:deoplete#enable_ignore_case = 1
				" let g:deoplete#enable_smart_case = 1
				" let g:deoplete#enable_refresh_always = 1
				" let g:deoplete#omni#input_patterns = get(g:,'deoplete#omni#input_patterns',{})
				" let g:deoplete#omni#input_patterns.java = [
						" \'[^. \t0-9]\.\w*',
						" \'[^. \t0-9]\->\w*',
						" \'[^. \t0-9]\::\w*',
						" \]
				" let g:deoplete#omni#input_patterns.jsp = ['[^. \t0-9]\.\w*']
				" let g:deoplete#ignore_sources = {}
				" let g:deoplete#ignore_sources._ = ['javacomplete2']
			 
				" " Regular settings
				inoremap <silent><expr> <TAB>
							\ pumvisible() ? "\<C-n>" :
							\ <SID>check_back_space() ? "\<TAB>" :
							\ deoplete#mappings#manual_complete()
				function! s:check_back_space() abort
					let col = col('.') - 1
					return !col || getline('.')[col - 1]  =~ '\s'
				endfunction
				inoremap <expr><C-h>
							\ deoplete#smart_close_popup()."\<C-h>"
				inoremap <expr><BS>
							\ deoplete#smart_close_popup()."\<C-h>"
      else
        echoerr "No python3 = No Deocomplete"
        " so if it doesnt have it activate clang instaed
        let g:deoplete#enable_at_startup = 0
      endif

        " NeoSnippets
      " Plugin key-mappings.
      imap <C-k>     <Plug>(neosnippet_expand_or_jump)
      smap <C-k>     <Plug>(neosnippet_expand_or_jump)
      xmap <C-k>     <Plug>(neosnippet_expand_target)
      smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
      \ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
      " Tell Neosnippet about the other snippets
      let g:neosnippet#snippets_directory= s:plugged_path . '/vim-snippets/snippets'
      let g:neosnippet#data_directory = s:cache_path . 'neosnippets'

    " Vim-Clang
      " Why I switched to Rip-Rip because it works
      " Steps to get plugin to work:
      " 1. Make sure that you can compile a program with clang++ command
        " a. Example: clang++ -std=c++14 -stdlib=libc++ -pedantic -Wall hello.cpp -v
      " 2. To get this to work I had to install libc++-dev package in unix
      " 3. install libclang-dev package. See g:clang_library_path to where it gets
      " installed. Also I had to make sym link: ln -s libclang.so.1 libclang.so
      if !executable('clang')
        echomsg string("No clang or clang-format present")
				let g:clang_complete_loaded = 1
      else
        " TODO: Go copy code from vim-clang that does this
				" if !executable('clang-format')
					" echomsg string("No clang formatter installed")
				" endif
        " nnoremap <c-f> :ClangFormat<CR>

        let g:clang_user_options = '-std=c++14 -stdlib=libc++ -Wall -pedantic'
        " let g:clang_complete_copen = 1
				" let g:clang_periodic_quickfix = 1
      endif

    " Vim-Markdown
      " messes up with neocomplete
      let g:vim_markdown_folding_disabled = 0
      let g:vim_markdown_folding_level = 6
      let g:vim_markdown_conceal = 0

    " Colorizer
      let g:colorizer_auto_filetype='css,html,xml'

    " JavaComplete2
			let g:JavaComplete_ClosingBrace = 1 
			let g:JavaComplete_EnableDefaultMappings = 0 
			let g:JavaComplete_ImportSortType = 'packageName'
			let g:JavaComplete_ImportOrder = ['android.', 'com.', 'junit.', 'net.', 'org.', 'java.', 'javax.']

    " GnuPG
      " This plugin doesnt work with gvim. Use only from cli
      let g:GPGUseAgent = 0

		" ft-java-syntax
			let java_highlight_java_lang_ids=1
			let java_highlight_functions="indent"
			let java_highlight_debug=1
			let java_space_errors=1
			let java_comment_strings=1
			hi javaParen ctermfg=blue guifg=#0000ff

		" Vim-Rooter
			let g:rooter_manual_only = 1
			nnoremap <Leader>cr :Rooter<CR>

		" ft-c-syntax
			let c_gnu = 1
			" Makes it akward when typing
			" If you really need to get rid of these just use <Leader>c<Space>
			" let c_space_errors = 1
			let c_ansi_constants = 1
			let c_ansi_typedefs = 1
			" Breaks too often
			" let c_curly_error = 1

		" FastFold
			" Stop updating folds everytime I save a file
			let g:fastfold_savehook = 0
			" To update folds now you have to do it manually pressing 'zuz'
			let g:fastfold_fold_command_suffixes =
						\['x','X','a','A','o','O','c','C','r','R','m','M','i','n','N']

		" Airline
			let g:airline_theme="term"

			let g:airline#extensions#whitespace#checks = []
			let g:airline#extensions#disable_rtp_load = 1
			let g:airline_extensions = ['branch']

		" Neomake
			if exists(':Neomake')
				let g:neomake_warning_sign = {
				\ 'text': '?',
				\ 'texthl': 'WarningMsg',
				\ }

				let g:neomake_error_sign = {
					\ 'text': 'X',
					\ 'texthl': 'ErrorMsg',
					\ }
			endif
			" delimitMate
				let g:delimitMate_expand_cr = 2
				let g:delimitMate_expand_space = 1
				let g:delimitMate_jump_expansion = 1
				" imap <expr> <CR> <Plug>delimitMateCR
		
		" ft-markdown-syntax
			let g:markdown_fenced_languages= [ 'cpp', 'vim' ]

		" markdown-folding
			let g:markdown_fold_style = 'nested'
	endif

" see :h modeline
" vim:tw=78:ts=2:sts=2:sw=2:
