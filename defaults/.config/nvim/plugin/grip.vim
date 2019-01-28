" File:           grepper.vim
" Description:    Utility to grep files with different tools
" Author:		    Reinaldo Molina
" Email:          rmolin88 at gmail dot com
" Revision:	    0.0.0
" Created:        Thu Jun 28 2018 14:22
" Last Modified:  Thu Jun 28 2018 14:22

" TODO:
" - Status Line
" - Async Search  
" - More default greppers  

if exists('g:loaded_grip')
	finish
endif

let g:loaded_grip = 1

" filetype_map - grepper_ft : vim_ft
"							 - Ex: 'cpp' : '+'
"	filetype_option - Ex: '-t' for rg
"									- It will be followed up by the filetype_map.grepper_ft
" Default template
" let grips = {
			" \ 'executable' : '',
			" \ 'args' : ['$*'],
			" \ 'filetype_support' : 0,
			" \ 'filetype_map' : {  },
			" \ 'filetype_option' : '',
			" \ 'grepformat' : '',
			" \ 'async' : '',
			" \ }

let g:loaded_grip = 1

" Must set verbose to 1 as well for this to work
" let g:grip_debug_file = <your file>

let s:grip = {
			\ 'grips' : get(g:, 'grip_tools', []),
			\ 'debug_file' : get(g:, 'grip_debug_file', (tempname() . '_grip')),
			\ 'copen' : get(g:, 'grip_copen', 20),
			\ }

function! s:grip.main(...) abort
	if empty(self) || !has_key(self, 'grips') || len(self.grips) < 1
		echoerr 'Grip: No grips defined'
		return -1
	endif

	if &verbose > 0
		call self.put_debug_info('grip.main', string(self))
	endif

	if a:0 > 0
		return self.run_specific_grip(a:1)
	endif

	" TODO-[RM]-(Tue Aug 14 2018 06:40): Here call try_grepper with input 
	while 1
		for l:grepper in self.grips
			let l:rc = self.try_grepper(l:grepper)
			if l:rc != 0
				return l:rc
			endif
		endfor
	endwhile
endfunction

function! s:grip.put_debug_info(func_name, msg) abort
	if empty(a:func_name) || empty(a:msg)
		echoerr '[grip.put_debug_info]: Bad function input'
		return
	endif

	let l:deb = self.debug_file
	if !exists('self.debug_file')
		echoerr '[grip.put_debug_info]: self.debug_file doesnt exist'
		return -1
	endif

	" Cant figure this one out
	" if empty(glob(self.debug_file))
		" echoerr '[grip.put_debug_info]: Cannot find "self.debug_file": ' . self.debug_file
		" return -1
	" endif

	let l:ret = '[' . a:func_name . '-' . strftime("%a_%b_%d_%Y_%H_%M") . ']: ' . a:msg
	call writefile([ l:ret ], self.debug_file, 'a')
endfunction

let s:USER_CHOICE = {
			\ 'USE_FT_SEARCH' : 0,
			\ 'USE_CURR_WORD' : 0,
			\ }
function! s:grip.display_grip_ui(grepper) abort
	if empty(a:grepper)
		echoerr '[grip.display_grip_ui]: Bad function input'
		return -1
	endif

	if !has_key(a:grepper, 'executable')
		echoerr '[grip.display_grip_ui]: Grip is missing "executable" key'
		return -2
	endif

	if !executable(a:grepper.executable)
		if &verbose > 0
			echoerr '[grip.display_grip_ui]: This grepper is not executable. So im not going to even show it'
		endif
		" Skip it
		return 0
	endif

	let l:args = has_key(a:grepper, 'args') ? a:grepper.args : []
	let l:name = has_key(a:grepper, 'name') ? a:grepper.name : a:grepper.executable

	if &verbose > 0
		call self.put_debug_info('grip.display_grip_ui', string(a:grepper))
	endif

	let l:grepprg = a:grepper.executable
	for arg in l:args
		let l:grepprg .= ' ' . arg
	endfor

	let l:msg = printf("Grip: \"%s\"\n".
				\ "Search in folder: \"%s\"\n".
				\ "Using grepprg: \"%s\"\n".
				\ "Please choose one of the following options:",
				\ l:name, getcwd(), l:grepprg)
	let l:ft_sup = has_key(a:grepper, 'filetype_support') ? a:grepper.filetype_support : 0
	if l:ft_sup > 0
		"								1:ft_choice -				2:ft_choice
		let l:choice = "&J<cword>/". &ft . "\n&K<any>/". &ft . "\n&L<cword>/all_files\n&;<any>/all_files\n&Next Grip"
		let l:next = 5
	else
		let l:choice = "&J<cword>\n&K<any>\n&Next Grip"
		let l:next = 3
	endif

	let l:rc = confirm(l:msg, l:choice)
	if l:rc == l:next
		let l:ret = 0
	elseif l:rc < 1
		let l:ret = -3
	else
		let l:ret = l:rc
	endif

	return l:ret
endfunction

function! s:grip.execute_grip(grepper, user_choice) abort
	if empty(a:grepper) || empty(a:user_choice)
		echoerr '[grip.execute_grip]: Bad function input'
		return -1
	endif

	if !has_key(a:grepper, 'executable')
		echoerr '[grip.execute_grip]: Grip is missing "executable" key'
		return -2
	endif

	if !executable(a:grepper.executable)
		echoerr '[grip.execute_grip]: Grip "' . a:grepper.executable . '" is not executable'
		return -3
	endif

	call self.parse_user_choice(a:grepper, a:user_choice)

	if &verbose > 0
		call self.put_debug_info('grip.execute_grip', string(s:USER_CHOICE))
	endif

	let l:ft_args = []
	if s:USER_CHOICE.USE_FT_SEARCH == 1
		let l:ft_args = self.get_ft_args(a:grepper)

		if &verbose > 0
			call self.put_debug_info('grip.execute_grip', string(l:ft_args))
		endif

		if empty(l:ft_args)
			echoerr '[grip.execute_grip]: Failed to Get FileType Arguments'
			return -4
		endif
	endif

	if s:USER_CHOICE.USE_CURR_WORD == 1
		let l:search = expand('<cword>')
	else
		let l:search = input('Please enter search word:')
	endif

	if empty(l:search)
		if &verbose > 0
			call self.put_debug_info('grip.execute_grip', 'Empty search variable')
		endif
		return -5
	endif

	" Save current grepprg
	let l:grepprg = &grepprg
	let l:grepformat = &grepformat

	" Overwrite with new one
	if has_key(a:grepper, 'grepformat') && !empty(a:grepper.grepformat)
		let &grepformat = a:grepper.grepformat
	endif

	let &grepprg = a:grepper.executable
	if len(a:grepper.args) > 0
		for l:arg in a:grepper.args
			let &grepprg .= ' ' . l:arg
		endfor
	endif

	if len(l:ft_args) > 0
		for l:arg in l:ft_args
			let &grepprg .= ' ' . l:arg
		endfor
	endif

	" log it
	if &verbose > 0
		call self.put_debug_info('grip.execute_grip',
					\ printf('cmd = %s %s', &grepprg, l:search))
	endif

	" TODO-[RM]-(Fri Jun 29 2018 13:14): Mode this to its own dictionary
	" The bang tells it not to jump to the first 
	execute ':silent grep! ' . l:search

	" Open quickfix
	if self.copen > 0
		execute 'copen ' . self.copen
	endif

	" Restore options
	let &grepprg = l:grepprg
	let &grepformat = l:grepformat
	return 1
endfunction

" Places result in s:USER_CHOICE
function! s:grip.parse_user_choice(grepper, user_choice) abort
	" Lets start with FT Search
	let l:ft_sup = has_key(a:grepper, 'filetype_support') ? a:grepper.filetype_support : 0

	if l:ft_sup <= 0
		let s:USER_CHOICE.USE_FT_SEARCH = 0
	else
		if a:user_choice == 1 || a:user_choice == 2
			let s:USER_CHOICE.USE_FT_SEARCH = 1
		else
			let s:USER_CHOICE.USE_FT_SEARCH = 0
		endif
	endif

	" Now onto curr_word
	if l:ft_sup <= 0 && a:user_choice == 1
		let s:USER_CHOICE.USE_CURR_WORD = 1
	elseif l:ft_sup <= 0 && a:user_choice == 2
		let s:USER_CHOICE.USE_CURR_WORD = 0
	elseif l:ft_sup > 0 && a:user_choice == 1
		let s:USER_CHOICE.USE_CURR_WORD = 1
	elseif l:ft_sup > 0 && a:user_choice == 3
		let s:USER_CHOICE.USE_CURR_WORD = 1
	elseif l:ft_sup > 0 && a:user_choice == 2
		let s:USER_CHOICE.USE_CURR_WORD = 0
	elseif l:ft_sup > 0 && a:user_choice == 4
		let s:USER_CHOICE.USE_CURR_WORD = 0
	endif
endfunction

function! s:grip.get_ft_args(grepper) abort
	if !has_key(a:grepper, 'filetype_support') || a:grepper.filetype_support == 0
		return ['']
	endif

	return [
				\ (has_key(a:grepper, 'filetype_option') ? a:grepper.filetype_option : ''),
				\ (has_key(a:grepper, 'filetype_map') && has_key(a:grepper.filetype_map, &ft) ?
				\		a:grepper.filetype_map[&ft] : &ft),
				\ ]
endfunction

function! s:grip.try_grepper(grepper) abort
	let l:rc = self.display_grip_ui(a:grepper)

	if l:rc > 0
		" This is the one. Run it
		return self.execute_grip(a:grepper, l:rc)
	endif

	return l:rc
endfunction

" Returns list of names of all greppers
" Inputs are required but not used
function! CompleteGripNames(A, L, P) abort
	let l:names = []

	for l:grepper in s:grip.grips
		let l:name = has_key(l:grepper, 'name') ? l:grepper.name : l:grepper.executable

		let l:names += [l:name]
	endfor

	return l:names
endfunction

" Returns grepper prvided the name or executable.
function! s:grip.find_grip_by_name(name) abort
	if empty(a:name)
		return {}
	endif

	for l:grepper in self.grips
		let l:name = has_key(l:grepper, 'name') ? l:grepper.name : l:grepper.executable
		if a:name ==# l:name
			return l:grepper 
		endif
	endfor
	
	return {}
endfunction

function! s:grip.run_specific_grip(name) abort
	if empty(a:name)
		return -1
	endif
	
	let l:grepper = self.find_grip_by_name(a:name)
	if empty(l:grepper)
		return -2
	endif

	return self.try_grepper(l:grepper)
endfunction

command! -nargs=? -complete=customlist,CompleteGripNames Grip call s:grip.main(<f-args>)
" TODO-[RM]-(Tue Aug 14 2018 06:41):
" - Create more commands with the names of the greppers
" - Like Grip rg
