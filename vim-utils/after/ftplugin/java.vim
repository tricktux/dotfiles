" File:					java.vim
" Description:	After default ftplugin for java
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:			1.0.0
" Last Modified: Fri Jun 02 2017 10:14
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
setlocal omnifunc=javacomplete#Complete
setlocal foldenable
compiler gradlew

" Add mappings, unless the user didn't want this.
if !exists("no_plugin_maps") && !exists("no_java_maps")
	call ftplugin#QuickFixMappings()
	call ftplugin#TagMappings()
	call ftplugin#Align('/\/\/')
	call ftplugin#Syntastic('passive', [])
	nnoremap <buffer> <unique> <Leader>od :call <SID>CommentDelete()<CR>
	" Comment Indent Increase/Reduce
	nnoremap <buffer> <unique> <Leader>oi :call <SID>CommentIndent()<CR>
	nnoremap <buffer> <unique> <Leader>oI :call <SID>CommentReduceIndent()<CR>
endif

call ftplugin#AutoHighlight()

let b:undo_ftplugin += "setl omnifunc< foldenable< | unlet b:match_words" 
