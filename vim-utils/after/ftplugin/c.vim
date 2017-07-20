" File:					c.vim
" Description:	After default ftplugin for c
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:			1.0.0
" Last Modified: Sat Jun 03 2017 19:02
" Created:			Nov 25 2016 23:16

" Only do this when not done yet for this buffer
if exists("b:did_cpp_ftplugin")
	finish
endif

" Don't load another plugin for this buffer
let b:did_cpp_ftplugin = 1

let b:match_words .= '\<if\>:\<else\>,'
			\ . '\<while\>:\<continue\>:\<break\>,'
			\ . '\<for\>:\<continue\>:\<break\>,'
			\ . '\<try\>:\<catch\>'
setlocal omnifunc=ClangComplete
setlocal ts=4
setlocal sw=4
setlocal sts=4
setlocal foldenable
setlocal foldnestmax=88
setlocal define=^\\(#\\s*define\\|[a-z]*\\s*const\\s*[a-z]*\\)
setlocal nospell
" So that you can jump from = to ; and viceversa
setlocal matchpairs+==:;
" This is that delimate doesnt aut fill the newly added matchpairs
let b:delimitMate_matchpairs = "(:),[:],{:}"

" Add mappings, unless the user didn't want this.
if !exists("no_plugin_maps") && !exists("no_c_maps")
	" Quote text by inserting "> "
	if exists(':Neomake')
		nnoremap <buffer> <Plug>Make :Neomake!<CR>
	else
		nnoremap <buffer> <Plug>Make :make!<CR>
	endif
	" Alternate between header and source file
	nnoremap <buffer> <unique> <Leader>lq :call utils#SwitchHeaderSource()<CR>

	nnoremap <buffer> <unique> <Leader>od :call <SID>CommentDelete()<CR>
	" Comment Indent Increase/Reduce
	nnoremap <buffer> <unique> <Leader>oi :call <SID>CommentIndent()<CR>
	nnoremap <buffer> <unique> <Leader>oI :call <SID>CommentReduceIndent()<CR>
	if executable('lldb') && exists(':LLmode')
		nmap <buffer> <unique> <Leader>db <Plug>LLBreakSwitch
		" vmap <F2> <Plug>LLStdInSelected
		" nnoremap <F4> :LLstdin<CR>
		" nnoremap <F5> :LLmode debug<CR>
		" nnoremap <S-F5> :LLmode code<CR>
		nnoremap <buffer> <unique> <Leader>dc :LL continue<CR>
		nnoremap <buffer> <unique> <Leader>do :LL thread step-over<CR>
		nnoremap <buffer> <unique> <Leader>di :LL thread step-in<CR>
		nnoremap <buffer> <unique> <Leader>dt :LL thread step-out<CR>
		nnoremap <buffer> <unique> <Leader>dD :LLmode code<CR>
		nnoremap <buffer> <unique> <Leader>dd :LLmode debug<CR>
		nnoremap <buffer> <unique> <Leader>dp :LL print <C-R>=expand('<cword>')<CR>
		" nnoremap <S-F8> :LL process interrupt<CR>
		" nnoremap <F9> :LL print <C-R>=expand('<cword>')<CR>
		" vnoremap <F9> :<C-U>LL print <C-R>=lldb#util#get_selection()<CR><CR>
	endif
	nnoremap <buffer> <Leader>lf :Autoformat<CR>
	nnoremap <buffer> <Leader>lt :TagbarToggle<CR>
	nnoremap <buffer> <Leader>la :call utils#TodoAdd()<CR>

	call ftplugin#TagMappings()
	call ftplugin#Align('/\/\/')
	call ftplugin#Syntastic('passive', [])
endif

" Setup AutoHighlight
call ftplugin#AutoHighlight()

" Window specific settings
if has('win32')
	" Fri May 19 2017 11:38 Having a lot of hang ups with the function! s:Highlight_Matching_Pair()
	" on the file C:\Program Files\nvim\Neovim\share\nvim\runtime\plugin\matchparen.vim
	" This value is suppose to help with it. The default value is 300ms
	" DoMatchParen, and NoMatchParen are commands that enable and disable the command
	let b:matchparen_timeout = 100
	" Commands for windows
	command! -buffer UtilsCompilerGcc execute("compiler gcc<CR>:setlocal makeprg=mingw32-make<CR>")
	command! -buffer UtilsCompilerBorland execute("compiler borland<CR>")
	command! -buffer UtilsCompilerMsbuild execute("compiler msbuild<CR>:set errorformat&<CR>")
	if exists(':Dispatch')
		" Time runtime of a specific program. Pass as Argument executable with arguments. Pass as Argument executable with
		" arguments. Example sep_calc.exe seprc.
		command! -nargs=+ -buffer UtilsTimeExec execute('Dispatch powershell -command "& {&'Measure-Command' {.\<f-args>}}"<CR>')
	endif

	" Set compiler now depending on folder and system. Auto set the compiler
	if !exists('b:current_compiler')
		" Notice inside the '' is a pat which is a regex. That is why \\
		if expand('%:p') =~ 'onewings\\source'
			command! -buffer UtilsUpdateBorlandMakefile call <SID>UpdateBorlandMakefile()
			compiler borland
		elseif expand('%:p') =~ 'Onewings' || expand('%:p') =~ 'unrealprojects'
			compiler msbuild
			silent set errorformat&
		else " if outside wings folder set gcc compiler
			compiler gcc
			setlocal makeprg=mingw32-make
		endif
	endif
	let b:syntastic_checkers = [ 'cppcheck', 'clang_tidy', 'clang_check' ]
else " Unix
	setlocal foldmethod=syntax 
	let b:syntastic_checkers = [ 'cppcheck', 'clang_tidy', 'clang_check', 'gcc' ]
endif

function! s:UpdateBorlandMakefile() abort
	" If compiler is not borland(set by SetupCompiler) fail.
	if !exists('b:current_compiler')
		echomsg "Error, not in WINGS folder"
	else
		execute "!bpr2mak -omakefile WINGS.bpr"
	endif
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

let b:undo_ftplugin = "setl omnifunc< ts< sw< sts< foldenable< define< spell< matchpairs< foldmethod< foldnestmax<| unlet! b:delimitMate_matchpairs b:matchparen_timeout b:match_words" 
