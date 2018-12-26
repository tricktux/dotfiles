

" File:highlight.vim
" Description: File to define function and colors for highlight
" Author:Reinaldo Molina <rmolin88@gmail.com>
" Version:1.0.0
" Last Modified: Mar 25 2017 14:27
" Taken from: neotags.nvim plugin
"
" util {{{1
" Keep in mind that none specified groups will be set to NONE
function! highlight#SetAll(group, style, ...)
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

" Keep in mind that none specified groups will keep its previous value
function! highlight#Set(group, style, ...)
	if(has_key(a:style, 'link'))
		exec 'highlight! link ' a:group a:style.link
	else
		exec 'highlight' a:group . ' ' .
					\ (has_key(a:style, 'fg')   ? 'guifg='  .a:style.fg.gui   : ' ') . ' ' .
					\ (has_key(a:style, 'bg')   ? 'guibg='  .a:style.bg.gui   : ' ') . ' ' .
					\ (has_key(a:style, 'sp')   ? 'guisp='  .a:style.sp.gui   : ' ') . ' ' .
					\ (has_key(a:style, 'deco') ? 'gui='    .a:style.deco     : ' ') . ' ' .
					\ (has_key(a:style, 'fg')   ? 'ctermfg='.a:style.fg.cterm : ' ') . ' ' .
					\ (has_key(a:style, 'bg')   ? 'ctermbg='.a:style.bg.cterm : ' ') . ' ' .
					\ (has_key(a:style, 'deco') ? 'cterm='  .a:style.deco     : ' ')

	endif
endfunction

" 1}}}
