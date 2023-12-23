" File:           passwd.vim
" Description:    Code to get passwords from the password store
" Author:		    Reinaldo Molina
" Email:          rmolin88 at gmail dot com
" Revision:	    0.0.0
" Created:        Fri Dec 01 2017 10:04
" Last Modified:  Fri Dec 01 2017 10:04

let s:splitter = has('unix') ? '/' : '\'

function! passwd#OnTextYankPost() abort
  " Telescope is 
  return s:copy_passwd_to_clipboard(getreg('p'))
endfunction

function! s:copy_passwd_to_clipboard(passwd_file) abort
	if !has('clipboard')
		echoerr 'No support for clipboard'
		return -2
	endif

  let l:p = v:lua.vim.fs.normalize(a:passwd_file)
	if empty(a:passwd_file) || empty(glob(l:p))
		echoerr 'Error locating input passwd_file: ' . l:p
		return -3
	endif

	let l:decrypt_cmd = 'gpg --decrypt ' . l:p

	let l:pass = systemlist(l:decrypt_cmd)

	if v:shell_error
		echoerr 'gpg command: ' . l:decrypt_cmd . ' failed'
		return -4
	endif

	" Copy only first line after User info. Should be passwd.
	let l:passwd = get(l:pass, 2, '')
	let @* = l:passwd
  let @+ = l:passwd
  let @" = l:passwd

	if !has('timers')
		echoerr 'Vim is missing the "timers" feature.' . "\n" .
					\ 'Cannot automagically clear the clipboard without this feature.' . "\n" .
					\	'!!!Please do it manually!!!'
		return -5
	endif

	echomsg 'Copied password: ' . a:passwd_file . ' to clipboard.'
				\ 'It will be cleared in ' . g:passwd_sec_on_clipboard . ' seconds'
	" TODO-[RM]-(Mon Aug 27 2018 16:35): Keep track of this timer.
	" If it is still active kill it and start a new one.
	" That way you fix the bug of multiple timers at the same time. 
	return timer_start(g:passwd_sec_on_clipboard*1000, funcref('s:clear_system_clipboard'))
endfunction

function! passwd#SelectPasswdFile() abort
	if !executable('gpg')
		echoerr 'Please install gpg'
		return -1
	endif

	if exists(':Denite')
		call setreg(v:register, '') " Clean up register
		" execute 'Denite -default-action=yank -path=' . g:passwd_store_dir . ' file_rec'
		execute 'Denite -default-action=yank -path=~/.password-store file_rec'
    let l:passwd_file = g:passwd_store_dir . s:splitter . getreg()
	else
    autocmd User TelescopeFindFilesYankPost ++once call passwd#OnTextYankPost()
    call v:lua.require'utils.utils'.fs.path.fuzzer_yank(g:passwd_store_dir)
    return
	endif

	if empty(l:passwd_file)
		return
	endif

	return s:copy_passwd_to_clipboard(l:passwd_file)
endfunction

function! passwd#AddPasswd() abort
	if !exists('g:passwd_store_dir') || empty(glob(g:passwd_store_dir))
		echoerr 'Passwords directory not defined'
		return
	endif

	if !executable('gpg')
		echoerr 'Please install gpg'
		return -1
	endif

	let l:rec = s:get_recipient()
	if empty(l:rec)
		echoerr 'Failed to get recipient from gpg-id file'
		return
	endif

	if &verbose > 0
		echomsg printf("[passwd#AddPasswd()]: rec = %s", l:rec)
	endif

	let l:new_pass_file = s:add_file(g:passwd_store_dir)
	if empty(l:new_pass_file)
		return
	endif

	if &verbose > 0
		echomsg printf("[passwd#AddPasswd()]: new_pass_file = %s", l:new_pass_file)
	endif

	if !empty(glob(l:new_pass_file))
		echoerr 'There is already a password file with that name'
		return
	endif

	let l:sugg = ''
	if has('nvim')
		let l:sugg = s:generate_random_pass(15)
	endif

	let l:new_pass = input('Please enter new password: ', l:sugg)
	if empty(l:new_pass)
		return
	endif

	let l:temp = tempname()
	let l:ret = writefile([l:new_pass], l:temp)
	if l:ret == -1
		return
	endif

	let l:cmd = 'gpg --encrypt ' .
				\ '--recipient "' .  l:rec . '"' .
				\ ' --output "' . l:new_pass_file . '" ' .
				\ '"' . l:temp . '"'

	if &verbose > 0
		echomsg printf("[passwd#AddPasswd()]: cmd = %s", l:cmd)
	endif

	cexpr system(l:cmd)

	let l:ret = delete(l:temp)
	if l:ret == -1
		echoerr 'Please manually DELETE file: ' . l:temp
	endif

	if v:shell_error
		echoerr 'Failed to create password'
		copen 20
		return
	endif

	return s:copy_passwd_to_clipboard(l:new_pass_file)
endfunction

function! s:clear_system_clipboard(timer) abort
	echomsg 'Clearing clibpboard'
	let @* = ''
  let @+ = ''
  let @" = ''
endfunction

function! s:add_file(path) abort
	if empty(a:path) || empty(glob(a:path))
		echoerr 'Input path doesnt exist'
		return
	endif

	let l:cwd = getcwd()
	execute 'lcd ' . a:path
	let l:new_file = input('Please enter name for new file:', '', 'file')

	if empty(l:new_file)
		return
	endif

	if l:new_file[0] !=# s:splitter
		let l:new_file = s:splitter . l:new_file
	endif

	let l:new_file = a:path . l:new_file
	if &verbose > 0
		echomsg printf('[add_file]: l:new_file = "%s"', l:new_file)
	endif

	" Find passed dir
	let l:last_folder = strridx(l:new_file, s:splitter)
	let l:new_folder = l:new_file[0:l:last_folder-1]
	if &verbose > 0
		echomsg printf('[wiki_add]: l:new_folder = "%s"', l:new_folder)
	endif

	if !isdirectory(l:new_folder)
		if &verbose > 0
			echomsg printf('[wiki_add]: Created new folder = "%s"', l:new_folder)
		endif
		call mkdir(l:new_folder, 'p')
	endif

	execute 'lcd ' . l:cwd
	return l:new_file
endfunction

function! s:rand(x,y) abort " random uniform between x and y
  return luaeval('(_A.y-_A.x)*math.random()+_A.x', {'x':a:x,'y':a:y})
endfunction

function! s:generate_random_pass(num_chars) abort
	" Create a loop until num_chars
	let l:pass = ''
	let l:idx = 1
	while (l:idx != a:num_chars)
		let l:pass .= nr2char(float2nr(s:rand(33,127)))
		let l:idx += 1
	endwhile
	return l:pass
endfunction

function! s:get_recipient() abort
	let l:rec_file = get(g:, 'passwd_store_dir', '') . '/.gpg-id'
	if empty(glob(l:rec_file))
		return ''
	endif

	let l:rec = readfile(l:rec_file)
	return get(l:rec, 0, '')
endfunction
