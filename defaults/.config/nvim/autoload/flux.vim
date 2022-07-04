" File:           flux.vim
" Description:    Automatically set colorscheme and background depending on time
" Author:		    Reinaldo Molina
" Email:          rmolin88 at gmail dot com
" Revision:	    1.0.0
" Created:        Tue Aug 27 2019 23:20
" Last Modified:  Tue Aug 27 2019 23:20

let s:api_response_file_name = 'sunrise-sunset_response_' . strftime('%m%d%Y') . '.json'
let s:api_res_path = stdpath('cache') . '/' . s:api_response_file_name
let s:api_url = 'https://api.sunrise-sunset.org/json?lat={}&lng={}'
let s:flux_times = {}
let s:day_time_handled = 0
let s:night_time_handled = 0


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

    if s:night_time_handled == 1
      return
    endif

    lua require("plugin.flux"):set('night')
    let s:night_time_handled = 1
    let s:day_time_handled = 0
    return
  endif

  " Its day time
  if s:day_time_handled == 1
    return
  endif

  lua require("plugin.flux"):set('day')
  let s:day_time_handled = 1
  let s:night_time_handled = 0
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
    silent execute "!curl --create-dirs -kfL -o " . s:api_res_path . " \"" . l:url . "\""
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
