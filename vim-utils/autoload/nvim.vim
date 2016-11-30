" File:           nvim.vim
" Description:		Neovim exclusive settings
" Author:         Reinaldo Molina <rmolin88@gmail.com>
" Version:        1.0.0
" Date:						Nov 29 2016 22:59

function! nvim#Config() abort
	" terminal-emulator mappings
	tnoremap <C-j> <C-\><C-n>
	tnoremap <A-h> <C-\><C-n><C-w>h
	tnoremap <A-j> <C-\><C-n><C-w>j
	tnoremap <A-k> <C-\><C-n><C-w>k
	tnoremap <A-l> <C-\><C-n><C-w>l
	tnoremap <C-o> <Up>
	tnoremap <C-l> <Right>
	" set inccommand=split
	" set clipboard+=unnamedplus
endfunction
" vim:tw=78:ts=2:sts=2:sw=2:
