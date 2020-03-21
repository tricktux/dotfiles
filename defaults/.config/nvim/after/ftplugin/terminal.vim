" File:					terminal.vim
"	Description:	Set mappings and settings proper of nvim-terminal
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:				1.0.0
" Last Modified: Apr 29 2017 19:26
" Created: Apr 29 2017 19:26

" Only do this when not done yet for this buffer
if exists("b:did_terminal_ftplugin")
	finish
endif

" Don't load another plugin for this buffer
let b:did_terminal_ftplugin = 1

" If plugin neoterm was loaded and mappings accepted
if !exists("no_plugin_maps") && !exists("no_terminal_maps")
	if exists('*neoterm#close()')
		" hide/close terminal
		" Thu Apr 11 2019 11:25: Doesnt work. Plugin broken 
		nnoremap <buffer> <silent> Q :Tclose<cr>
	endif
	" Doesn't work, in win at least
  nnoremap <buffer> <silent> q ZZ
  nnoremap <buffer> <M-`> ZZ
	tnoremap <M-`> <c-\><c-n>ZZ
	" nunmap <buffer> <c-space>
	execute "tnoremap " . g:esc . " <C-\\><C-n>"
	tnoremap <A-h> <C-\><C-n><C-w>h
	tnoremap <A-j> <C-\><C-n><C-w>j
	tnoremap <A-k> <C-\><C-n><C-w>k
	tnoremap <A-l> <C-\><C-n><C-w>l

	tnoremap <a-]> <C-\><C-n>gt
	tnoremap <a-[> <C-\><C-n>gT
	for idx in range(1,9)
		execute 'tnoremap <silent> <a-' . idx .
					\ '> <C-\><C-n>' . idx. 'gt'
	endfor

	" Sun Dec 23 2018 11:34 
	" Can confuse things since I set it up in inputrc as well
	" tnoremap <C-p> <Up>
endif

if exists('+winhighlight') && has('nvim-0.4')
	" Create a Terminal Highlight group
	execute 'highlight Terminal guibg=' .
				\ (&background ==# 'light' ? 'White' : 'Black')
	" Overwrite ctermbg only for this window. Neovim exclusive option
	setlocal winhighlight=NormalFloat:Terminal
endif

function! s:check_zoom() abort
	if ((exists('g:loaded_zoom')) && (!empty(zoom#statusline())))
		call zoom#toggle()
	endif

	normal! ZZ
endfunction
