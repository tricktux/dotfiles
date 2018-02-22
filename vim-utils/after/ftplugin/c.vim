" File:					c.vim
" Description:	After default ftplugin for c
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:			1.0.0
" Last Modified: Sat Jun 03 2017 19:02
" Created:			Nov 25 2016 23:16

" Only do this when not done yet for this buffer
if exists('b:did_cpp_ftplugin')
	finish
endif

" Don't load another plugin for this buffer
let b:did_cpp_ftplugin = 1

let b:match_words .= '\<if\>:\<else\>,'
			\ . '\<while\>:\<continue\>:\<break\>,'
			\ . '\<for\>:\<continue\>:\<break\>,'
			\ . '\<try\>:\<catch\>'
if exists('g:omnifunc_clang')
	let &l:omnifunc=g:omnifunc_clang
endif
setlocal tabstop=4
setlocal shiftwidth=4
setlocal softtabstop=4
setlocal foldenable
setlocal foldnestmax=88
setlocal define=^\\(#\\s*define\\|[a-z]*\\s*const\\s*[a-z]*\\)
setlocal nospell
" So that you can jump from = to ; and viceversa
setlocal matchpairs+==:;
" This is that delimate doesnt aut fill the newly added matchpairs
let b:delimitMate_matchpairs = '(:),[:],{:}'

" Add mappings, unless the user didn't want this.
if !exists('no_plugin_maps') && !exists('no_c_maps')
	" Quote text by inserting "> "
	if exists(':Neomake')
		nnoremap <silent> <buffer> <LocalLeader>c :Neomake clangtidy clangcheck cppcheck<cr>
	else
		nnoremap <buffer> <Plug>Make :make!<cr>
	endif
	" Alternate between header and source file
	nnoremap <buffer> <unique> <LocalLeader>a :call utils#SwitchHeaderSource()<cr>

	if executable('lldb') && exists(':LLmode')
		nmap <buffer> <unique> <LocalLeader>db <Plug>LLBreakSwitch
		" vmap <F2> <Plug>LLStdInSelected
		" nnoremap <F4> :LLstdin<cr>
		" nnoremap <F5> :LLmode debug<cr>
		" nnoremap <S-F5> :LLmode code<cr>
		nnoremap <buffer> <unique> <LocalLeader>dc :LL continue<cr>
		nnoremap <buffer> <unique> <LocalLeader>do :LL thread step-over<cr>
		nnoremap <buffer> <unique> <LocalLeader>di :LL thread step-in<cr>
		nnoremap <buffer> <unique> <LocalLeader>dt :LL thread step-out<cr>
		nnoremap <buffer> <unique> <LocalLeader>dD :LLmode code<cr>
		nnoremap <buffer> <unique> <LocalLeader>dd :LLmode debug<cr>
		nnoremap <buffer> <unique> <LocalLeader>dp :LL print <C-R>=expand('<cword>')<cr>
		" nnoremap <S-F8> :LL process interrupt<cr>
		" nnoremap <F9> :LL print <C-R>=expand('<cword>')<cr>
		" vnoremap <F9> :<C-U>LL print <C-R>=lldb#util#get_selection()<cr><cr>
	endif
	call ftplugin#TagMappings()
	call ftplugin#Align('/\/\/')

	if exists('g:clang_format_py')
		nnoremap <buffer> <LocalLeader>f :execute('pyf ' . g:clang_format_py)<cr>
	endif
endif

" Setup AutoHighlight
call ftplugin#AutoHighlight()

" Setup Compiler and some specific stuff
call ftplugin#SetCompilersAndOther()

let b:undo_ftplugin = 'setl omnifunc< ts< sw< sts< foldenable< define< spell< matchpairs< foldmethod< foldnestmax<| unlet! b:delimitMate_matchpairs b:match_words'
