" File:					utils.vim
" Description:	Function Container
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:			2.0.0
" Date:					Mon Mar 06 2017 09:22

" FUNCTIONS
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
function! utils#CheckDirWoPrompt(name) abort
	if !has('file_in_path')
		echomsg "utils#CheckDirWoPrompt(): This vim install has no support for +find_in_path"
		return
	endif

	if !empty(finddir(a:name,",,"))
		return
	endif

	if !exists("*mkdir")
		echomsg "CheckDirwoPrompt(): This vim install has no support creating directories"
		return
	endif

	if has('unix')    " have to test check works fine on linux
		call mkdir(expand(a:name), 'p')
	else              " on win prepare name by escaping '\'
		call mkdir(escape(expand(a:name), '\'), 'p')
	endif
endfunction

function! utils#SetDiff() abort
	" Make sure you run diffget and diffput from left window
	if !executable('diff')
		echoerr 'diff is not executable. Please install it'
		return
	endif

	try
		windo diffthis
	catch
		echoerr 'diff command failed. Make sure it is installed correctly'
		echoerr v:exception
		diffoff!
		return
	endtry
	nnoremap <C-j> ]c
	nnoremap <C-k> [c
	nnoremap <C-h> :diffget<CR>
	nnoremap <C-l> :diffput<CR>
endfunction

function! utils#UnsetDiff() abort
	nnoremap <C-j> zj
	nnoremap <C-k> zk
	nnoremap <C-h> :noh<CR>
	nunmap <C-l>
	diffoff!
endfunction

function! utils#FixPreviousWord() abort
	normal mm[s1z=`m
	return ''
endfunction

function! utils#TodoCreate() abort
	execute "normal! ^lli[ ]\<Space>\<Esc>"
endfunction

function! utils#TodoMark() abort
	execute "normal! ^f[lrx\<Esc>"
endfunction

function! utils#TodoClearMark() abort
	execute "normal! ^f[lr\<Space>\<Esc>"
endfunction

function! utils#TodoAdd() abort
	execute "normal! O" . &commentstring[0] . " "
	execute "normal! ==a TODO-[RM]-(" . strftime("%a %b %d %Y %H:%M") . "): "
endfunction

function! utils#ListFiles(dir) abort
	let l:directory = globpath(a:dir, '*')
	if empty(l:directory)
		" echohl ErrorMsg | echom a:dir . " is not a valid directory name" | echohl None
		return []
	endif
	return map(split(l:directory,'\n'), "fnamemodify(v:val, ':t')")
endfunction

" Vim-Wiki {{{
" Origin: Wang Shidong <wsdjeg@outlook.com>
" vim-cheat
function! CheatCompletion(ArgLead, CmdLine, CursorPos)
	echom "arglead:[".a:ArgLead ."] cmdline:[" .a:CmdLine ."] cursorpos:[" .a:CursorPos ."]"
	if a:ArgLead =~ '^-\w*'
		echohl WarningMsg | echom a:ArgLead . " is not a valid wiki name" | echohl None
	endif
	return join(utils#ListFiles(g:wiki_path . '//'),"\n")
endfunction

function! utils#WikiOpen(...) abort
	if !exists('g:wiki_path') || empty(glob(g:wiki_path))
		echoerr 'Variable g:wiki_path not set or path doesnt exist'
		return
	endif

	if a:0 > 0
		execute "vs " . g:wiki_path . '/'.  a:1
	else
		if exists(':Denite')
			call utils#DeniteRec(g:wiki_path)
		else
			let dir = getcwd()
			execute "cd " . g:wiki_path
			execute "vs " . fnameescape(g:wiki_path . '/' . input('Wiki Name: ', '', 'custom,CheatCompletion'))
			silent! execute "cd " . dir
		endif
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

function! utils#OpenTerminal() abort
	let sys = system('uname -o')
	if sys =~ 'Android'
		execute "normal :vs\<CR>\<c-w>l:e term:\/\/bash\<CR>"
	else
		execute "normal :vs\<CR>\<c-w>l:terminal\<CR>"
	endif
endfunction

function! utils#Make()
	let filet = &filetype
	if filet =~ 'vim'
		so %
		return
	elseif filet =~ 'python' && executable('flake8')
		Neomake
		return
	endif
	Neomake! " Used to run make asynchronously
endfunction

function! utils#WikiSearch() abort
	if !exists('g:wiki_path') || empty(glob(g:wiki_path))
		echoerr 'Variable g:wiki_path not valid'
		return
	endif

	" TODO-[RM]-(Sun Oct 15 2017 15:53): fix this here not to use denite
	if !exists(':Denite')
		let dir = getcwd()
		execute "cd " . g:wiki_path
		execute "grep " . input("Enter wiki search string:")
		silent! execute "cd " . dir
		return
	endif

	execute "Denite grep -path=`g:wiki_path`"
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
	if has('nvim') && exists('g:GuiLoaded') && exists('g:GuiFont')
		" Substitute last number with a plus or minus value depending on input
		let new_cmd = substitute(g:GuiFont, ':h\zs\d\+','\=eval(submatch(0)'.a:sOp.'1)','')
		echomsg new_cmd
		call GuiFont(new_cmd, 1)
	else " gvim
		let sub = has('win32') ? ':h\zs\d\+' : '\ \zs\d\+'
		let &guifont = substitute(&guifont, sub,'\=eval(submatch(0)'.a:sOp.'1)','')
	endif
endfunction

" TODO-[RM]-(Mon Sep 18 2017 16:45): No idea whats going on here. Fix here.
" Optional argument to specify if you want to ask for to use denite or not
function! utils#EditFileInPath(path, ...) abort
	if empty(glob(a:path))
		echoerr 'Input is not a valid path: ' . a:path
		return
	endif

	if exists(':Denite') && a:0 > 0 && a:1 > 0
		" ask for denite
		echo 'Use denite?'
		let c = nr2char(getchar())
		if c == "y" || c == "j"
			let den = 1
		else
			let den = 0
		endif
	else
		let den = 0
	endif

	if den > 0
		execute "Denite -path=". a:path . " file_rec"
	else
		let dir = getcwd()
		execute "cd " . a:path
		execute "e " . input('e ' . expand(a:path) . '/', "", "file")
		silent! execute "cd " . dir
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
	" silent exe "1," . l . "g/Last Author:/s/Last Author:.*/Last Author: " .
				" \ " Reinaldo Molina"
	" Date
	silent exe "1," . l . "g/[Dd]ate:/s/[Dd]ate:.*/date:					" .
				\ strftime("%a %b %d %Y %H:%M")
	exe "normal! `z"
endfun

" TODO.RM-Fri Apr 28 2017 16:14: Also move this to the ftplugin
" Use current 'grepprg' to search files for text
"		filteype - Possible values: 1 - Search only files of type 'filetype'. Any
"								other value search all types of values
"		word - Possible values: 1 - Search word under the cursor. Otherwise prompt
"		for search word
function! utils#FileTypeSearch(filetype, word) abort
	let grep_engine = &grepprg

	if a:word == 1
		let search = expand("<cword>")
	else
		let search = input("Please enter search word:")
	endif

	let file_type_search = &ft
	if grep_engine =~# 'rg'
		" rg filetype for vim files is called vimscript
		if file_type_search =~# 'vim'
			let file_type_search = '-t vimscript'
		elseif file_type_search =~# 'python'
			let file_type_search = '-t py'
		else
			let file_type_search = '-t ' . file_type_search
		endif
	elseif grep_engine =~# 'ag'
			let file_type_search = '--' . file_type_search
	else
		" If it is not a recognized engine do not do file type search
		exe ":grep! " . search
		echomsg '|Grep Engine:' grep_engine ' |FileType: All| CWD: ' getcwd()
		return
	endif

	if a:filetype == 1
		exe ":grep " . file_type_search . ' ' . search
		echon '|Grep Engine:' grep_engine ' |FileType: ' file_type_search '| CWD: ' getcwd()
	else
		exe ":grep " . search
		echon '|Grep Engine:' grep_engine ' |FileType: All| CWD: ' getcwd()
	endif
endfunction

" Kinda deprecated function because cscope databases are no longer created at
" repo root
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
		echoerr 'Missing pandoc executable from path'
		return -1
	endif
	let loc_out = 'D:\2.Office\HPD\' . strftime('%Y')
	" Create folder in case it doesnt exist
	if empty(glob(loc_out))
		if !exists('*mkdir')
			echoerr 'utils#ConvertWeeklyReport(): Base folder doesnt exist and cannot create it'
		else
			call mkdir(loc_out, "p")
		endif
	endif

	" Thu Nov 02 2017 17:07: keep working here
	let out_name = loc_out . '\WeeklyReport_ReinaldoMolina_' . strftime('%b-%d-%Y') . '.docx'
	if filereadable(out_name)
		call delete(out_name)
	endif

	let in_name = 'D:\wiki_work\WeeklyReport.md'

	if !filereadable(in_name)
		echoerr 'Source file ' . in_name . ' not found'
		return
	endif

	" Execute command
	cexpr systemlist('pandoc ' . in_name . ' -s -o ' . out_name . ' --from markdown')
endfunction

function! utils#AutoHighlightToggle()
	let @/ = ''
	if exists('#auto_highlight')
		au! auto_highlight
		augroup! auto_highlight
		setl updatetime=4000
		" echo 'Highlight current word: off'
		unlet! g:highlight
		return 0
	else
		augroup auto_highlight
			au!
			" au CursorHold  *.py,*.c,*.cpp,*.h,*.hpp let @/ = '\V\<'.escape(expand('<cword>'), '\').'\>'
			au CursorHold  *.py,*.c,*.cpp,*.h,*.hpp exe printf('silent! match IncSearch /\<%s\>/', expand('<cword>'))
		augroup end
		setl updatetime=500
		" echo 'Highlight current word: ON'
		let g:highlight = 1
		return 1
	endif
endfunction

" Custom command
function! utils#CaptureCmdOutput(...)
	" this function output the result of the Ex command into a split scratch buffer
	if a:0 == 0
		return
	endif
	let cmd = join(a:000, ' ')
	if cmd[0] == '!'
		vnew
		setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted
		execute "read " . cmd
		return
	endif
	redir => output
	execute cmd
	redir END
	if empty(output)
		echoerr "No output from: " . cmd
	else
		vnew
		setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted
		put! =output
	endif
endfunction

" Change vim colorscheme depending on time of the day
function! utils#Flux() abort
	if get(g:, 'flux_enabled', 1) == 0
		return
	endif

	if strftime("%H") >= g:colorscheme_night_time || strftime("%H") < g:colorscheme_day_time
		" Its night time
		if	&background !=# 'dark' ||
				\ !exists('g:colors_name') ||
				\ g:colors_name !=# g:colorscheme_night
			call utils#ChangeColors(g:colorscheme_night, 'dark')
		endif
	else
		" Its day time
		if !exists('g:colors_name')
			let g:colors_name = g:colorscheme_day
		endif
		if &background !=# 'light' ||
					\ !exists('g:colors_name') ||
					\ g:colors_name !=# g:colorscheme_day
			call utils#ChangeColors(g:colorscheme_day, 'light')
		endif
	endif
endfunction

function! utils#ChangeColors(scheme, background) abort
	if a:background ==# 'dark'
		let color = g:black
	elseif a:background ==# 'light'
		let color = g:white
	else
		echoerr 'Only possible backgrounds are dark and light'
		return
	endif

	execute "colorscheme " . a:scheme
	let &background=a:background
	" Restoring these after colorscheme. Because some of them affect by the colorscheme
	call highlight#SetAll('IncSearch',	{ 'bg': color })
	call highlight#SetAll('Search', { 'fg' : g:yellow, 'deco' : 'bold', 'bg' : g:turquoise4 })
	call highlight#Set('Comment', { 'deco' : 'italic' })

	" If using the lightline plugin then update that as well
	" this could cause trouble if lightline does not that colorscheme
	call plugin_lightline#UpdateColorscheme()
endfunction

function! utils#ProfilePerformance() abort
	if exists('g:std_cache_path')
		execute 'profile start ' . g:std_cache_path . '/profile_' . strftime("%m%d%y-%H.%M.%S") . '.log'
	else
		" TODO.RM-Mon Apr 24 2017 12:17: Check why this function is not working
		" execute 'profile start ~/.cache/profile_' . strftime("%m%d%y-%T") . '.log'
		execute 'profile start ~/.cache/profile_' . strftime("%m%d%y-%H.%M.%S") . '.log'
	endif
	execute 'profile func *'
	execute 'profile file *'
endfunction

function! utils#SearchHighlighted() abort
	if exists(':Wcopen')
		" Yank selection to reg a then echo it cli
		execute "normal \"ay:Wcsearch duckduckgo \<c-r>a\<cr>"
	else
		echoerr string('Missing plugin: vim-www')
	endif
endfunction

" TODO.RM-Sat Nov 26 2016 00:04: Function that auto adds SCR # and description
"
" Source: http://vim.wikia.com/wiki/Easily_switch_between_source_and_header_file
function! utils#SwitchHeaderSource() abort
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
endfunction

function! utils#TmuxMove(direction)
	let wnr = winnr()
	silent! execute 'wincmd ' . a:direction
	" If the winnr is still the same after we moved, it is the last pane
	if wnr == winnr()
		call system('tmux select-pane -' . tr(a:direction, 'phjkl', 'lLDUR'))
	endif
endfunction

function! utils#MastersDropboxOpen(wiki) abort
	let db_path = get(g:, 'dropbox_path', "~/Dropbox/masters")
	let db_path .= a:wiki

	if empty(a:wiki) " Use Denite
		call utils#DeniteRec(db_path)
	elseif !filereadable(db_path)
		echoerr "File " . db_path . " does not exists"
		return
	endif
	execute "edit " . db_path
endfunction

function! utils#DeniteRec(path) abort
	if !exists(':Denite')
		let dir = getcwd()
		execute "cd " . a:path
		execute "e " . input('e ' . expand(a:path) . '/', "", "file")
		silent! execute "cd " . dir
		return
	endif

	if empty(glob(a:path))
		echoerr 'Folder ' . a:path . 'not found'
		return
	endif

	execute "Denite -path=" . a:path . " file_rec"
endfunction

function! utils#CurlDown(file_name, link) abort
	if !executable('curl')
		echoerr 'curl is not installed'
		return
	endif

	execute "!curl -kfLo " . a:file_name . " --create-dirs " . a:link
endfunction

function! utils#ChooseEmailAcc() abort
	let choice = confirm("Please choose an email:",
				\ "&Gmail\n&Honeywell\n&PSU", 1)

	if choice == 1
		return 'rmolin88 at gmail dot com'
	elseif choice == 2
		return 'reinaldo.molinaperez at honeywell dot com'
	elseif choice == 3
		return 'rim18 at psu dot edu'
	endif

	return ''
endfunction

" TODO.RM-Thu Mar 16 2017 08:36: Update this function to make it async. Maybe the whole plugin be async
" This function gets called on BufEnter
" Call the function from cli with any argument to obtain debugging output
function! utils#UpdateSvnBranchInfo() abort
	if !executable('svn')
		return ''
	endif

	if !exists('g:root_dir') || empty(g:root_dir) || empty(finddir(g:root_dir . '/.svn'))
		return ''
	endif

	let cmd = 'svn info ' . g:root_dir .  ' | ' .
				\ (executable('grep') ? 'grep': 'findstr') . ' "Relative URL"'

	" echomsg 'g:root_dir = ' . g:root_dir
	" echomsg 'cmd = ' . cmd

	let info = systemlist(cmd)
	if v:shell_error
		" echomsg 'v:shell_error = 1'
		return ''
	endif

	" echomsg 'here'
	" The system function returns something like "Relative URL: ^/...."
	" Strip from "^/" forward and put that in status line
	for line in info
		let index = stridx(line, "^/")

		" echomsg 'line = ' . line
		if index >= 0
			let url = line
			break
		endif
	endfor

	" echomsg 'here 1'

	if index == -1
		" echomsg 'index == -1'
		return ''
	endif

	let pot_display = url[index+2:-1] " Again skip last char. Looks ugly
	" echomsg 'pot_display = ' . pot_display

	" echomsg 'here 2'

	if strlen(pot_display) > 20
		return pot_display[0:20] . '...'
	endif

	return pot_display
endfunction


function! utils#Grep() abort
	let msg = 'Searching inside "' . getcwd() . '". Choose:'
	let choice = "&J<cword>/". &ft . "\n&K<any>/". &ft . "\n&L<cword>/all_files\n&;<any>/all_files"
	let c = confirm(msg, choice, 1)

	if c == 1
		" Search '&filetype' type of files, and word under the cursor
		call utils#FileTypeSearch(1, 1)
	elseif c == 2
		" Search '&filetype' type of files, and prompt for search word
		call utils#FileTypeSearch(1, 8)
	elseif c == 3
		" Search all type of files, and word under the cursor
		call utils#FileTypeSearch(8, 1)
	else
		" Search all type of files, and prompt for search word
		call utils#FileTypeSearch(8, 8)
	endif
endfunction

function! utils#CommentDelete() abort
	execute "normal! ^f/D"
endfunction

function! utils#CommentIndent() abort
	execute "normal! ^f/i\<Tab>\<Tab>\<Esc>"
endfunction

function! utils#CommentReduceIndent() abort
	execute "normal! ^f/hxhx"
endfunction

" TODO-[RM]-(Fri Dec 01 2017 05:36): This function could be heavily improved by adding
" color and also making vim understand its output
" - Sample output without color
" || ./applying-uml-and-patterns-3rd.pdf-59-"waterfall" process), iterative and evolutionary development is based on an attitude of embracing
" || ./applying-uml-and-patterns-3rd.pdf:59:change and adaptation as unavoidable and indeed essential drivers.
" || ./applying-uml-and-patterns-3rd.pdf-59-This is not to say that iterative development and the UP encourage an uncontrolled and reactive
function! utils#SearchPdf() abort
	if !executable('pdfgrep')
		echoe 'Please install "pdfgrep"'
		return
	endif

	if exists(':Grepper')
		execute ':Grepper -tool pdfgrep'
		return
	endif

	let grep_buf = &grepprg

	setlocal grepprg=pdfgrep\ --ignore-case\ --page-number\ --recursive\ --context\ 1
	return utils#FileTypeSearch(8, 8)

	let &l:grepprg = grep_buf
endfunction

function! utils#TrimWhiteSpace() abort
	%s/\s*$//
	''
endfunction

function! utils#GetPathFolderName(curr_dir) abort
	" Strip path to get only root folder name
	let back_slash_index = strridx(a:curr_dir, '/')
	if back_slash_index == -1
		let back_slash_index = strridx(a:curr_dir, '\')
	endif

	if back_slash_index == -1
		" echomsg string("utils#GetPathFolderName(): No back_slash_index found")
		return
	endif

	return a:curr_dir[back_slash_index+1:]
endfunction

function! utils#DownloadFile(path, link) abort
	" Need curl to download the file
	if !executable('curl')
		echomsg 'Master I cant download file for you because you'
					\' do not have curl.'
		return 0
	endif

	if empty(a:path) || empty(a:link)
		echomsg '[utils#DownloadFile]: Please specify a path and link to download'
		return -1
	endif

	execute '!curl -kfLo ' . a:path . ' --create-dirs ' . a:link
	return 1
endfunction
