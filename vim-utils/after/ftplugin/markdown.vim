
" File:					markdown.vim
" Description:	After default ftplugin for markdown
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:			1.0.0
" Date:					Wed Nov 30 2016 09:21

setlocal foldenable
setlocal foldexpr=MarkdownLevel()
setlocal foldmethod=expr
setlocal spell spelllang=en_us
inoremap <buffer> * **<Left>

let b:undo_ftplugin += "setl omnifunc< ts< sw< sts< foldenable< | unlet b:match_words" 
