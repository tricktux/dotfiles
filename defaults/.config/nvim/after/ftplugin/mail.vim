" File:           mail.vim
" Description:    Options for writing emails
" Author:		    Reinaldo Molina
" Email:          rmolin88 at gmail dot com
" Revision:	    0.0.0
" Created:        Mon Jan 15 2018 05:56
" Last Modified:  Mon Jan 15 2018 05:56


" Only do this when not done yet for this buffer
if exists('b:did_mail_ftplugin')
	finish
endif

" Don't load another plugin for this buffer
let b:did_mail_ftplugin = 1

setlocal wrap
setlocal spell spelllang=en
" Many people recommend keeping e-mail messages 72 chars wide
setlocal tw=72
" setlocal omnifunc=muttaliases#CompleteMuttAliases

let mail_alias_program="Abook"

if !exists("no_plugin_maps") && !exists("no_mail_maps")
	nnoremap <buffer> <unique> <localleader>a :edit ~/.local/share/mutt/aliases.txt
	" nmap <buffer> <unique> <LocalLeader>al  <Plug>MailAliasList
	" nmap <buffer> <unique> <LocalLeader>aq  <Plug>MailAliasQuery

	nnoremap <buffer> <unique> <script> <Plug>MailAliasList <SID>AliasList
	nnoremap <buffer> <SID>AliasList A<c-r>=<SID>AliasList{mail_alias_program}()<cr><c-o>:set nopaste<cr><c-o>:redraw!<cr><c-o>:echo b:AliasListMsg<cr><esc>


	nnoremap <buffer> <unique> <script> <Plug>MailAliasQuery <SID>AliasQuery
	nnoremap <buffer> <SID>AliasQuery      :call <SID>AliasQuery{mail_alias_program}()<cr>:echo b:AliasQueryMsg<cr>
endif
"

" Description:
" This function will launch abook and spit out what the user selected from the
" application (by pressing 'Q').  It's always called from 'insert' mode, so
" the text will be inserted like it was typed.
"
" That's why 'paste' is set and reset.  So that the text that we insert won't
" be 'mangled' by the user's settings.
function! s:AliasListAbook() abort
	let b:AliasListMsg = ""
	let f = tempname()

	set paste
	silent exe '!abook 2> ' . f
	exe 'let addresses=system("cat ' . f . '")'
	if "" == addresses
		let b:AliasListMsg = "Nothing found to lookup"
		return ""
	endif

	" - parses the output from abook
	let addresses=s:ParseMuttQuery(addresses)
	if "" == addresses
		let b:AliasListMsg = b:ParseMuttQueryErr
		return ""
	endif

	" so that they will be aligned under the 'to' or 'cc' line
	let addresses=substitute(addresses, "\n", ",\n    ", "g")

	return addresses
endfunction


" Description:
" This function will take the output of a "mutt query" (as defined by the mutt
" documenation) and parses it.  
"
" It returns the email addresses formatted as follows:
" - each address is on a line
function! s:ParseMuttQuery(aliases) abort
	" remove first informational line
	let aliases   = substitute (a:aliases, "\n", "", "")
	let expansion = ""

	while 1
		" whip off the name and address
		let line    = matchstr(aliases, ".\\{-}\n")
		let address = matchstr(line, ".\\{-}\t")
		let address = substitute(address, "\t", "", "g")
		if "" == address
			let b:ParseMuttQueryErr = "Unable to parse address from ouput"
			return ""
		endif

		let name = matchstr(line, "\t.*\t")
		let name = substitute(name, "\t", "", "g")
		if "" == name
			let b:ParseMuttQueryErr = "Unable to parse name from ouput"
			return ""
		endif

		" debugging:
		" echo "line: " . line . "|"
		" echo "address: " . address . "|"
		" echo "name: " . name . "|"
		" let a=input("hit enter")

		" make into valid email address
		let needquote = match (name, '"')
		if (-1 == needquote)
			let name = '"' . name    . '" '
		endif

		let needquote = match (address, '<')
		if (-1 == needquote)
			let address = '<' . address . '>'
		endif

		" add email address to list
		let expansion = expansion . name
		let expansion = expansion . address

		" debugging:
		" echo "address: " . address . "|"
		" echo "name: " . name . "|"
		" let a=input("hit enter")

		" process next line (if there is one)
		let aliases = substitute(aliases, ".\\{-}\n", "", "")
		if "" == aliases
			let b:ParseMuttQueryErr = ""
			return expansion
		endif

		let expansion = expansion . "\n"
	endwhile
endfunction


" Description:
" This function assumes that user has the cursor on an alias to lookup.  Based
" on this it:
" - retrieves the alias(es) from abook
" - parses the output from abook
" - actually replaces the alias with the parsed output
function! s:AliasQueryAbook() abort
	let b:AliasQueryMsg = ""

	" - retrieves the alias(es) from abook
	let lookup=expand("<cword>")
	if "" == lookup
		let b:AliasQueryMsg = "Nothing found to lookup"
		return
	endif

	silent exe 'let output=system("abook --mutt-query ' . lookup . '")'
	if v:shell_error
		let b:AliasQueryMsg = output
		return
	endif

	" - parses the output from abook
	let replacement=s:ParseMuttQuery(output)
	if "" == replacement
		let b:AliasQueryMsg = b:ParseMuttQueryErr
		return
	endif

	" so that they will be aligned under the 'to' or 'cc' line
	let replacement=substitute(replacement, "\n", ",\n    ", "g")

	" - actually replaces the alias with the parsed output
	" paste is set/unset so that the email addresses aren't "mangled" by the
	" user's formating options
	set paste
	exe "normal! ciw" . replacement . "\<Esc>"
	set nopaste
endfunction

let b:undo_ftplugin = 'setl spell< spelllang< wrap< tw<'
