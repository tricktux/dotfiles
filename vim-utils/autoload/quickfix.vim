" File:					qf.vim
"	Description:	Quickfix vim plugin. Functionality to close/open and move around
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:				1.0.0
" Last Modified: May 04 2017 11:05
" Created: May 04 2017 11:05
" Note: File after/ftplugin/qf.vim is also part of this plugin

function! quickfix#OpenQfWindow() abort
	if !empty(getqflist())
		execute "normal :copen 20\<CR>\<C-W>J"	
	elseif !empty(getloclist(0))
		lopen 20
	else
		echomsg 'Quickfix and Location Lists are empty'
	endif
endfunction

function! quickfix#GetBufferList()
	redir =>buflist
	silent! ls!
	redir END
	return buflist
endfunction

function! quickfix#ToggleList(bufname, pfx)
	let buflist = quickfix#GetBufferList()
	for bufnum in map(filter(split(buflist, '\n'), 'v:val =~ "'.a:bufname.'"'), 'str2nr(matchstr(v:val, "\\d\\+"))')
		if bufwinnr(bufnum) != -1
			exec(a:pfx.'close')
			return
		endif
	endfor
	if a:pfx == 'l' && len(getloclist(0)) == 0
		echohl ErrorMsg
		echo "Location List is Empty."
		return
	endif
	let winnr = winnr()
	exec(a:pfx.'open')
	if winnr() != winnr
		wincmd p
	endif
endfunction

function! quickfix#ListsNavigation(cmd) abort
	try
		let list = 0
		if !empty(getloclist(0)) " if location list is not empty
			let list = 1
			execute "silent l" . a:cmd
		elseif !empty(getqflist()) " if quickfix list is not empty
			execute "silent c" . a:cmd
		else
			echohl ErrorMsg
			redraw " always use it to prevent msg from dissapearing
			echomsg "ListsNavigation(): Lists quickfix and location are empty"
			echohl None
		endif
	catch /:E553:/ " catch no more items error
		if list == 1
			silent .ll
		else
			silent .cc
		endif
	endtry
endfunction
