" File:					c.vim
" Description:	After default ftplugin for c
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:			1.0.0
" Last Modified: Fri Apr 28 2017 14:33
" Created:			Nov 25 2016 23:16

" Only do this when not done yet for this buffer
if exists("b:did_cpp_ftplugin")
	finish
endif

" Don't load another plugin for this buffer
let b:did_cpp_ftplugin = 1

let b:match_words = '\<if\>:\<else\>,'
			\ . '\<while\>:\<continue\>:\<break\>,'
			\ . '\<for\>:\<continue\>:\<break\>,'
			\ . '\<try\>:\<catch\>'
setlocal omnifunc=ClangComplete
setlocal ts=4 sw=4 sts=4
setlocal foldenable
setlocal define=^\\(#\\s*define\\|[a-z]*\\s*const\\s*[a-z]*\\)

" Add mappings, unless the user didn't want this.
if !exists("no_plugin_maps") && !exists("no_c_maps")
	" Quote text by inserting "> "
	if !hasmapto('<Plug>CppMake')
		nmap <buffer> <Leader>jk <Plug>CppMake
	endif
	if exists(':Neomake')
		nnoremap <buffer> <unique> <Plug>CppMake :Neomake!<CR>
	else
		nnoremap <buffer> <unique> <Plug>CppMake :make<CR>
	endif
	" Compiler
	nnoremap <buffer> <unique> <Leader>lb :compiler borland<CR>
	" msbuild errorformat looks horrible resetting here
	nnoremap <buffer> <unique> <Leader>lv :compiler msbuild<CR>
				\:set errorformat&<CR>
	nnoremap <buffer> <unique> <Leader>lg :compiler gcc<CR>
				\:setlocal makeprg=mingw32-make<CR>

	nnoremap <buffer> <Leader>lh :call utils#AutoHighlightToggle()<CR>
	" Time runtime of a specific program
	nnoremap <buffer> <unique> <Leader>lt :Dispatch powershell -command "& {&'Measure-Command' {.\sep_calc.exe seprc}}"<CR>
	nnoremap <buffer> <unique> <Leader>lu :call <SID>UpdateBorlandMakefile()<CR>

	" Alternate between header and source file
	nnoremap <buffer> <unique> <Leader>lq :call <SID>SwitchHeaderSource()<CR>

	" Cscope and tag jumping mappings
	nnoremap <buffer> <unique> <Leader>tk :cs kill -1<CR>
	nnoremap <buffer> <unique> <Leader>tv :vs<CR>:exec("tag ".expand("<cword>"))<CR>
	" ReLoad cscope database
	nnoremap <buffer> <unique> <Leader>tl :cs add cscope.out<CR>
	" Find functions calling this function
	nnoremap <buffer> <unique> <Leader>tc :cs find c <C-R>=expand("<cword>")<CR><CR>
	" Find functions definition
	nnoremap <buffer> <unique> <Leader>tg :cs find g <c-r>=expand("<cword>")<cr><cr>
	" Find functions called by this function not being used
	" nnoremap <Leader>td :cs find d <C-R>=expand("<cword>")<CR><CR>
	nnoremap <buffer> <unique> <Leader>ts :cs show<CR>

	if exists(':SyntasticCheck')
		nnoremap <buffer> <unique> <Leader>lo :SyntasticToggleMode<CR>
		nnoremap <buffer> <unique> <Leader>ls :SyntasticCheck<CR>
	endif
	if exists(':Autoformat')
		nnoremap <buffer> <unique> <Leader>lf :Autoformat<CR>
	endif

	nnoremap <buffer> <unique> <Leader>od :call <SID>CommentDelete()<CR>
	" Comment Indent Increase/Reduce
	nnoremap <buffer> <unique> <Leader>oi :call <SID>CommentIndent()<CR>
	nnoremap <buffer> <unique> <Leader>oI :call <SID>CommentReduceIndent()<CR>
	nnoremap <buffer> <Leader>lh :call utils#AutoHighlightToggle()<CR>

	if exists(':LLmode')
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

	" if exists('*quickfix#ToggleList')
		nnoremap <silent> <buffer> <Leader>ll :call quickfix#ToggleList("Location List", 'l')<CR>
		nnoremap <silent> <buffer> <Leader>;; :call quickfix#ToggleList("Quickfix List", 'c')<CR>
		nnoremap <buffer> <Leader>ln :call quickfix#ListsNavigation("next")<CR>
		nnoremap <buffer> <Leader>lp :call quickfix#ListsNavigation("previous")<CR>

		nnoremap <buffer> <unique> <Leader>tu :call ctags#NvimSyncCtags(0)<CR>
	" endif
endif

if exists('*utils#AutoHighlightToggle') && !exists('g:highlight')
	silent call utils#AutoHighlightToggle()
endif

" Auto set the compiler
if has('win32')
	if !exists('b:current_compiler')
		" Notice inside the '' is a pat which is a regex. That is why \\
		if expand('%:p') =~ 'onewings\\source'
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
	let b:syntastic_checkers = [ 'cppcheck', 'clang_tidy', 'clang_check', 'gcc' ]
endif
let b:syntastic_mode = 'passive'

function! s:UpdateBorlandMakefile() abort
	" If compiler is not borland(set by SetupCompiler) fail.
	if !exists('b:current_compiler')
		echomsg "Error, not in WINGS folder"
	else
		execute "!bpr2mak -omakefile WINGS.bpr"
	endif
endfunction

" Source: http://vim.wikia.com/wiki/Easily_switch_between_source_and_header_file
function! s:SwitchHeaderSource() abort
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

function! s:CommentDelete() abort
	execute "normal Bf/D"
endfunction

function! s:CommentIndent() abort
	execute "normal Bf/i\<Tab>\<Tab>\<Esc>"
endfunction

function! s:CommentReduceIndent() abort
	execute "normal Bf/hxhx"
endfunction

let b:undo_ftplugin += "setlocal omnifunc< ts< sw< sts< foldenable< define<" 
