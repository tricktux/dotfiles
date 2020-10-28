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

" Special comment function {{{
function! utils#FindIf() abort
	while 1
		" jump to matching {
		normal! %
		" check to see if there is another else
		if match(getline(line(".")-1, line(".")), "else") > -1
			" search curr and previous 2 lines for }
			if match(getline(line(".")-2, line(".")), "}") > -1
				" jump to it
				execute "normal! ?}\<CR>"
				" if there is no } could be no braces else if
			else
				" go up to lines and see what happens
				normal! kk
			endif
		else
			" if original if was found copy it to @7 and jump back to origin
			execute "normal! k^\"7y$`m"
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
		"execute "normal! mm" . l:ref_col . "|%k^\"8y$j%"
		execute "normal! mm" . l:ref_col . "|%"
		let l:upper_line = line(".")
		execute "normal! k^\"8y$j%"
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
				execute "normal! a" . l:end . @7 . "\" : \"\<Esc>"
			else
				let l:end = "  // \""
				execute "normal! a" . l:end . "\<Esc>"
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
			execute "normal! a" . l:end . @7 . "\" : \"\<Esc>"
			" if not very easy
		else
			" Append // End of "..."
			let l:end = "  // End of \""
			execute "normal! a" . l:end . "\<Esc>"
		endif
		" truncate comment line in case too long
		let @8 = utils#TruncComment(@8)
		execute "normal! a" . @8 . "\""
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
	if a:name ==# 0  " use 0 for file, 1 for dir
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
		if l:decision ==# "y"
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
	if !has('file_in_path') && &verbose > 0
		echomsg "utils#CheckDirWoPrompt(): This vim install has no support for +find_in_path"
		return -1
	endif

	if !empty(finddir(a:name,",,"))
		return 1
	endif

	if !exists("*mkdir") && &verbose > 0
		echomsg "CheckDirwoPrompt(): This vim install has no support creating directories"
		return -2
	endif

	if has('unix')    " have to test check works fine on linux
		call mkdir(expand(a:name), 'p')
	else              " on win prepare name by escaping '\'
		call mkdir(escape(expand(a:name), '\'), 'p')
	endif

	return 1
endfunction

function! utils#TodoAdd() abort
	execute "normal! O" . &commentstring[0] . " "
	execute "normal! ==a TODO (" . strftime("%a %b %d %Y %H:%M") . "): "
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
function! CheatCompletion(ArgLead, CmdLine, CursorPos) abort
	echom "arglead:[".a:ArgLead ."] cmdline:[" .a:CmdLine ."] cursorpos:[" .a:CursorPos ."]"
	if a:ArgLead =~# '^-\w*'
		echohl WarningMsg | echom a:ArgLead . " is not a valid wiki name" | echohl None
	endif
	return join(utils#ListFiles(g:wiki_path . '//'),"\n")
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
	if sys =~# 'Android'
		execute "normal :vs\<CR>\<c-w>l:e term:\/\/bash\<CR>"
	else
		execute "normal :vs\<CR>\<c-w>l:terminal\<CR>"
	endif
endfunction

function! utils#Make() abort
	let filet = &filetype
	if filet =~# 'vim'
		so %
		return
	elseif filet =~# 'python' && executable('flake8')
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

	let l:dir = getcwd()
	if exists(':Grip')
		execute 'Grip wiki'
	elseif exists(':Denite')
		execute 'Denite grep -path=`g:wiki_path`'
	else
		execute 'lcd ' . g:wiki_path
		execute 'grep ' . input('Enter wiki search string:')
		silent! execute 'lcd ' . l:dir
	endif
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
		if c ==# "y" || c ==# "j"
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

function! utils#UpdateHeader() abort
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

	let in_name = 'D:\wiki_work\hpd\WeeklyReport.md'

	if !filereadable(in_name)
		echoerr 'Source file ' . in_name . ' not found'
		return
	endif

	" Execute command
	cexpr systemlist('pandoc ' . in_name . ' -s -o ' . out_name . ' --from markdown')
endfunction

function! utils#AutoHighlightToggle() abort
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
function! utils#SearchHighlighted() abort
	if exists(':Wcopen')
		" Yank selection to reg a then echo it cli
		normal! "ay:Wcsearch duckduckgo <c-r>a<cr>
	else
		echoerr string('Missing plugin: vim-www')
	endif
endfunction

" TODO.RM-Sat Nov 26 2016 00:04: Function that auto adds SCR # and description
"
" Source: http://vim.wikia.com/wiki/Easily_switch_between_source_and_header_file
function! utils#SwitchHeaderSource() abort
	if expand("%:e") ==# "cpp" || expand("%:e") ==# "c"
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

function! utils#MastersDropboxOpen(wiki) abort
	let db_path = get(g:, 'dropbox_path', "~/Dropbox/masters")
	let db_path .= a:wiki

	if empty(a:wiki) " Use Denite
		call utils#PathFileFuzzer(db_path)
	elseif !filereadable(db_path)
		echoerr "File " . db_path . " does not exists"
		return
	endif
	execute "edit " . db_path
endfunction

function! utils#FzfCopyFileNameApi() abort
	if (!exists('*fzf#run'))
		echoerr '[utils#FzfCopyFileNameApi]: Fzf not intalled'
		return -1
	endif


endfunction

function! utils#PathFileFuzzer(path) abort
	if empty(a:path)
		return
	endif

	if exists(':FZF')
		execute 'Files ' . fnameescape(expand(a:path))
		return
	endif

	if !exists(':Denite')
		let l:dir = getcwd()
		execute 'lcd ' . a:path
		execute 'e ' . input('e ' . expand(a:path) . '/', '', 'file')
		silent! execute 'lcd ' . l:dir
		return
	endif

	if empty(glob(a:path))
		echoerr 'Folder "' . a:path . '" not found'
		return
	endif

	" Make a copy so that I can modify it
	let l:cp_path = s:fix_denite_path(a:path)

	if &verbose > 0
		echomsg printf('[utils#PathFileFuzzer()]: l:cp_path = %s', l:cp_path)
	endif

	execute 'Denite -path=' . l:cp_path . ' file_rec'
endfunction

function! utils#CurlDown(file_name, link) abort
	if !executable('curl')
		if &verbose > 0
			echoerr 'Curl is not installed. Cannot proceed'
		endif
		return -1
	endif

	if empty(a:file_name) || empty(a:link)
		if &verbose > 0
			echoerr 'Please specify a path and link to download'
		endif
		return -2
	endif

	silent execute "!curl -kfLo " . a:file_name . " --create-dirs \"" . a:link . "\""
	return 1
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

	let l:svn_dir = getcwd() . '/.svn'
	if empty(finddir(l:svn_dir))
		return ''
	endif

	let cmd = 'svn info  | ' .
				\ (executable('grep') ? 'grep': 'findstr') . ' "Relative URL"'

	let info = systemlist(cmd)
	if v:shell_error
		" echomsg 'v:shell_error = 1'
		return ''
	endif

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

	if index == -1
		" echomsg 'index == -1'
		return ''
	endif

	" Again skip last char. Looks ugly
	let pot_display = fnamemodify(url[index+2:-1], '%:t')
	" echomsg 'pot_display = ' . pot_display

	return pot_display[-15:-2]
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
function! utils#TrimWhiteSpace() abort
	execute 'normal! :%s/\s*$//'
	normal! ''
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

function! utils#AutoHighlight() abort
	if exists("*utils#AutoHighlightToggle") && !exists('g:highlight')
		silent call utils#AutoHighlightToggle()
		command! UtilsAutoHighlightToggle call utils#AutoHighlightToggle()
	endif
endfunction

function! utils#Syntastic(mode, checkers) abort
	if exists(":SyntasticCheck")
		" nnoremap <buffer> <unique> <Leader>lo :SyntasticToggleMode<CR>
		nnoremap <buffer> <LocalLeader>c :SyntasticCheck<CR>
	endif

	if !empty(a:checkers)
		let b:syntastic_checkers=a:checkers
	endif
	let b:syntastic_mode =a:mode
endfunction

function! utils#QpdfviewPreview(ext, maker) abort
	let s:ext = a:ext
	let s:maker = a:maker
	execute 'nnoremap <buffer> <Plug>Preview :silent !qpdfview --unique --quiet %:r' . a:ext
	let s:i3_mark = 'nvim'
	" Set an i3 mark on this current window so that we can regain focus later
	execute ':silent !i3-msg mark ' . s:i3_mark

	" augroup update_pdf
	" autocmd!
	" autocmd User NeomakeJobFinished call s:preview_qpdfview()
	" augroup end
endfunction

function! s:preview_qpdfview() abort
	if !exists('s:ext') || !exists('s:i3_mark') || !exists('s:maker')
		return -1
	endif

	let context = g:neomake_hook_context
	if context.jobinfo.exit_code != 0
		return -2
	endif

	if context.jobinfo.maker.name != s:maker
		return -3
	endif

	let file = expand('%:r') . s:ext
	if !filereadable(file)
		" echomsg 'File doesn exist: ' . file
		return -4
	endif

	" Such awesome unix hacking!
	" Update the just updated file view in qpdfview
	execute ':silent !qpdfview --unique --quiet ' . file
	" However this will focus the qpdfview window. Annoying.
	" Therefore restore focust to the marked nvim instance
	execute ":silent !i3-msg '[con_mark=\"" . s:i3_mark . "\"]' focus"
endfunction

function! utils#GetFullPathAsName(folder) abort
	" Create unique tag file name based on cwd
	let l:ret = substitute(a:folder, "\\", '_', 'g')
	let l:ret = substitute(l:ret, ':', '_', 'g')
	let l:ret = substitute(l:ret, ' ', '_', 'g')
	return substitute(l:ret, "/", '_', 'g')
endfunction

function! utils#DeniteYank(path) abort
	if !exists(':Denite')
		echoerr '[utils#DeniteYank]: Please install denite plugin'
		return ''
	endif

	if empty(glob(a:path))
		echoerr '[utils#DeniteYank]: Please provide a valid path'
		return ''
	endif
	
	let l:path = s:fix_denite_path(a:path)
	call setreg(v:register, '') " Clean up register
	execute 'Denite -default-action=yank -path=' . l:path . ' file_rec'
	return getreg()
endfunction

function! s:fix_denite_path(path) abort
	let l:cp_path = a:path
	
	" Strip ending slaches. They dont work well with denite
	let l:idx = strlen(l:cp_path)-1
	if l:cp_path[l:idx] ==? '\' || l:cp_path[l:idx] ==? '/'
		let l:cp_path = l:cp_path[0:l:idx-1]
	endif

	return (has('unix') ? l:cp_path : substitute(l:cp_path, "[\\/]", '\\\\', 'g'))
endfunction

" Executes cmds on files
function! utils#ExecCmdOnFile(files, cmds) abort
	if empty(a:files) || empty(a:cmds)
		echoerr '[utils#ExecCmdOnFile]: Invalid input argumetns'
		return
	endif

	for l:file in a:files
		execute 'argadd ' . l:file
	endfor

	for l:cmd in a:cmds
		execute 'argdo! ' . l:cmd
	endfor

  " Clean up the list
	" for l:file in a:files
		" execute 'argdelete ' . l:file
	" endfor
endfunction
