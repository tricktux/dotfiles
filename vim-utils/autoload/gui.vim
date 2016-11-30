" File:gui.vim
" Description:Gui-Console settings
" Author:Reinaldo Molina <rmolin88@gmail.com>
" Version:1.0.0
" Last modified:Nov 30 2016 08:49

function! gui#Config() abort
	if has('gui_running')
		let &guifont = g:custom_font " OS dependent font
		set guioptions-=T  " no toolbar
		set guioptions-=m  " no menu bar
		set guioptions-=r  " no right scroll bar
		set guioptions-=l  " no left scroll bar
		set guioptions-=L  " no side scroll bar
		if has('nvim') && has('win32')
			Guifont DejaVu Sans Mono:h9
		endif
	else " common cli options to both systems
		if $TERM ==? 'linux'
			set t_Co=8
		else
			set t_Co=256
		endif
		" fixes colorscheme not filling entire backgroud
		set t_ut=
		" Set blinking cursor shape everywhere
		if has('nvim')
			let $NVIM_TUI_ENABLE_TRUE_COLOR=1
			let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1
			" Fixes broken nmap <c-h> inside of tmux
			nnoremap <BS> :noh<CR>
		endif

		" TODO.RM-Wed Nov 30 2016 09:01: Testing here may break things  
		if exists('$TMUX')
			let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
			let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
		elseif has('win32')
			set term=xterm
			let &t_AB="\e[48;5;%dm"
			let &t_AF="\e[38;5;%dm"
		else
			let &t_SI = "\<Esc>[5 q"
			let &t_EI = "\<Esc>[1 q"
		endif
	endif
endfunction

" vim:tw=78:ts=2:sts=2:sw=2:
