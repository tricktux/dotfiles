
" File:					utils.vim
" Description:	Function Container
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:			2.0.0
" Date:					Mon Mar 06 2017 09:22

" FUNCTIONS
function! utils#SetGrep() abort
	if executable('rg')
		" use option --list-file-types if in doubt
		" rg = ripgrep
		"Use the -t option to search all text files; -a to search all files; and -u to search all, including hidden files.
		set grepprg=rg\ --vimgrep
		set grepformat=%f:%l:%c:%m
	elseif executable('ucg')
		" Add the --type-set=markdown:ext:md option to ucg for it to recognize
		" md files
		set grepprg=ucg\ --nocolor\ --noenv
	elseif executable('ag')
		" ctrlp with ag
		" see :Man ag for help
		" to specify a type of file just do `--cpp`
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
	execute "!svn commit -m \"" . input("Commit comment:") . "\""
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
		let dir = getcwd()
		execute "cd ". g:cache_path ."sessions/"
		let l:sSessionName = input("Enter
					\ save session name:", "", "file")
		silent! execute "cd " . dir
	else
		" Need to keep this option short and sweet
		let l:sSessionName = a:1
	endif
	silent! execute "normal :mksession! " . g:cache_path . "sessions/". l:sSessionName  . "\<CR>"
endfunction

function! utils#LoadSession(...) abort
	" Logic path when not called at startup
	if a:0 < 1
		execute "wall"
		echo "Save Current Session before deleting all buffers: (y)es (any)no"
		let l:iResponse = getchar()
		if l:iResponse == 121 " y
			call utils#SaveSession()
		endif
		let l:sSessionName = input("Enter load session name:", "", "file")
		silent! execute "normal :%bdelete\<CR>"
		silent execute "normal :so " . g:cache_path . "sessions/". l:sSessionName . "\<CR>"
	else
		" echo "Reload previous session: (j|y)es (any)no"
		" let response = getchar()
		" if response == 121 || response == 106 " y|j
			 " silent! execute "normal :so " . g:cache_path . "sessions/". a:1 . "\<CR>"
		" endif
		silent! execute "normal :%bdelete\<CR>"
		silent! execute "normal :so " . g:cache_path . "sessions/". a:1 . "\<CR>"
	endif
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
	return join(utils#ListFiles(g:wiki_path . '//'),"\n")
endfunction

function! utils#WikiOpen(...) abort
	if a:0 > 0
		execute "vs " . g:wiki_path . '/'.  a:1
	else
		execute "vs " . fnameescape(g:wiki_path . '//' . input('Wiki Name: ', '', 'custom,CheatCompletion'))
	endif
endfunction
" }}}

function! utils#WingsSymLink(sPath) abort
	let dir = getcwd()
	execute "cd " .a:sPath
	let l:path = input("Enter path to new default.ini:", "", "file")
	!del default.ini
	execute "!mklink default.ini " . l:path
	silent! execute "cd " . dir
endfunction

function! utils#UpdateBorlandMakefile() abort
	" If compiler is not borland(set by SetupCompiler) fail.
	if !exists('b:current_compiler')
		echomsg "Error, not in WINGS folder"
	else
		execute "!bpr2mak -omakefile WINGS.bpr"
	endif
endfunction

function! utils#OpenTerminal() abort
	let sys = system('uname -o')
	if sys =~ 'Android'
		execute "normal :vs\<CR>\<c-w>l:e term:\/\/bash\<CR>"
	else
		execute "normal :vs\<CR>\<c-w>l:terminal\<CR>"
	endif
endfunction

function! utils#UpdateCscope() abort
	if !executable('cscope') || !executable('ctags')
		echoerr "Please install cscope and/or ctags before using this application"
		return
	endif

	if has('nvim') && has('python3') " Use asynch nvim call instead
		call UpdateTagsRemote()
		return	
	elseif has('python3')			" If python3 is available use it
		call python#UpdateCtags()
		return
	endif

	silent! cs kill -1
	if has('unix')
		!rm cscope.files cscope.out cscope.po.out cscope.in.out
		!find . -iregex '.*\.\(c\|cpp\|java\|cc\|h\|hpp\)$' > cscope.files
	else
		!del /F cscope.files cscope.in.out cscope.po.out cscope.out
		!dir /b /s *.java *.cpp *.h *.hpp *.c *.cc *.cs > cscope.files
	endif
	!cscope -b -q -i cscope.files
	if !filereadable('cscope.out')
		echoerr "Couldnt create cscope.out files"
		return
	endif
	cs add cscope.out
	" The extra=+q option is to highlight memebers
	" Keep in mind that you are forcing the tags to be c++
	silent !ctags -R -L cscope.files -f .tags --sort=yes --c++-kinds=+pl --fields=+iaS --extra=+q --language-force=C++
	" set tags+=.tags
endfunction

function! utils#Make()
	let filet = &filetype
	if filet =~ 'vim'
		so %
		return
	elseif filet =~ 'python' && executable('flake8')
		Neomake
		return
	elseif has('win32')
		let l:path = expand('%:p')
		" if l:path =~ 'UnrealProjects' && executable('clang-format') && exists(':Autoformat')
			" Autoformat
		" endif
		if !exists('b:current_compiler')
			" Notice inside the '' is a pat which is a regex. That is why \\
			if l:path =~ 'OneWINGS\\Source'
				compiler borland
			elseif l:path =~ 'OneWINGS' || l:path =~ 'UnrealProjects'
				compiler msbuild
				silent set errorformat&
			else " if outside wings folder set gcc compiler
				compiler gcc
				setlocal makeprg=mingw32-make
			endif
		endif
	endif
	Neomake! " Used to run make asynchronously
endfunction

function! utils#WikiSearch() abort
	let dir = getcwd()
	execute "cd " . g:wiki_path
	execute "grep " . input("Enter wiki search string:")
	silent! execute "cd " . dir
endfunction

function! utils#ToggleTerm() abort
	if has('nvim')
		if empty(bufname("term://*"))
			" split window and term
			call utils#OpenTerminal()
		else
			execute "b " . bufname("term*")
		endif
	else
		echoerr "<term> only available on nvim"
	endif
endfunction

function! utils#GuiFont(sOp) abort
	let sub = has('win32') ? ':h\zs\d\+' : '\ \zs\d\+'
	if has('nvim') && exists('g:GuiLoaded') && exists(':Guifont')
		" Capture output of Guifont
		redir => guifont_out
		silent Guifont
		redir END
		" Substitute last number with a plus or minus value depending on input
		if !empty(guifont_out)
			let new_cmd = substitute(guifont_out, sub,'\=eval(submatch(0)'.a:sOp.'1)','')			
			echomsg new_cmd
			execute "GuiFont! " . new_cmd
		endif
	else " gvim
		let &guifont = substitute(&guifont, sub,'\=eval(submatch(0)'.a:sOp.'1)','')
	endif
endfunction

function! utils#EditPlugins() abort
	let dir = getcwd()
	execute "cd " .g:plugged_path
	execute "e " . input('e ' . expand(g:plugged_path), "", "file")
	silent! execute "cd " . dir
endfunction

function! utils#FormatFile() abort
	let type = &ft
	if type ==# 'cpp' || type ==# 'java' || type ==# 'c'
		" if executable("astyle") && exists(":Autoformat")
		if executable('clang-format')
			Autoformat
		else
			echomsg string("No clang-format present")
		endif
	"elseif &ft ==? 'java' " vim-javafmt its not working
		"if exists(":JavaFmt")
			"JavaFmt
		"else
			"echomsg string("No java-fmt present")
		"endif
	else
		echomsg string("No formatter set for this filetype")
	endif
endfunction

function! utils#UpdateHeader()
	exe "normal! mz"
  if line("$") > 20
    let l = 20
  else
    let l = line("$")
  endif
	" Last Modified
  silent exe "1," . l . "g/Last Modified:/s/Last Modified:.*/Last Modified: " .
  \ strftime("%a %b %d %Y %H:%M")
	" Last Author
	silent exe "1," . l . "g/Last Author:/s/Last Author:.*/Last Author: " .
				\ " Reinaldo Molina"
	" Date
	silent exe "1," . l . "g/Date:/s/Date:.*/Date:					" .
				\ strftime("%a %b %d %Y %H:%M")
	exe "normal! `z"
	" TODO.RM-Sat Nov 26 2016 00:06: Add Last Author
	" See getmatches, and matchadd()
endfun

" Default Wings mappings are for laptop
function! utils#SetWingsPath(sPath) abort
	execute "nnoremap <Leader>e21 :silent e " . a:sPath . "OneWings/"
	execute "nnoremap <Leader>e22 :silent e " . a:sPath . "OneWingsSupFiles/"
	execute "nnoremap <Leader>ed :silent e ". a:sPath . "OneWings/default.ini<CR>"
	execute "nnoremap <Leader>ewl :call utils#WingsSymLink('" . expand(a:sPath) . "OneWings')<CR>"

	" Mappings
	execute "nnoremap <Leader>cs :cd ". g:wings_path . "OneWingsSupFiles<CR>"
	execute "nnoremap <Leader>co :cd ". g:wings_path . "OneWings<CR>"

	" Mappings to execute programs
	execute "nnoremap <Leader>ewd :Start! " . a:sPath . "OneWings/WINGS.exe 3 . default.ini<CR>"
	execute "nnoremap <Leader>ewu :Start! " . a:sPath . "OneWings/WINGS.exe 3 . %<CR>"
	execute "nnoremap <Leader>ewc :Start! " . a:sPath . "OneWings/WINGS.exe 3 . "

	" Time runtime of a specific program
	nnoremap <Leader>mt :Dispatch powershell -command "& {&'Measure-Command' {.\sep_calc.exe seprc}}"<CR>
	nnoremap <Leader>mu :call utils#UpdateBorlandMakefile()<CR>
	call utils#GuiFont('+')
endfunction

" Source: http://vim.wikia.com/wiki/Easily_switch_between_source_and_header_file
function! utils#SwitchHeaderSource()
	if expand("%:e") == "cpp" || expand("%:e") == "c"
		try " Replace cpp or c with hpp
			find %:t:r.hpp
		catch /:E345:/ " catch not found in path and try to find then *.h
			find %:t:r.h
		endtry
	else
		try
			find %:t:r.cpp
		catch /:E345:/
			find %:t:r.c
		endtry
	endif
endfun

function! utils#NeomakeOpenWindow() abort
	if g:neomake_hook_context.file_mode
		let loc_text = getloclist(0)
		if len(loc_text) == 0
			echo "Success"
			return
		endif
		echon "(1 of " len(loc_text) "):" bufname(loc_text[0].bufnr) '|' loc_text[0].lnum '|: ' loc_text[0].text
	else
		let qf_text = getqflist()
		if len(qf_text) == 0
			echo "Success"
			return
		endif
		echon "(1 of " len(qf_text) "):" bufname(qf_text[0].bufnr) '|' qf_text[0].lnum '|: ' qf_text[0].text
	endif
endfunction

function! utils#FileTypeSearch() abort
	let grep_engine = &grepprg

	" In the case that rg or ag doesnt exist perform simple search
	if grep_engine !~ 'rg' && grep_engine !~ 'ag'
		let search = input("Please enter search word:")
		exe ":grep " . search
		echon '|Grep Engine:' &grepprg ' |FileType: All| CWD: ' getcwd()
		return
	endif

	" Otherwise allow user to specify `filetype`
	let user_ft_selection = inputlist([
				\ 'Please select the filetypes to search:',
				\ '1 - ' . &filetype,
				\ '2 - All filetypes'])
				" \ '3 - To specify a different type'])
	let search = input("Please enter search word:")
	if &grepprg =~ 'rg'
		" rg filetype for vim files is called vimscript
		let rg_ft = &ft
		if &ft =~ 'vim'
			let rg_ft = 'vimscript'
		endif
		if user_ft_selection == 1
			exe ":grep -t " . rg_ft . ' ' . search
			echon '|Grep Engine:' &grepprg ' |FileType: ' rg_ft '| CWD: ' getcwd()
		else
			exe ":grep " . search
			echon '|Grep Engine:' &grepprg ' |FileType: All| CWD: ' getcwd()
		endif
	elseif &grepprg =~ 'ag'
		if user_ft_selection == 1
			exe ":grep --" . &ft . ' ' . search
			echon '|Grep Engine:' &grepprg ' |FileType: ' &ft '| CWD: ' getcwd()
		else
			exe ":grep " . search
			echon '|Grep Engine:' &grepprg ' |FileType: All| CWD: ' getcwd()
		endif
	endif
endfunction

function! utils#SvnWingsSetup() abort
	" let g:svnj_branch_url = [ g:wings_svn_url . 'OneWings/branches/OneWings_19',
				" \  g:wings_svn_url . 'OneWings/tags/OneWings-005'
				" \ ]

	" let g:svnj_trunk_url =   g:wings_svn_url . 'OneWings/trunk'

	" " Creating a branch
	" TODO.RM-Wed Feb 22 2017 17:15: Create this SvnCopy()  
endfunction

function! utils#SetTags() abort
	if has('win32')
		" TODO.RM-Mon Feb 27 2017 12:04: Make this better in a function. Like is
		" close but not really working
		let tags_buff = split(system('cd %userprofile%\.cache && dir tags* /b'), "\n")
		" set tags+=~/.cache/tags_unreal
		" set tags+=~/.cache/tags_clang

		call map(tags_buff, 'v:val . ","') " Append commas to values
		for t in tags_buff
			let &tags .= t
		endfor
	else
		let tags_buff = split(system("find ~/.cache/ -name tags* -print -maxdepth 1"), "\n")
		let sys = 0
		if !empty(tags_buff)
			call map(tags_buff, '"," . v:val') " Append commas to values
			for t in tags_buff
				let &tags .= t
				" Check to see if specific tags where loaded
				if t =~# 'tags_sys'
					let sys = 1
					" elseif =~# 'tags_unreal'
					" let unreal = 1
				endif
			endfor
		endif
		" TODO.RM-Fri Mar 03 2017 22:10: These tags are super heafty. Maybe use it
		" as example for creating other auto tags not so heavy but not
		if !sys && executable('ctags')
			" Create tags
			!ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ -f ~/.cache/tags_sys /usr/include
			!ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ -f ~/.cache/tags_sys2 /usr/local/include
		endif
	endif
	" Note: There is also avr tags created by .dotfiles/scripts/maketags.sh
endfunction

function! utils#RooterAutoloadCscope() abort
	Rooter
	redir => cs_show
	silent! cs show
	redir END
	if cs_show =~# 'no cscope connection' && !empty(glob('cscope.out'))
		cs add cscope.out
	endif
	echo getcwd()
endfunction

" Excellent function but useless since pandoc prints shitty reports
"TODO.RM-Mon Mar 06 2017 09:05: Try to get pandoc to print something useful  
function! utils#ConvertWeeklyReport() abort
	if !executable('pandoc')
		echohl ErrorMsg
		echo "Missing pandoc executable from path"
		echohl None
		return -1
	endif

	" Cd into current buffer file dir
	let dir_buff = getcwd()
	execute "cd " . expand('%:p:h')

	" Execute command
	cexpr systemlist("pandoc WeeklyReport.md -s -o WeeklyReport_ReinaldoMolina_" . strftime("%b-%d-%Y") . ".pdf")

	execute "cd " dir_buff
endfunction

function! utils#AutoHighlightToggle()
	let @/ = ''
	if exists('#auto_highlight')
		au! auto_highlight
		augroup! auto_highlight
		setl updatetime=4000
		echo 'Highlight current word: off'
		return 0
	else
		augroup auto_highlight
			au!
			" au CursorHold  *.py,*.c,*.cpp,*.h,*.hpp let @/ = '\V\<'.escape(expand('<cword>'), '\').'\>'
			au CursorHold  *.py,*.c,*.cpp,*.h,*.hpp exe printf('match IncSearch /\<%s\>/', expand('<cword>')) 
		augroup end
		setl updatetime=500
		echo 'Highlight current word: ON'
		return 1
	endif
endfunction

" TODO.RM-Sat Nov 26 2016 00:04: Function that auto adds SCR # and description
" vim:tw=78:ts=2:sts=2:sw=2:
