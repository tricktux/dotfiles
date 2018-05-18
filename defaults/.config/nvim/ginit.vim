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
function! SetGui() abort
	if has('win32')
		if exists('g:GuiLoaded') " nvim-qt gui

			if !exists('g:valid_device')
				Guifont! Consolas:h9
				return
			endif

			let g:GuiFont ='DejaVuSansMonoForPowerline Nerd:h8'
			execute 'Guifont! ' . g:GuiFont
			call GuiWindowMaximized(1)
			call GuiMousehide(1)
		else
			if !exists('g:valid_device')
				set guifont=consolas:h8
				return
			endif

			" No space is required here
			set guifont=DejaVuSansMonoForPowerline_Nerd:h8:cANSI:qDRAFT
		endif
		return
	endif

	if exists('g:GuiLoaded') " nvim-qt gui
		if !exists('g:valid_device')
			let g:GuiFont ='Monospace:h9'
			return
		endif

		let g:GuiFont ='DejaVu Sans Mono:h10'
		execute 'Guifont! ' . g:GuiFont
		call GuiMousehide(1)

	else
		if !exists('g:valid_device')
			set guifont=Consolas:h8
			return
		endif

		set guifont =DejaVu\ Sans\ Mono\ 9
		" only for GTK and X11 gvim guis
		set guiheadroom=0
	endif
endfunction

set guioptions-=T  " no toolbar
set guioptions-=m  " no menu bar
set guioptions-=r  " no right scroll bar
set guioptions-=l  " no left scroll bar
set guioptions-=L  " no side scroll bar
set guioptions+=c  " no pop ups
set showtabline=1		" do not show tabline
call SetGui()

