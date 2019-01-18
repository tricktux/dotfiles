" File:           sessions.vim
" Description:    Plugin to handle saving and loading sessions
" Author:		    Reinaldo Molina
" Email:          rmolin88 at gmail dot com
" Revision:	    0.0.0
" Created:        Thu Jan 17 2019 10:39
" Last Modified:  Thu Jan 17 2019 10:39


if exists('g:loaded_sessions')
	finish
endif

let g:loaded_sessions = 1

let g:sessions_path = ''

" let g:sessions_load_function = string(function('utils#DeniteYank', g:sessions_path))

let s:sessions = {
			\ 'path' : get(g:, 'sessions_path', ''),
			\ 'current' : get(g:, 'sessions_current_name', ''),
			\ 'overwrite' : get(g:, 'sessions_overwrite', 0),
			\ 'load_function' : get(g:, 'sessions_load_function', ''),
			\ 'default_name' : get(g:, 'sessions_default_name', ''),
			\ 'auto_save' : get(g:, 'sessions_auto_save', ''),
			\ 'debug_file' : get(g:, 'sessions_debug_file', ''),
			\ }

" If empty session it will use the value of default_name
function! s:sessions.save(session) abort
	" Validate path and name
	if (empty(glob(self.path)))
		echoerr printf("sessions: Invalid or missing 'g:sessions_path' variable: '%s'", self.path)
		return -1
	endif

	" Sanitize self.path. Ensure ending in /
	
endfunction

