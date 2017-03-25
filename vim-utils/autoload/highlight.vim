
" File:highlight.vim
"	Description: File to define function and colors for highlight
" Author:Reinaldo Molina <rmolin88@gmail.com>
" Version:1.0.0
" Last Modified: Mar 25 2017 14:27
" Taken from: 
"
" colors {{{1
" let g:bg         = { 'gui': '#0c0c0c', 'cterm': 'none' }
" let g:fg         = { 'gui': '#424242', 'cterm': 'none' }

let g:black      = { 'gui': '#212121', 'cterm': '0' }
let g:grey       = { 'gui': '#424242', 'cterm': '8' }

let g:darkred    = { 'gui': '#d32f2f', 'cterm': '1' }
let g:red        = { 'gui': '#f44336', 'cterm': '9' }

let g:darkgreen  = { 'gui': '#689f38', 'cterm': '2' }
let g:green      = { 'gui': '#8bc34a', 'cterm': '10' }

let g:brown      = { 'gui': '#ffa000', 'cterm': '3' }
let g:yellow     = { 'gui': '#ffc107', 'cterm': '11' }

let g:darkblue   = { 'gui': '#0288d1', 'cterm': '4' }
let g:blue       = { 'gui': '#03a9f4', 'cterm': '12' }

let g:purple     = { 'gui': '#c2185b', 'cterm': '5' }
let g:pink       = { 'gui': '#e91e63', 'cterm': '13' }

let g:darkcyan   = { 'gui': '#0097a7', 'cterm': '6' }
let g:cyan       = { 'gui': '#00bcd4', 'cterm': '14' }

let g:lightgrey  = { 'gui': '#757575', 'cterm': '7' }
let g:white      = { 'gui': '#e0e0e0', 'cterm': '15' }

let g:darkergrey = { 'gui': '#121212', 'cterm': '233' }
let g:darkgrey   = { 'gui': '#1c1c1c', 'cterm': '234' }
" 1}}}
" util {{{1
function! highlight#Set(group, style)
	if(has_key(a:style, 'link'))
		exec 'highlight! link ' a:group a:style.link
	else
		exec 'highlight' a:group
					\ 'guifg='   (has_key(a:style, 'fg')    ? a:style.fg.gui   : 'NONE')
					\ 'guibg='   (has_key(a:style, 'bg')    ? a:style.bg.gui   : 'NONE')
					\ 'guisp='   (has_key(a:style, 'sp')    ? a:style.sp.gui   : 'NONE')
					\ 'gui='     (has_key(a:style, 'deco')  ? a:style.deco     : 'NONE')
					\ 'ctermfg=' (has_key(a:style, 'fg')    ? a:style.fg.cterm : 'NONE')
					\ 'ctermbg=' (has_key(a:style, 'bg')    ? a:style.bg.cterm : 'NONE')
					\ 'cterm='   (has_key(a:style, 'deco')  ? a:style.deco     : 'NONE')
	endif
endfunction
" 1}}}
" vim:fdm=marker
