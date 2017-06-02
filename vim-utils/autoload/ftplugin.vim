
" File:					ftplugin.vim
"	Description:	Functions that set settings that are common for different
"								environments. Like c, python, java, .etc
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:				1.0.0
" Last Modified: Jun 02 2017 10:19
" Created:			Jun 02 2017 10:19

function! ftplugin#AutoHighlight() abort
	if exists('*utils#AutoHighlightToggle') && !exists('g:highlight')
		silent call utils#AutoHighlightToggle()
		nnoremap <buffer> <Leader>lh :call utils#AutoHighlightToggle()<CR>
	endif
endfunction

function! ftplugin#TagMappings() abort
	" Cscope and tag jumping mappings
	nnoremap <buffer> <Leader>tk :cs kill -1<CR>
	nnoremap <buffer> <Leader>tv :vs<CR>:exec("tag ".expand("<cword>"))<CR>
	" ReLoad cscope database
	nnoremap <buffer> <Leader>tl :call ctags#LoadCscopeDatabse()<CR>
	" Find functions calling this function
	nnoremap <buffer> <Leader>tc :cs find c <C-R>=expand("<cword>")<CR><CR>
	" Find functions definition
	nnoremap <buffer> <Leader>tg :cs find g <c-r>=expand("<cword>")<cr><cr>
	" Find functions called by this function not being used
	" nnoremap <Leader>td :cs find d <C-R>=expand("<cword>")<CR><CR>
	nnoremap <buffer> <Leader>ts :cs show<CR>
	nnoremap <buffer> <Leader>tu :call ctags#NvimSyncCtags(0)<CR>
endfunction

function! ftplugin#QuickFixMappings() abort
	if exists('*quickfix#ToggleList')
		nnoremap <silent> <buffer> <Leader>ll :call quickfix#ToggleList("Location List", 'l')<CR>
		nnoremap <silent> <buffer> <Leader>;; :call quickfix#ToggleList("Quickfix List", 'c')<CR>
		nnoremap <buffer> <Leader>ln :call quickfix#ListsNavigation("next")<CR>
		nnoremap <buffer> <Leader>lp :call quickfix#ListsNavigation("previous")<CR>
	endif
endfunction

" For cpp use '/\/\/'
" For vim use '/"'
" For python use '/#'
function! ftplugin#Align(comment) abort
	if exists(':Tabularize')
		execute "vnoremap <buffer> <Leader>oa :Tabularize " . a:comment . "<CR>"
	endif
endfunction

function! ftplugin#Syntastic(mode, checkers) abort
	if exists(':SyntasticCheck')
		nnoremap <buffer> <unique> <Leader>lo :SyntasticToggleMode<CR>
		nnoremap <buffer> <unique> <Leader>ls :SyntasticCheck<CR>
	endif
	if !empty(a:checkers)
		let b:syntastic_checkers=a:checkers
	endif
	let b:syntastic_mode =a:mode
endfunction
