" File:					utils.vim
" Description:	Function Container
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:			2.0.0
" Date:					Mon Mar 06 2017 09:22

" FUNCTIONS
" Support here for rg, ucg, ag in that order
function! utils#SetGrep() abort
	if executable('rg')
		" use option --list-file-types if in doubt
		" rg = ripgrep
		"Use the -t option to search all text files; -a to search all files; and -u to search all,
		"including hidden files.
		set grepprg=rg\ --vimgrep\ --smart-case\ --follow\ --hidden\ --glob\ !.git\ --glob\ !.svn\ $*
		set grepformat=%f:%l:%c:%m
	elseif executable('ucg')
		" Add the --type-set=markdown:ext:md option to ucg for it to recognize
		" md files
		set grepprg=ucg\ --nocolor\ --noenv
	elseif executable('ag')
		" ctrlp with ag
		" see :Man ag for help
		" to specify a type of file just do `--cpp`
		set grepprg=ag\ --nogroup\ --nocolor\ --smart-case\ --vimgrep\ --glob\ !.git\ --glob\ !.svn\ $*
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
	if !has('file_in_path') || !exists("*mkdir")
		echoerr "CheckFileOrDir(): This vim install has no support for +find_in_path or cant create directories"
	endif

	if !empty(finddir(a:name,",,"))
		return
	endif

	if has('win32') " on win prepare name by escaping '\'
		call mkdir(escape(expand(a:name), '\'), "p")
	else  " have to test check works fine on linux
		call mkdir(expand(a:name), "p")
	endif
endfunction

function! utils#YankFrom(sign) abort
	let in = utils#ParseLineModificationInput('Yank',  a:sign)
	execute "normal :" . in . "y\<CR>p"
endfunction

" msg - {Comment, Delete, Paste, Yank}
" sing - {+,-}
" Returns: Modified input
function! utils#ParseLineModificationInput(msg, sign) abort
	let in = input(a:msg . " Line:")
	let in = a:sign . in
	let comma = stridx(in, ',')
	if comma > -1
		return strcharpart(in, 0,comma+1) . a:sign . strcharpart(in, comma+1)
	endif

	return in
endfunction

function! utils#DeleteLine(sign) abort
	let in = utils#ParseLineModificationInput('Delete',  a:sign)
	execute "normal :" . in . "d\<CR>``"
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

function! utils#NormalizeWindowSize() abort
	execute "normal \<c-w>="
endfunction

function! utils#FixPreviousWord() abort
	normal mm[s1z=`m
	return ''
endfunction

function! utils#SaveSession(...) abort
	let session_path = g:std_data_path . '/sessions/'
	" if session name is not provided as function argument ask for it
	if a:0 < 1
		execute "wall"
		let dir = getcwd()
		execute "cd ". session_path
		let session_name = input("Enter save session name:", "", "file")
		silent! execute "cd " . dir
	else
		" Need to keep this option short and sweet
		let session_name = a:1
	endif
	silent! execute "mksession! " . session_path . session_name
endfunction

function! utils#LoadSession(...) abort
	let session_path = g:std_data_path . '/sessions/'
	" Logic path when not called at startup
	if a:0 >= 1
		let session_name = session_path . a:1
		if !filereadable(session_name)
			echoerr '[utils#LoadSession]: File ' . session_name . ' not readabale'
			return
		endif
		silent! execute "normal :%bdelete\<CR>"
		silent! execute "normal :so " . session_path . a:1 . "\<CR>"
		return
	endif

	execute "wall"
	let response = confirm("Save Current Session before deleting all buffers?", "&Jes\n&No(def.)")
	if response == 1
		call utils#SaveSession()
	endif

	if exists(':Denite')
		call setreg(v:register, "") " Clean up register
		execute "Denite -default-action=yank -path=" . session_path . " file_rec"
		let session_name = getreg()
		if !filereadable(session_path . session_name)
			return
		endif
	else
		let dir = getcwd()
		execute "cd ". session_path
		let session_name = input("Load session:", "", "file")
		silent! execute "cd " . dir
	endif
	silent! execute "normal :%bdelete\<CR>"
	silent execute "source " . session_path . session_name
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

function! utils#CommentLine(sign) abort
	if !exists("*NERDComment")
		echo "Please install NERDCommenter"
		return
	endif

	let in = utils#ParseLineModificationInput('Comment',  a:sign)
	execute "normal mm:" . in . "\<CR>"
	execute "normal :call NERDComment(\"n\", \"Toggle\")\<CR>`m"
endfunction

function! utils#LastCommand() abort
	execute "normal :\<Up>\<CR>"
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

" Default Wings mappings are for laptop
function! utils#SetWingsPath(sPath) abort
	execute "nnoremap <Leader>ew1 :call utils#DeniteRec(\"" . a:sPath . "OneWings/\")<CR>"
	execute "nnoremap <Leader>ew2 :call utils#DeniteRec(\"" . a:sPath . "OneWingsSupFiles/\")<CR>"
	execute "nnoremap <Leader>ewd :silent e ". a:sPath . "OneWings/default.ini<CR>"

	call utils#GuiFont('+')
endfunction

function! utils#CheckNeomakeStatus() abort
	return exists('g:neomake_lightline') ? g:neomake_lightline : ''
endfunction

function! utils#NeomakeJobStartd() abort
	if exists('g:neomake_hook_context.jobinfo.maker.name')
		let g:neomake_lightline = "\uf188" . printf(" %s ", g:neomake_hook_context.jobinfo.maker.name) . "\uf0e4"
	else
		unlet! g:neomake_lightline
	endif
endfunction

function! utils#NeomakeJobFinished() abort
	if exists('g:neomake_hook_context.jobinfo.exit_code')
		let g:neomake_lightline = "\uf188" . printf(" %s: %s", g:neomake_hook_context.jobinfo.maker.name,
					\ g:neomake_hook_context.jobinfo.exit_code)
		echomsg g:neomake_lightline
		" Thu Nov 09 2017 10:11: When using the native status line function this is not
		" needed. 
		" keyword: example use of lambda in vim
		" call timer_start(
						" \ 60 * 1000,
						" \ { timer -> execute("unlet! g:neomake_lightline") }
					" \ )
	else
		unlet! g:neomake_lightline
	endif
endfunction

function! utils#NeomakeNativeStatusLine() abort
	return neomake#statusline#get(bufnr("%"), {
				\ 'format_running': "\uf188" .' {{running_job_names}} ' . "\uf0e4",
				\ 'format_ok': "\uf188" .' ✓',
				\ 'format_quickfix_ok': '',
				\ 'format_quickfix_issues': "\uf188" .' %s ',
				\ 'format_quickfix_type_E': ' {{type}}:{{count}} ',
				\ 'format_quickfix_type_W': ' {{type}}:{{count}} ',
				\ 'format_quickfix_type_I': ' {{type}}:{{count}} ',
				\ 'format_loclist_ok': '',
				\ 'format_loclist_issues': "\uf188" .' %s ',
				\ 'format_loclist_type_E': ' {{type}}:{{count}} ',
				\ 'format_loclist_type_W': ' {{type}}:{{count}} ',
				\ 'format_loclist_type_I': ' {{type}}:{{count}} ',
				\ 'format_loclist_unknown': '',
				\ })
	" return ret == '?' ? '' : ret
endfunction

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
	if &grepprg =~# 'rg'
		" rg filetype for vim files is called vimscript
		if file_type_search =~# 'vim'
			let file_type_search = '-t vimscript'
		elseif file_type_search =~# 'python'
			let file_type_search = '-t py'
		else
			let file_type_search = '-t ' . file_type_search
		endif
	elseif &grepprg =~# 'ag'
			let file_type_search = '--' . file_type_search
	else
		" If it is not a recognized engine do not do file type search
		exe ":grep " . search
		echomsg '|Grep Engine:' &grepprg ' |FileType: All| CWD: ' getcwd()
		return
	endif

	if a:filetype == 1
		exe ":grep " . file_type_search . ' ' . search
		echon '|Grep Engine:' &grepprg ' |FileType: ' file_type_search '| CWD: ' getcwd()
	else
		exe ":grep " . search
		echon '|Grep Engine:' &grepprg ' |FileType: All| CWD: ' getcwd()
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
	if strftime("%H") >= g:colorscheme_night_time || strftime("%H") < g:colorscheme_day_time 
		" Its night time
		if !exists('g:colors_name')
			let g:colors_name = g:colorscheme_night
		endif
		if	&background !=# 'dark' || g:colors_name !=# g:colorscheme_night
			call utils#ChangeColors(g:colorscheme_night, 'dark')
		endif
	else
		" Its day time
		if !exists('g:colors_name')
			let g:colors_name = g:colorscheme_day
		endif
		if &background !=# 'light' || g:colors_name !=# g:colorscheme_day
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
	call utils#LightlineUpdateColorscheme()
endfunction

function! utils#LightlineUpdateColorscheme()
	" Update the name first. This is important. Otherwise no colorscheme is set during startup
	if exists('g:lightline')
		if &background ==# 'dark'
			let g:lightline.colorscheme = g:colorscheme_night . '_dark'
		else
			let g:lightline.colorscheme = g:colorscheme_day . '_light'
		endif
	endif

	if !exists('g:loaded_lightline')
		return
	endif
	try
		" if g:colors_name =~# 'wombat\|solarized\|landscape\|jellybeans\|seoul256\|Tomorrow\|gruvbox\|PaperColor\|zenburn'
			" let g:lightline.colorscheme =
						" \ substitute(substitute(g:colors_name, '-', '_', 'g'), '256.*', '', '')
			call lightline#init()
			call lightline#colorscheme()
			call lightline#update()
		endif
	catch
	endtry
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

function! utils#BufDetermine() abort
	let ext = expand('%:e')	
	if ext ==# 'ino' || ext ==# 'pde'
		setfiletype arduino
	elseif ext ==# 'scp'
		setfiletype wings_syntax
	elseif ext ==# 'log'
		setfiletype unreal-log
	elseif ext ==# 'set' || ext ==# 'sum'
		setfiletype dosini
	elseif ext ==# 'bin' || ext ==# 'pdf' || ext ==# 'hsr'
		call utils#SetBinFileType()
	endif

	" Remember last cursor position
	if line("'\"") > 0 && line("'\"") <= line("$") |
		exe "normal g`\"" |
	endif
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

function! utils#SetBinFileType() abort
	let &l:bin=1
	%!xxd
	setlocal ft=xxd
	%!xxd -r
	setlocal nomodified
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

function! utils#LightlineReadonly()
	return &readonly ? '' : ''
endfunction

function! utils#LightlineVerControl() abort
	" let mark = ''  " edit here for cool mark
	let mark = "\uf406"  " edit here for cool mark
	if expand('%:t') =~? 'Tagbar\|Gundo\|NERD\|ControlP' || &ft =~? 'vimfiler\|gitcommit'
		return ''
	endif

	try
		if exists('*fugitive#head')
			let git = fugitive#head()
			if git !=# ''
				return mark . ' ' . git
			endif
		endif
		" TODO-[RM]-(Mon Oct 30 2017 16:37): This here really doesnt work
		" if executable('svn') && exists('*utils#UpdateSvnBranchInfo')
			" let svn = utils#UpdateSvnBranchInfo()
			" if !empty(svn)
				" return '' . ' ' . svn
			" endif
		" endif
	catch
		return ''
	endtry
	return ''
endfunction

function! utils#LightlineCtrlPMark()
	if expand('%:t') =~ 'ControlP' && has_key(g:lightline, 'ctrlp_item')
		call lightline#link('iR'[g:lightline.ctrlp_regex])
		return lightline#concatenate([g:lightline.ctrlp_prev, g:lightline.ctrlp_item
					\ , g:lightline.ctrlp_next], 0)
	else
		return ''
	endif
endfunction

function! utils#CtrlPStatusFunc_1(focus, byfname, regex, prev, item, next, marked)
	let g:lightline.ctrlp_regex = a:regex
	let g:lightline.ctrlp_prev = a:prev
	let g:lightline.ctrlp_item = a:item
	let g:lightline.ctrlp_next = a:next
	return lightline#statusline(0)
endfunction

function! utils#CtrlPStatusFunc_2(str)
	return lightline#statusline(0)
endfunction

function! utils#LightlineTagbar() abort
	try
		let ret =  tagbar#currenttag('%s','')
	catch
		return ''
	endtry
	return empty(ret) ? '' : "\uf02b" . ' ' . ret
endfunction

function! utils#LightlinePomo() abort
	if !exists('*pomo#status_bar')
		return ''
	endif

	return pomo#status_bar()
endfunction

function! utils#TagbarStatusFunc(current, sort, fname, ...) abort
	let g:lightline.fname = a:fname
	return lightline#statusline(0)
endfunction

" TODO.RM-Thu Mar 16 2017 08:36: Update this function to make it async. Maybe the whole plugin be async  
" This function gets called on BufEnter
" Call the function from cli with any argument to obtain debugging output
function! utils#UpdateSvnBranchInfo() abort
	if !executable('svn')
		return ''
	endif

	let srch_eng = has('win32') ? 'findstr' : 'grep'
	let path = expand('%:h')
	try
		let info = systemlist('svn info ' . path . ' | grep "Relative URL"')
	catch
		return ''
	endtry
	" The system function returns something like "Relative URL: ^/...."
	" Strip from "^/" forward and put that in status line
	"TODO.RM-Tue Mar 28 2017 15:05: Find a much better way to do this  
	let info = get(info, 0, "")
	let index = stridx(info, "^/")
	" echomsg string(info)
	if index == -1
		return ''
	else
		let pot_display = info[index+2:-1] " Again skip last char. Looks ugly
	endif
	" Debugging
	" echomsg string(pot_display)

	if strlen(pot_display) > 16
		return pot_display[0:16] . '...'
	else
		return pot_display
	endif
endfunction

function! utils#LightlineAbsPath(count) abort
	return expand('%')
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

function! utils#LightlineDeviconsFileType()
	if !exists('*WebDevIconsGetFileTypeSymbol')
		return &filetype
	endif

	return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype . ' ' . WebDevIconsGetFileTypeSymbol() : 'no ft') : ''
endfunction

function! utils#LightlineDeviconsFileFormat()
	if !exists('*WebDevIconsGetFileTypeSymbol')
		return &fileformat
	endif

	return winwidth(0) > 70 ? (&fileformat . ' ' . WebDevIconsGetFileFormatSymbol()) : ''
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

	let grep_buf = &grepprg

	setlocal grepprg=pdfgrep\ --page-number\ --recursive\ --context\ 1
	return utils#FileTypeSearch(8, 8)

	let &l:grepprg = grep_buf
endfunction
