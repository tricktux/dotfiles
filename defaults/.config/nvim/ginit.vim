" if exists('g:GuiLoaded') " nvim-qt gui
	" Choose one
	" Guifont DejaVu Sans Mono:h10
	" Guifont Hack:h8
	" Guifont Monospace:h10
	" Guifont Incosolata for Powerline:h10
	" Guifont! Consolas:h9
	" Guifont! FontAwesome:h9
	" endif
	" Note: Fri Mar 03 2017 14:59 - Not having much of an effect in windows  
	" call GuiMousehide(1)
if has('win32')
	if exists('g:GuiLoaded') " nvim-qt gui
		Guifont! Consolas:h9
		call GuiWindowMaximized(1)
	else
		" No space is required here
		set guifont=consolas:h8
	endif
else
	if exists('g:GuiLoaded') " nvim-qt gui
		Guifont! Consolas:h9
		call GuiWindowMaximized(1)
	else
		" set guifont =Hack 8
		set guifont =DejaVu\ Sans\ Mono\ 8
	endif
endif
set guioptions-=T  " no toolbar
set guioptions-=m  " no menu bar
set guioptions-=r  " no right scroll bar
set guioptions-=l  " no left scroll bar
set guioptions-=L  " no side scroll bar

" vim:tw=78:ts=2:sts=2:sw=2:
