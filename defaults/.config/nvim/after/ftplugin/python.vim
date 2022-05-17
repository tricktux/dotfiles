" File:					python.vim
"	Description:	Specific mappings for python development
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:			1.0.0
" Last Modified: Tue May 02 2017 15:45
" Created:			 May 02 2017 15:44

" Only do this when not done yet for this buffer
if exists("b:did_python_ftplugin")
	finish
endif
" Don't load another plugin for this buffer
let b:did_python_ftplugin = 1

let s:keepcpo= &cpo
set cpo&vim

setlocal textwidth=79
setlocal shiftwidth=4
setlocal tabstop=4
setlocal softtabstop=4
setlocal define=^\s*\\(def\\\\|class\\)

abbreviate <buffer> sefl self

if !exists("no_plugin_maps") && !exists("no_python_maps")
	if (exists(':Neoformat'))
		nnoremap <localleader>f :Neoformat<cr>
	endif
	if (exists(':Neomake'))
		nnoremap <buffer> <plug>make_file :Neomake<cr>
		nnoremap <buffer> <plug>make_project :Neomake!<cr>
	endif

endif

let b:undo_ftplugin = 'setlocal textwidth<'
      \ . '|setlocal shiftwidth<'
      \ . '|setlocal tabstop<'
      \ . '|setlocal softtabstop<'
      \ . '|setlocal define<'

let &cpo = s:keepcpo
unlet s:keepcpo
