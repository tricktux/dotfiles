" File:           passwd.vim
" Description:    Code to get passwords from the password store
" Author:		    Reinaldo Molina
" Email:          rmolin88 at gmail dot com
" Revision:	    <`4:0.0.0`>
" Created:        Fri Dec 01 2017 10:04
" Last Modified:  Fri Dec 01 2017 10:04

function! s:copy_passwd_to_clipboard(passwd_file) abort
	if !executable('gpg')
		echoerr 'Please install gpg'
		return -1
	endif

	if empty(a:passwd_file) || empty(glob(a:passwd_file))
		echoerr 'Error locating input passwd_file: ' . a:passwd_file
		return -2
	endif

	if !executable(g:passwd_clipboard)
		echoerr 'Provided clipboard "'. g:passwd_clipboard . '" is not executable'
		return -3
	endif

	let decrypt_cmd = 'gpg -d ' . a:passwd_file . ' | ' . g:passwd_clipboard

	cexpr system(decrypt_cmd)

	if v:shell_error
		echoerr 'gpg command: ' . decrypt_cmd . ' failed'
		return -4
	endif

	if !has('timers')
		echoerr 'Vim is missing the "timers" feature.\n' .
					\ 'Cannot clear clipboard without this feature.\n' .
					\	'!!!Please do it manually!!!'
		return -5
	endif

	echomsg 'Copied password: ' . a:passwd_file . " to clipboard."
				\ 'It will be cleared in ' . g:passwd_sec_on_clipboard . ' seconds'
	return timer_start(g:passwd_sec_on_clipboard*1000, funcref('s:clear_system_clipboard'))
endfunction

function! passwd#SelectPasswdFile() abort
	if exists(':Denite')
		call setreg(v:register, "") " Clean up register
		execute "Denite -default-action=yank -path=" . g:passwd_store_dir . " file_rec"
		let passwd_file = getreg()
		if empty(passwd_file)
			return
		endif
		" TODO-[RM]-(Fri Dec 01 2017 11:54): This down here could be a problem. Need to
		" detect if the '/' was provided in the name. If user provides it could be
		" duplicated here
		return s:copy_passwd_to_clipboard(g:passwd_store_dir . '/' . passwd_file)
	else
		echoerr 'Denite not accessible. Dont know any other way to this'
	endif

	" TODO-[RM]-(Fri Dec 01 2017 11:48): Provide alternative to Denite
endfunction

function! s:clear_system_clipboard(timer) abort
	echomsg 'Clearing clibpboard'
	cexpr system(g:passwd_clear_clipboard_cmd)

	if v:shell_error
		echoerr 'Failed to clear clipboard with command: ' . g:passwd_clear_clipboard_cmd
	endif
endfunction
