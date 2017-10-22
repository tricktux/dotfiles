
" File:					ftplugin.vim
"	Description:	Functions that set settings that are common for different
"								environments. Like c, python, java, .etc
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:				1.0.0
" Last Modified: Sun Jun 04 2017 15:59
" Created:			Jun 02 2017 10:19
" Wed Oct 18 2017 13:52: Decided to change many of these from mappings to commands. Most of these mappings
" are rarely used. It makes more sense to free up these mappings and make them mappings. 

function! ftplugin#AutoHighlight() abort
	if exists("*utils#AutoHighlightToggle") && !exists('g:highlight')
		silent call utils#AutoHighlightToggle()
		command! UtilsAutoHighlightToggle call utils#AutoHighlightToggle()
	endif
endfunction

function! ftplugin#TagMappings() abort
	" Cscope and tag jumping mappings
	" nnoremap <buffer> <Leader>tk :cs kill -1<CR>
	command! UtilsTagKill :cs kill -1<CR>
	" nnoremap <buffer> <Leader>tv :vs<CR>:exec("tag ".expand("<cword>"))<CR>
	" ReLoad cscope database
	" nnoremap <buffer> <Leader>tl :call ctags#LoadCscopeDatabse()<CR>
	command! UtilsTagLoadCurrFolder call ctags#LoadCscopeDatabse()
	" Find functions calling this function
	" nnoremap <buffer> <Leader>tc :cs find c <C-R>=expand("<cword>")<CR><CR>
	" Find functions definition
	" nnoremap <buffer> <Leader>tg :cs find g <c-r>=expand("<cword>")<cr><cr>
	" Find functions called by this function not being used
	" nnoremap <Leader>td :cs find d <C-R>=expand("<cword>")<CR><CR>
	" nnoremap <buffer> <Leader>ts :cs show<CR>
	command! UtilsTagShow :cs show<CR>
	" nnoremap <buffer> <Leader>tu :call ctags#NvimSyncCtags(0)<CR>
	command! UtilsTagUpdateCurrFolder call ctags#NvimSyncCtags(0)
endfunction

" For cpp use '/\/\/'
" For vim use '/"'
" For python use '/#'
function! ftplugin#Align(comment) abort
	if exists(":Tabularize")
		execute "vnoremap <buffer> <Leader>oa :Tabularize " . a:comment . "<CR>"
	endif
endfunction

function! ftplugin#Syntastic(mode, checkers) abort
	if exists(":SyntasticCheck")
		" nnoremap <buffer> <unique> <Leader>lo :SyntasticToggleMode<CR>
		nnoremap <buffer> <LocalLeader>c :SyntasticCheck<CR>
	endif
	if !empty(a:checkers)
		let b:syntastic_checkers=a:checkers
	endif
	let b:syntastic_mode =a:mode
endfunction
