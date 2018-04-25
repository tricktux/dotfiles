" File:					java.vim
" Description:	After default ftplugin for java
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:			1.0.0
" Last Modified: Wed Apr 25 2018 15:26
" Created:			Wed Nov 30 2016 09:21

" Only do this when not done yet for this buffer
if exists("b:did_java_ftplugin")
	finish
endif

" Don't load another plugin for this buffer
let b:did_java_ftplugin = 1

let b:match_words .= '\<if\>:\<else\>,'
			\ . '\<while\>:\<continue\>:\<break\>,'
			\ . '\<for\>:\<continue\>:\<break\>,'
			\ . '\<try\>:\<catch\>'
if exists('*javacomplete#Complete')
	setlocal omnifunc=javacomplete#Complete
endif
setlocal foldenable
compiler gradlew

" Add mappings, unless the user didn't want this.
if !exists("no_plugin_maps") && !exists("no_java_maps")
	call ftplugin#Align('/\/\/')
	call ftplugin#Syntastic('passive', [])
endif

call ftplugin#AutoHighlight()

let b:undo_ftplugin += "setl omnifunc< foldenable< | unlet! b:match_words"
