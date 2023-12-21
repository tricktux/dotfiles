" File:           passwd.vim
" Description:    Settings and options
" Author:		    Reinaldo Molina
" Email:          rmolin88 at gmail dot com
" Revision:	    0.0.0
" Created:        Fri Dec 01 2017 10:14
" Last Modified:  Fri Dec 01 2017 10:14

if exists('g:loaded_passwd')
	finish
endif

let g:loaded_passwd = 1

if !exists('g:passwd_clipboard')
	let g:passwd_clipboard = has('unix') ? 'xclip' : 'clip'
endif

if !exists('g:passwd_store_dir')
  let g:passwd_store_dir = v:lua.vim.loop.os_homedir() . (has('unix') ? "/" : "\\") . '.password-store'
endif

" Completely ignores g:passwd_clipboard
if !exists('g:passwd_clear_clipboard_cmd')
	let g:passwd_clear_clipboard_cmd = has('unix') ? 'xclip -i /dev/null' : 'echo off | clip'
endif

if !exists('g:passwd_sec_on_clipboard')
	let g:passwd_sec_on_clipboard = 45
endif
