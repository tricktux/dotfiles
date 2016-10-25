if has('win32')
	" Path variables
	let s:cache_path= $HOME . '\.cache\'
	let s:plugged_path=  $HOME . '\vimfiles\plugged\'
	let s:vimfile_path=  $HOME . '\vimfiles\'
	let s:wiki_path =  $HOME . '\Documents\1.WINGS\NeoWingsSupportFiles\wiki'
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
endif

" FUNCTIONS
function! utils#SetGrep() abort
	" use option --list-file-types if in doubt
	" to specify a type of file just do `--cpp`
	" Add the --type-set=markdown:ext:md option to ucg for it to recognize
	" Use the -t option to search all text files; -a to search all files; and -u to search all, including hidden files.
	" md files
	if executable('rg')
		set grepprg=rg\ --vimgrep
	elseif executable('ucg')
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
function! utils#GitCommit() abort
	if utils#CheckFileOrDir(1, ".git") > 0
		silent !git add .
		execute "silent !git commit -m \"" . input("Commit comment:") . "\""
		!git push origin master
	else
		echo "No .git directory was found"
	endif
endfunction

" Should be performed on root .svn folder
function! utils#SvnCommit() abort
	execute "!svn commit -m \"" . input("Commit comment:") . "\" ."
endfunction

" Special comment function {{{
function! utils#FindIf() abort
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

function! utils#TruncComment(comment) abort
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

" Gotchautils# Start from the bottom up commenting
function! utils#EndOfIfComment() abort
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
				call utils#FindIf()
				" truncate comment line in case too long
				let @7 = utils#TruncComment(@7)
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
			call utils#FindIf()
			" truncate comment line in case too long
			let @7 = utils#TruncComment(@7)
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
		let @8 = utils#TruncComment(@8)
		execute "normal a" . @8 . "\""
	else
		echo "EndOfIfComment(): Closing brace } needs to be present at the line"
	endif
endfunction
" End of Special Comment function }}}

function! utils#CheckDirwPrompt(name) abort
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
function! utils#CheckDirwoPrompt(name) abort
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

function! utils#YankFrom() abort
	execute "normal :" . input("Yank From Line:") . "y\<CR>"
endfunction

function! utils#DeleteLine() abort
	execute "normal :" . input("Delete Line:") . "d\<CR>``"
endfunction

function! utils#ListsNavigation(cmd) abort
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

function! utils#SetDiff() abort
	" Make sure you run diffget and diffput from left window
	nnoremap <C-j> ]c
	nnoremap <C-k> [c
	nnoremap <C-h> :diffget<CR>
	nnoremap <C-l> :diffput<CR>
	windo diffthis
endfunction

function! utils#UnsetDiff() abort
	nnoremap <C-j> zj
	nnoremap <C-k> zk
	nnoremap <C-h> :noh<CR>
	nunmap <C-l>
	diffoff!
endfunction

function! utils#CheckVimPlug() abort
	let b:bLoadPlugins = 0
	if empty(glob(s:vimfile_path . 'autoload/plug.vim'))
		if executable('curl')
			" Create folder
			call utils#CheckDirwoPrompt(s:vimfile_path . "autoload")
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

function! utils#NormalizeWindowSize() abort
	execute "normal \<c-w>="
endfunction

function! utils#FixPreviousWord() abort
	normal mm[s1z=`m
endfunction

function! utils#SaveSession(...) abort
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

function! utils#LoadSession(...) abort
	" save all work
	execute "cd ". s:cache_path ."sessions/"
	" Logic path when not called at startup
	if a:0 < 1
		execute "wall"
		echo "Save Current Session before deleting all buffers: (y)es (any)no"
		let l:iResponse = getchar()
		if l:iResponse == 121 " y
			call utils#SaveSession()
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

function! utils#TodoCreate() abort
	execute "normal Blli\<Space>[ ]\<Space>\<Esc>"
endfunction

function! utils#TodoMark() abort
	execute "normal Bf[lrX\<Esc>"
endfunction

function! utils#TodoClearMark() abort
	execute "normal Bf[lr\<Space>\<Esc>"
endfunction

function! utils#TodoAdd() abort
	execute "normal aTODO.RM-\<F5>: "
endfunction

function! utils#CommentDelete() abort
	execute "normal Bf/D"
endfunction

function! utils#CommentIndent() abort
	execute "normal Bf/i\<Tab>\<Tab>\<Esc>"
endfunction

function! utils#CommentReduceIndent() abort
	execute "normal Bf/hxhx"
endfunction

function! utils#CommentLine() abort
	if exists("*NERDComment")
		execute "normal mm:" . input("Comment Line:") . "\<CR>"
		execute "normal :call NERDComment(\"n\", \"Toggle\")\<CR>`m"
	else
		echo "Please install NERDCommenter"
	endif
endfunction

function! utils#ManFind() abort
	" execute "cexp system('man -wK ". expand("<cword>") ."')"
	" let l:command = printf
	let l:list = system("man -wK " . expand("<cword>"))
	if !empty(l:list)
		for item in l:list
			" Strip name list them so they can be called with Man
		endfor
		cexpr l:list
	endif
	" TODO Sample output below. Strip file name in the form 5 login.conf for
	" example and pass it to Man
	" || /usr/share/man/man5/logind.conf.5.gz
	" || /usr/share/man/man7/systemd.directives.7.gz
endfunction

" To update ctags simply delete the ctags folder
" Note: There is also avr tags created by vimrc/scripts/maketags.sh
" let &tags= s:cache_path . 'ctags/tags'
function! utils#AutoCreateCtags() abort
	if empty(finddir(s:cache_path . "ctags",",,"))
		" Go ahead and create the ctags
		if !executable('ctags')
			echomsg string("Please install ctags")
		else
			" Create folder
			if !utils#CheckDirwoPrompt(s:cache_path . "ctags")
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
function! utils#AutoCreateUnixCtags() abort
	if empty(finddir(s:cache_path . "ctags",",,"))
		" Go ahead and create the ctags
		if !executable('ctags')
			echomsg string("Please install ctags")
			return 0
		else
			" Create folder
			if !utils#CheckDirwoPrompt(s:cache_path . "ctags")
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

	function! utils#LastCommand() abort
		execute "normal :\<Up>\<CR>"
	endfunction

	function! utils#ListFiles(dir) abort
		let l:directory = globpath(a:dir, '*')
		if empty(l:directory)
			echohl ErrorMsg | echom a:dir . " is not a valid directory name" | echohl None
		endif
		return map(split(l:directory,'\n'), "fnamemodify(v:val, ':t')")
	endfunction

	function! MarkdownLevel()
		if getline(v:lnum) =~ '^# .*$'
			return ">1"
		endif
		if getline(v:lnum) =~ '^## .*$'
			return ">2"
		endif
		if getline(v:lnum) =~ '^### .*$'
			return ">3"
		endif
		if getline(v:lnum) =~ '^#### .*$'
			return ">4"
		endif
		if getline(v:lnum) =~ '^##### .*$'
			return ">5"
		endif
		if getline(v:lnum) =~ '^###### .*$'
			return ">6"
		endif
		return "=" 
	endfunction

" Vim-Wiki {{{
" Origin: Wang Shidong <wsdjeg@outlook.com>
" vim-cheat
func! CheatCompletion(ArgLead, CmdLine, CursorPos)
	echom "arglead:[".a:ArgLead ."] cmdline:[" .a:CmdLine ."] cursorpos:[" .a:CursorPos ."]"
	if a:ArgLead =~ '^-\w*'
		echohl WarningMsg | echom a:ArgLead . " is not a valid wiki name" | echohl None
	endif
	return join(utils#ListFiles(s:wiki_path . '//'),"\n")
endfunction

function! utils#WikiOpen(...) abort
	if a:0 > 0
		execute "vs " . s:wiki_path . '/'.  a:1
		return
	endif
	execute "vs " . fnameescape(s:wiki_path . '//' . input('Wiki Name: ', '', 'custom,CheatCompletion'))
endfunction
" }}}

function! utils#WingsSymLink(sPath) abort
	execute "cd " .a:sPath
	let l:path = input("Enter path to new default.ini:", "", "file")
	!del default.ini
	execute "!mklink default.ini " . l:path
	cd -
endfunction

function! utils#MakeUpdateBorlandMakefile() abort
	" If compiler is not borland(set by SetupCompiler) fail.
	if empty(get(b:, 'current_compiler', 0))
		echomsg "Error, not in WINGS folder"
	else
		execute "!bpr2mak -omakefile WINGS.bpr"
	endif
endfunction

function! utils#OpenTerminal() abort
	execute "normal :vs\<CR>\<c-w>l:terminal\<CR>"
endfunction

function! utils#UpdateCscope() abort
	if !executable('cscope') || !executable('ctags')
		echoerr "Please install cscope and/or ctags before using this application"
		return	
	endif
	try
		cs kill -1
	catch
		" Dont do anything if it fails
	endtry
	!rm cscope.files cscope.out cscope.po.out cscope.in.out
	!find . -iregex '.*\.\(c\|cpp\|java\|cc\|h\|hpp\)$' > cscope.files
	!cscope -b -q -i cscope.files
	if !filereadable('cscope.out')
		echoerr "Couldnt create cscope.out files"
		return
	endif
	cs add cscope.out
	silent !ctags -R -L cscope.files -f .tags
	" set tags+=.tags
endfunction

function! utils#SetupCompiler(...)
	if expand('%:p') ==? expand('$MYVIMRC')
		so %
		return
	elseif empty(get(b:, 'current_compiler'))
		let l:path = expand('%:p')
		" Notice inside the '' is a pat which is a regex. That is why \\
		if match(l:path,'NeoOneWINGS\\Source') > 0
			compiler borland
		elseif match(l:path,'NeoOneWINGS') > 0
			compiler msbuild
			silent set errorformat&
		endif
	endif
	make
endfunction

function! utils#WikiSearch() abort
	execute "cd " . s:wiki_path
	execute "grep " . input("Enter wiki search string:")
	cd -
endfunction

" vim:tw=78:ts=2:sts=2:sw=2:
