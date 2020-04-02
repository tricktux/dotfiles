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

setlocal textwidth=79
setlocal commentstring=#%s
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

call autocompletion#AdditionalLspSettings()

" TODO.RM-Tue May 02 2017 16:53: 
" Add support for `isort`
" Also add better python highlight

let b:undo_ftplugin = "setlocal textwidth< commentstring< define<" 
