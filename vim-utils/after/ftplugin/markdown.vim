
" File:					markdown.vim
" Description:	After default ftplugin for markdown
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:			1.0.0
" Date:					Wed Nov 30 2016 11:02

setlocal foldenable
setlocal foldexpr=MarkdownLevel()
setlocal foldmethod=expr
setlocal spell spelllang=en_us
inoremap <buffer> * **<Left>
if has('unix')
	autocmd FileType markdown nnoremap <buffer> <Leader>mr :!google-chrome-stable %<CR>
endif

let b:undo_ftplugin += "setl foldenable< foldexpr< foldmethod< spell< spelllang<" 
