" File:           cs.vim
" Description:    ftplugin for csharp
" Author:		    Reinaldo Molina
" Email:          rmolin88 at gmail dot com
" Revision:	    0.0.0
" Created:        Fri Aug 23 2019 08:46
" Last Modified:  Fri Aug 23 2019 08:46

" Only do this when not done yet for this buffer
if exists('b:did_cs_ftplugin')
	finish
endif

" Don't load another plugin for this buffer
let b:did_cs_ftplugin = 1

let s:keepcpo= &cpo
set cpo&vim

setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal nospell
setlocal textwidth=79

function! s:set_omni_mappings() abort
	" The following commands are contextual, based on the cursor position.
	nnoremap <buffer> <localleader>ld :OmniSharpGotoDefinition<CR>
	nnoremap <buffer> <localleader>lfi :OmniSharpFindImplementations<CR>
	nnoremap <buffer> <localleader>lfs :OmniSharpFindSymbol<CR>
	nnoremap <buffer> <localleader>lfu :OmniSharpFindUsages<CR>

	" Finds members in the current buffer
	nnoremap <buffer> <localleader>lfm :OmniSharpFindMembers<CR>

	nnoremap <buffer> <localleader>lfx :OmniSharpFixUsings<CR>
	nnoremap <buffer> <localleader>ltt :OmniSharpTypeLookup<CR>
	nnoremap <buffer> <localleader>ldc :OmniSharpDocumentation<CR>
	nnoremap <buffer> <localleader>lh :OmniSharpSignatureHelp<CR>
	inoremap <buffer> <C-\> <C-o>:OmniSharpSignatureHelp<CR>

	" Navigate up and down by method/property/field
	nnoremap <buffer> <localleader>lj :OmniSharpNavigateUp<CR>
	nnoremap <buffer> <localleader>lk :OmniSharpNavigateDown<CR>

	" Find all code errors/warnings for the current solution and populate the quickfix window
	nnoremap <buffer> <localleader>lc :OmniSharpGlobalCodeCheck<CR>

	" Contextual code actions (uses fzf, CtrlP or unite.vim when available)
	nnoremap <buffer> <localleader>lg :OmniSharpGetCodeActions<CR>
	" Run code actions with text selected in visual mode to extract method
	xnoremap <buffer> <localleader>lg :call OmniSharp#GetCodeActions('visual')<CR>

	" Rename with dialog
	nnoremap <buffer> <localleader>lr :OmniSharpRename<CR>
endfunction

" Add mappings, unless the user didn't want this.
if !exists('no_plugin_maps') && !exists('no_cs_maps')
	if (exists(':Neomake'))
		nnoremap <buffer> <plug>make_file :Neomake<cr>
		nnoremap <buffer> <plug>make_project :Neomake!<cr>
	endif

	if exists(':OmniSharpStartServer')
		call <sid>set_omni_mappings()
	endif
endif

lua require('config.linting').set_neomake_msbuild_compiler('cs')

let &cpo = s:keepcpo
unlet s:keepcpo

let b:undo_ftplugin = 'setlocal tabstop<'
      \ . '|setlocal shiftwidth<'
      \ . '|setlocal softtabstop<'
      \ . '|setlocal nospell<'
      \ . '|setlocal textwidth<'
