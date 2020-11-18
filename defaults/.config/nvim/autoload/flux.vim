" File:           flux.vim
" Description:    Automatically set colorscheme and background depending on time
" Author:		    Reinaldo Molina
" Email:          rmolin88 at gmail dot com
" Revision:	    1.0.0
" Created:        Tue Aug 27 2019 23:20
" Last Modified:  Tue Aug 27 2019 23:20

" TODO 
"  check for filereadable(s:api_res_path) every time flux() is called
let s:api_response_file_name = 'api_response_' . strftime('%m%d%Y') . '.json'
let s:api_res_path = g:std_cache_path . '/' . s:api_response_file_name
let s:api_url = 'https://api.sunrise-sunset.org/json?lat={}&lng={}'
let s:flux_times = {}
" async curl request


let s:async_curl = {}
function! s:async_curl.on_event(job_id, data, event) abort
	if a:event == 'stdout'
		let str = ' stdout: '.join(a:data)
	elseif a:event == 'stderr'
		let str = ' stderr: '.join(a:data)
	else
		let str = 'exited'
	endif

	echomsg str 
endfunction

let s:async_curl = {
			\ 'jobid': 0,
			\ 'callbacks' : { 
			\ 'on_stdout': function(s:async_curl.on_event), 
			\ 'on_stderr': function(s:async_curl.on_event),
			\ 'on_exit': function(s:async_curl.on_event)
			\ },
			\ 'cmd': 'curl -kfL --create-dirs -o ',
			\ }
" let s:async_curl.callbacks = {
" \ 'on_stdout': function(s:async_curl.on_event),
" \ 'on_stderr': function(s:async_curl.on_event),
" \ 'on_exit': function(s:async_curl.on_event)
" \ }
function! s:async_curl.start(file_name, link) abort
	if !executable('curl')
		if &verbose > 0
			echoerr 'Curl is not installed. Cannot proceed'
		endif
		return -1
	endif

	if empty(a:file_name) || empty(a:link)
		if &verbose > 0
			echoerr 'Please specify a path and link to download'
		endif
		return -2
	endif

	" silent execute "!curl -kfLo " . a:file_name . " --create-dirs \"" .
	" \ a:link . "\""
	let l:cmd = self.cmd . a:file_name . " \"" . a:link . "\""
	" Callbacks are not adding any value
	if has('nvim')
		let self.jobid = jobstart(l:cmd)
	else
		call job_start(l:cmd)
		let self.jobid = 1
	endif

	return self.jobid
endfunction


" Change vim colorscheme depending on time of the day
function! flux#Flux() abort
	if get(g:, 'flux_enabled', 0) == 0
		return
	endif

	if empty(s:flux_times)
		let s:flux_times = s:get_api_response_file()

		if empty(s:flux_times)
			let s:flux_times = { 'day':  g:flux_day_time, 'night' : g:flux_night_time}
		endif
	endif

	if !exists('g:flux_day_colorscheme') || !exists('g:flux_night_colorscheme')
		if &verbose > 0
			echoerr 'Variables not set properly'
		endif
		return
	endif

	let l:curr_time = str2nr(strftime("%H%M"))
	if &verbose > 0
		echomsg '[flux#Flux()]: day time = ' . string(s:flux_times['day'])
		echomsg '[flux#Flux()]: night time = ' . string(s:flux_times['night'])
		echomsg '[flux#Flux()]: current time = ' . string(l:curr_time)
	endif

	if l:curr_time >= s:flux_times['night'] ||
				\ l:curr_time < s:flux_times['day']
		" Its night time
		if &verbose > 0
			echomsg '[flux#Flux()]: its night time'
		endif
		if	&background !=# 'dark' ||
					\ !exists('g:colors_name') ||
					\ g:colors_name !=# g:flux_night_colorscheme
			if &verbose > 0
				echomsg '[flux#Flux()]: changing colorscheme to dark'
			endif
			call <sid>change_colors(g:flux_night_colorscheme, 'dark')
		endif
	else
		" Its day time
		if !exists('g:colors_name')
			let g:colors_name = g:flux_day_colorscheme
		endif
		if &verbose > 0
			echomsg '[flux#Flux()]: its day time'
		endif
		if &background !=# 'light' ||
					\ !exists('g:colors_name') ||
					\ g:colors_name !=# g:flux_day_colorscheme
			if &verbose > 0
				echomsg '[flux#Flux()]: changing colorscheme to light'
			endif
			call <sid>change_colors(g:flux_day_colorscheme, 'light')
		endif
	endif
endfunction

function! s:change_colors(scheme, background) abort
	if !exists('g:black')
		if &verbose > 1
			echoerr 'Colors do not exist'
		endif
	endif

	if a:background ==# 'dark'
		let color = g:black
	elseif a:background ==# 'light'
		let color = g:white
	else
		echoerr 'Only possible backgrounds are dark and light'
		return
	endif

	try
		execute "colorscheme " . a:scheme
	catch
		if &verbose > 1
			echoerr 'Failed to set colorscheme'
		endif
		return
	endtry

	let &background=a:background
	" Restoring these after colorscheme. Because some of them affect by the colorscheme
	" call highlight#SetAll('IncSearch',	{ 'bg': color })
	" call highlight#SetAll('IncSearch',	{ 'fg': 0, 'bg' : 9,  })
	" call highlight#SetAll('Search', { 'fg' : g:yellow, 'deco' : 'bold', 'bg' : g:turquoise4 })
	" Tue Jun 26 2018 14:00: Italics fonts on neovim-qt on windows look bad
	if has('unix') || has('gui_running')
		call highlight#Set('Comment', { 'deco' : 'italic' })
	endif

	" If using the lightline plugin then update that as well
	" this could cause trouble if lightline does not that colorscheme
	call status_line#UpdateColorscheme()
endfunction

" Returns dictionary:
"		day: strftime('%H%M')
"		night: strftime('%H%M')
function! s:get_api_response_file() abort
	let l:url = substitute(s:api_url, '{}', string(g:flux_api_lat), '')
	" echomsg 'url = ' l:url
	let l:url = substitute(l:url, '{}', string(g:flux_api_lon), '')
	" echomsg 'url = ' l:url

	if !filereadable(s:api_res_path)
		if s:async_curl.start(s:api_res_path, l:url) < 1
			if &verbose > 0
				echoerr 'Failed to make api request'
			endif
			return
		endif
		" Give curl time to download the file
		sleep 500m
	endif

	if !filereadable(s:api_res_path)
		if &verbose > 0
			echoerr 'API response file does not exists'
		endif
		return
	endif

	let l:sunrise = s:get_sunrise_times('sunrise')
	if l:sunrise < 1
		return
	endif

	let l:sunset = s:get_sunset_times('sunset')
	if l:sunset < 1
		return
	endif

	return { 'day': l:sunrise, 'night': l:sunset }
endfunction

function! s:get_sunset_times(time) abort
	let l:content = readfile(s:api_res_path, '', 1)[0]
	" echomsg 'content = ' l:content
	let l:sunrise_idx = stridx(l:content, a:time)
	if (l:sunrise_idx < 0)
		if &verbose > 0
			echoerr 'Failed to find ' . a:time  . ' time in api response'
		endif
		return -1
	endif

	" Time is given in UTC. Subs 4 to get ETC plus 12 to convert to military
	let l:t = strpart(l:content, l:sunrise_idx + 9, 2)
  " echomsg 't = ' l:t
	let l:time = (str2nr(l:t) + 12 - 5) * 100
  " echomsg 'time = ' l:time
	let l:t = strpart(l:content, l:sunrise_idx + 12, 2)
  " echomsg 't = ' l:t
	let l:time += str2nr(l:t)
  " echomsg 'time = ' l:time

	return str2nr(l:time)
endfunction

function! s:get_sunrise_times(time) abort
	let l:content = readfile(s:api_res_path, '', 1)[0]
	" echomsg 'content = ' l:content
	let l:sunrise_idx = stridx(l:content, a:time)
	if (l:sunrise_idx < 0)
		if &verbose > 0
			echoerr 'Failed to find ' . a:time  . ' time in api response'
		endif
		return -1
	endif

	" Time is given in UTC. Subs 4 to get ETC
	let l:t = strpart(l:content, l:sunrise_idx + 10, 2)
  " echomsg 't = ' l:t
	let l:time = (str2nr(l:t) - 5) * 100
  " echomsg 'time = ' l:time
	let l:t = strpart(l:content, l:sunrise_idx + 13, 2)
  " echomsg 't = ' l:t
	let l:time += str2nr(l:t)
  " echomsg 'time = ' l:time
	
	return str2nr(l:time)
endfunction

function! flux#GetTimes() abort
	echomsg string(s:flux_times)
endfunction
