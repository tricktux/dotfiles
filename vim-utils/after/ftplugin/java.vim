
" File:					java.vim
" Description:	After default ftplugin for java
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:			1.0.0
" Date:					Wed Nov 30 2016 09:21

let b:match_words = '\<if\>:\<else\>,'
			\ . '\<while\>:\<continue\>:\<break\>,'
			\ . '\<for\>:\<continue\>:\<break\>,'
			\ . '\<try\>:\<catch\>'
setlocal omnifunc=javacomplete#Complete
:RainbowParentheses
setlocal foldenable
" Only for current buffer
compiler! gradlew

let b:undo_ftplugin += "setl omnifunc< ts< sw< sts< foldenable< | unlet b:match_words" 
