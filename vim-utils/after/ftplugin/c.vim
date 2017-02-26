
" File:					c.vim
" Description:	After default ftplugin for c
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:			1.0.0
" Date:					Nov 25 2016 23:16
"
" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
	finish
endif

" Don't load another plugin for this buffer
let b:did_ftplugin = 1

let b:match_words = '\<if\>:\<else\>,'
			\ . '\<while\>:\<continue\>:\<break\>,'
			\ . '\<for\>:\<continue\>:\<break\>,'
			\ . '\<try\>:\<catch\>'
setlocal omnifunc=ClangComplete
setlocal ts=4 sw=4 sts=4
if exists(':RainbowParentheses')
	RainbowParentheses
endif
setlocal foldenable

let b:undo_ftplugin += "setl omnifunc< ts< sw< sts< foldenable< | unlet b:match_words" 
