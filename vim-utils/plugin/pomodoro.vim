" File:					pomodoro.vim
" Description:			self explained
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:				0.0.0
" Last Modified: Sep 23 2017 00:30
" Created: Sep 23 2017 00:30


function! s:handler(job_id, data, event_type)
	echomsg 'Pomodoro is done'
endfunction

let g:pomodoro_time_work = 10

if has('win32') || has('win64')
	let argv = ['cmd', '/c', 'dir c:\ /b']
else
	let argv = ['bash', '-c', 'sleep ' . g:pomodoro_time_work ]
endif

let jobid = async#job#start(argv, {
			\ 'on_exit': function('s:handler'),
			\ })

" if jobid > 0
	" echom 'job started'
" else
	" echom 'job failed to start'
" endif
