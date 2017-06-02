" File:vim.vim
"	Description:	ftplugin for the vim filetype
" Author:Reinaldo Molina <rmolin88@gmail.com>
" Version:1.0.0
" Last Modified: Thu May 04 2017 21:39
" Created: Apr 28 2017 15:41

" Only do this when not done yet for this buffer
if exists("b:did_vim_ftplugin")
	finish
endif

" Don't load another plugin for this buffer
let b:did_vim_ftplugin = 1

" Add mappings, unless the user didn't want this.
if !exists("no_plugin_maps") && !exists("no_vim_maps")
	" Quote text by inserting "> "
	nnoremap <buffer> <Plug>Make :so %<CR>
	nnoremap <buffer> <unique> <Leader>lh :h <c-r>=expand("<cword>")<CR><cr>
	call ftplugin#Align('/"')
	" vnoremap <buffer> <unique> <Leader>le :call <SID>Evaluate()<CR>
endif

" TODO.RM-Fri Jun 02 2017 11:32: Doesnt really work  
function! s:Evaluate() abort
	" Yank selection to reg a then echo it cli
	execute "normal \"ay:echomsg \<c-r>a\<cr>"
endfunction
