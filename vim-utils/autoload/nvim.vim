" File:           nvim.vim
" Description:		Neovim exclusive settings
" Author:         Reinaldo Molina <rmolin88@gmail.com>
" Version:        1.0.0
" Date:						Nov 29 2016 22:59

function! nvim#Config() abort
	" terminal-emulator mappings
	execute "tnoremap " . g:esc . " <C-\\><C-n>"
	tnoremap <A-h> <C-\><C-n><C-w>h
	tnoremap <A-j> <C-\><C-n><C-w>j
	tnoremap <A-k> <C-\><C-n><C-w>k
	tnoremap <A-l> <C-\><C-n><C-w>l

	" TODO.RM-Sat Apr 29 2017 17:20: Need to rethink all of this mappings here  
	tnoremap <A-s> <Down>
	tnoremap <A-w> <Up>
	tnoremap <C-k> <Up>
	tnoremap <A-a> <Left>
	tnoremap <A-d> <Right>

	" set inccommand=split
	" set clipboard+=unnamedplus
	set termguicolors
endfunction
" vim:tw=78:ts=2:sts=2:sw=2:
