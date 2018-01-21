" File:					ginit.vim
" Description:	Settings applied before gui is loaded.
" Author:				Reinaldo Molina <rmolin88 at gmail dot com>
" Version:				0.0.0
" Last Modified: Oct 27 2017 08:16
" Created: Oct 27 2017 08:16

	" Choose one font
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
		let g:GuiFont ='Consolas:h8'
		execute 'Guifont! ' . g:GuiFont
		call GuiWindowMaximized(1)
		call GuiMousehide(1)
	else
		" No space is required here
		" set guifont=consolas:h8
		" set guifont=DejaVu_Sans_Mono_for_Powerline:h8
		set guifont=DejaVuSansMonoForPowerline_NF:h9
	endif
else
	if exists('g:GuiLoaded') " nvim-qt gui
		" TODO.RM-Sat May 20 2017 10:21: Probably will have to make this hostname
		" depenednt
		" let g:GuiFont ='Monospace:h9'
		" let g:GuiFont ='FontAwesome:h10'
		let g:GuiFont ='DejaVu Sans Mono:h10'
		execute 'Guifont! ' . g:GuiFont
		call GuiMousehide(1)
	else
		" set guifont =Hack 8
		set guifont =DejaVu\ Sans\ Mono\ 9
		" only for GTK and X11 gvim guis
		set guiheadroom=0
	endif
endif

set guioptions-=T  " no toolbar
set guioptions-=m  " no menu bar
set guioptions-=r  " no right scroll bar
set guioptions-=l  " no left scroll bar
set guioptions-=L  " no side scroll bar
set guioptions+=c  " no pop ups
set showtabline=1		" do not show tabline

