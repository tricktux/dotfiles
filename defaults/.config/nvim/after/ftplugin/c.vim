" File:					c.vim
" Description:	After default ftplugin for c
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:			2.0.0
" Last Modified: Fri Aug 23 2019 08:46
" Created:			Nov 25 2016 23:16

" Only do this when not done yet for this buffer
if exists('b:did_cpp_ftplugin')
	finish
endif

" Don't load another plugin for this buffer
let b:did_cpp_ftplugin = 1

" This doesnt work. Set omnifunc from augroups
" if exists('g:omnifunc_clang')
	" let &omnifunc=g:omnifunc_clang
" endif

" This is that delimate doesnt aut fill the newly added matchpairs
let b:delimitMate_matchpairs = '(:),[:],{:}'
let &l:define='^\(#\s*define\|[a-z]*\s*const\s*[a-z]*\)'

" Add mappings, unless the user didn't want this.
if !exists('no_plugin_maps') && !exists('no_c_maps')
	nnoremap <buffer> <plug>terminal_send_file :call <sid>repl()<cr>

	nnoremap <buffer> <localleader>h :Man <c-r>=expand("<cword>")<CR><cr>

	" Alternate between header and source file
	if exists(':A')
		nnoremap <buffer> <localleader>a :A<cr>
		" Open in alternate in a vertical window
		nnoremap <buffer> <localleader>A :AV<cr>
	else
		nnoremap <buffer> <localleader>a :call
					\ utils#SwitchHeaderSource()<cr>
	endif

	if (exists(':Neomake'))
		nnoremap <buffer> <plug>make_file :Neomake<cr>
		nnoremap <buffer> <plug>make_project :Neomake!<cr>
	endif

	if has('unix') && has('nvim')
		nnoremap <buffer> <plug>help_under_cursor :call <SID>man_under_cursor()<cr>
	endif

	if exists(':GTestRun')
		" Attempt to guess executable test
		let g:gtest#gtest_command = (has('unix') ? '.' : '') .
					\ expand('%:p:r') . (has('unix') ? '' : '.exe')
		nnoremap <buffer> <localleader>tr :GTestRun<cr>
		nnoremap <buffer> <localleader>tt :GTestToggleEnable<cr>
		nnoremap <buffer> <localleader>tu :GTestRunUnderCursor<cr>
	endif

	call mappings#SetCscope()
endif

function! s:time_exe_win(...) abort
	if !exists(':Dispatch')
		echoerr 'Please install vim-dispatch'
		return
	endif

	let l:cmd = "Dispatch powershell -command \"& {&'Measure-Command' {.\\"

	for s in a:000
	  let l:cmd .= s . ' '
	endfor

	let l:cmd .= "}}\""

	exe l:cmd
endfunction

function! s:set_compiler_and_friends() abort
	if exists('b:current_compiler')
		return
	endif

	if has('unix')
		call linting#SetNeomakeClangMaker()
		if executable('ninja')
			call linting#SetNeomakeNinjaMaker()
		else
			call linting#SetNeomakeMakeMaker()
		endif
		call autocompletion#AdditionalLspSettings()
		return 1
	endif

	" Commands for windows
  if executable('mingw32-make')
    command! -buffer UtilsCompilerGcc
          \ execute("compiler gcc<bar>:setlocal makeprg=mingw32-make")
    nnoremap <buffer> <localleader>mg :UtilsCompilerGcc<cr>
  endif
	command! -buffer UtilsCompilerBorland call linting#SetNeomakeBorlandMaker()
	command! -buffer UtilsCompilerClangNeomake call linting#SetNeomakeClangMaker()
	nnoremap <buffer> <localleader>mb :UtilsCompilerBorland<cr>
  command! -buffer UtilsCompilerMsbuild2017 lua
        \ require('config.linting').set_neomake_msbuild_compiler('cpp', 'vs2017')
  nnoremap <buffer> <localleader>m5 :UtilsCompilerMsbuild2017<cr>
  command! -buffer UtilsCompilerMsbuild2015 lua
        \ require('config.linting').set_neomake_msbuild_compiler('cpp', 'vs2015')
  nnoremap <buffer> <localleader>m7 :UtilsCompilerMsbuild2017<cr>
	nnoremap <buffer> <localleader>mc :UtilsCompilerClangNeomake<cr>

	" Time runtime of a specific program. Pass as Argument executable with 
	" arguments. Pass as Argument executable with arguments. Example sep_calc.exe 
	" seprc.
	command! -nargs=+ -buffer UtilsTimeExec call s:time_exe_win(<f-args>)
endfunction

function! s:man_under_cursor() abort
	if !exists(':Man')
		echoerr 'Man plugin not present'
		return -1
	endif

	execute ':vertical Man ' . expand('<cword>')
endfunction

" Setup Compiler and some specific stuff
call <SID>set_compiler_and_friends()

function! s:cctree_load_db() abort
	if !exists('g:ctags_output_dir') || empty('g:ctags_output_dir')
		echoerr '[cctree_load_db]: Failed to get g:ctags_output_dir path'
		return
	endif

	let l:db = g:ctags_output_dir . utils#GetFullPathAsName(getcwd())
	if !empty(glob(l:db . '.xref'))
		execute ':CCTreeLoadXRefDB ' . l:db . '.xref'
		return
	endif

	if !empty(glob(l:db . '.out'))
		execute ':CCTreeLoadDB ' . l:db . '.out'
		return
	else
		echoerr 'No cscope database for current path'
		return
	endif

	if !exists(':Denite')
		let l:db = input('Please enter full path to cscope.out like file: ')
	else
		let l:db = utils#DeniteYank(g:ctags_output_dir)
		if empty(l:db)
			echoerr '[cctree_load_db]: Failed to get Denite path'
			return
		endif
	endif
	
	execute ':CCTreeLoadDB ' . l:db
endfunction

function! s:cctree_save_xrefdb() abort
	if !exists('g:ctags_output_dir') || empty('g:ctags_output_dir')
		echoerr '[cctree_save_xrefdb]: Failed to get g:ctags_output_dir path'
		return
	endif

	let l:db = g:ctags_output_dir . utils#GetFullPathAsName(getcwd()) . '.xref'
	execute ':CCTreeSaveXRefDB ' . l:db
endfunction

function! s:repl() abort
	if !exists(':T')
		echoerr 'Neoterm plugin not installed'
		return
	endif

  let l:compiler = ''
	if executable('clang++')
    let l:compiler = 'clang++'
	endif

  if executable('g++')
    let l:compiler = 'g++'
  endif

  if l:compiler == ''
    echoerr 'No cpp compiler found'
    return
  endif

	execute ':T ' . l:compiler . ' ' . expand('%') . ' && ' .
				\ (has('unix') ? './a.out' : 'a.exe') . "\<cr>"
endfunction

" Setup AutoHighlight
" call utils#AutoHighlight()
