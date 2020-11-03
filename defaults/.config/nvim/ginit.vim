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
function! s:win_nvim_ugly_font() abort
    let g:GuiFont ='FontAwesome:h9'
    execute 'Guifont! ' . g:GuiFont
	" Guifont! Consolas:h10
	" Fri Jan 11 2019 11:22 
	" Dont auto maximize
	" call GuiWindowMaximized(1)
	return s:set_nvim_qt_guioptions()
endfunction

function! s:win_nvim_nice_font() abort
	" let g:GuiFont ='DejaVuSansMonoForPowerline Nerd:h9'
    let g:GuiFont ='SauceCodePro Nerd Font Mono:h9'
    " let g:GuiFont ='FontAwesome:h9'
	" let g:GuiFont ='UbuntuMono NF:h11'
  " let g:GuiFont ='DejaVuSansMono NF:h9'
	" let g:GuiFont ='FuraCode Nerd Font Mono:h10'
	execute 'Guifont! ' . g:GuiFont
	return s:set_nvim_qt_guioptions()
endfunction

function! s:win_gvim_ugly_font() abort
	set guifont=consolas:h10
	call s:set_gvim_guioptions()
endfunction

function! s:win_gvim_nice_font() abort
	set guifont=consolas:h10
	call s:set_gvim_guioptions()
endfunction

function! s:unix_nvim_ugly_font() abort
	let g:GuiFont ='FuraCode Nerd Font:h9'
	execute 'Guifont! ' . g:GuiFont
	return s:set_nvim_qt_guioptions()
endfunction

function! s:unix_nvim_nice_font() abort
	let g:GuiFont ='FuraCode Nerd Font:h9'
	execute 'Guifont! ' . g:GuiFont
	return s:set_nvim_qt_guioptions()
endfunction

function! s:unix_gvim_ugly_font() abort
	set guifont=Consolas:h8
	call s:set_gvim_guioptions()
endfunction

function! s:unix_gvim_nice_font() abort
	set guifont =DejaVu\ Sans\ Mono\ 10
	call s:set_gvim_guioptions()
endfunction

function! s:set_gvim_guioptions() abort
	set guioptions-=T  " no toolbar
	set guioptions-=m  " no menu bar
	set guioptions-=r  " no right scroll bar
	set guioptions-=l  " no left scroll bar
	set guioptions-=L  " no side scroll bar
	set guioptions+=c  " no pop ups
endfunction

function! s:set_nvim_qt_guioptions() abort
	GuiTabline 0
	GuiPopupmenu 0
endfunction

function! SetGui() abort
	if has('unix') && exists('g:GuiLoaded') && !exists('g:valid_device')
		return s:unix_nvim_ugly_font()
	elseif has('unix') && exists('g:GuiLoaded') && exists('g:valid_device')
		return s:unix_nvim_nice_font()
	elseif has('unix') && !exists('g:GuiLoaded') && !exists('g:valid_device')
		return s:unix_gvim_ugly_font()
	elseif has('unix') && !exists('g:GuiLoaded') && exists('g:valid_device')
		return s:unix_gvim_nice_font()
	elseif has('win32') && exists('g:GuiLoaded') && !exists('g:valid_device')
		return s:win_nvim_ugly_font()
	elseif has('win32') && exists('g:GuiLoaded') && exists('g:valid_device')
		return s:win_nvim_nice_font()
	elseif has('win32') && !exists('g:GuiLoaded') && !exists('g:valid_device')
		return s:win_gvim_ugly_font()
	elseif has('win32') && !exists('g:GuiLoaded') && exists('g:valid_device')
		return s:win_gvim_nice_font()
	endif
endfunction

call SetGui()
