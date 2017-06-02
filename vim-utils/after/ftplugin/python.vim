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

if !exists("no_plugin_maps") && !exists("no_python_maps")
	if exists(':Autoformat') && exists(':Isort')
		nnoremap <buffer> <unique> <Leader>lf :Autoformat<CR>Isort<CR>
	endif

	call ftplugin#QuickFixMappings()
	call ftplugin#TagMappings()
	call ftplugin#Align('/#')
	call ftplugin#Syntastic('passive', ['flake8', 'pep8', 'pycodestyle', 'pyflakes', 'python'])
endif

" Setup AutoHighlight
call ftplugin#AutoHighlight()

" TODO.RM-Tue May 02 2017 16:53: 
" Add support for `isort`
" Also add better python highlight

let b:undo_ftplugin = "setlocal textwidth< commentstring< define<" 
