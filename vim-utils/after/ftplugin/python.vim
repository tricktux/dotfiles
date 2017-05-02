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
	if exists(':SyntasticCheck')
		nnoremap <buffer> <unique> <Leader>lo :SyntasticToggleMode<CR>
		nnoremap <buffer> <unique> <Leader>ls :SyntasticCheck<CR>
	endif

	if exists(':Autoformat') && exists(':Isort')
		nnoremap <buffer> <unique> <Leader>lf :Autoformat<CR>Isort<CR>
	endif

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
	nnoremap <buffer> <unique> <Leader>tu :call ctags#NvimSyncCtags(0)<CR>

endif

" TODO.RM-Tue May 02 2017 16:53: unlet b:plugin_options
" Add support for `isort`
" Also add better python highlight
" Look into `AsyncRun` plugin. Keep in mind that this is `vim` plugin. May not
" work properly in `nvim`

