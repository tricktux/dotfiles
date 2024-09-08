
let g:flux_daytime_start = 6
let g:flux_daytime_end = 20

" Define a global variable to hold the file location
let g:flux_file_location = '/tmp/flux'

" List of valid periods
let g:flux_periods = ['daytime', 'night', 'transition']

" Function to determine the period based on the current time
function! s:get_period_by_time() abort
  let l:hour = strftime("%H")  " Get current hour in 24-hour format
  let l:day_start = g:flux_day_time_start
  let l:day_end = g:flux_day_time_end

  if l:hour >= l:day_start && l:hour < l:day_end
    return 'daytime'
  endif
  return 'night'
endfunction

" Function to check and set the correct period
function! flux#Check() abort
  let l:period = readfile(g:flux_file_location)

  if empty(l:period)
    " Manually set period based on time if file is empty
    return s:get_period_by_time()
  endif

  return l:period[0] " Return the first line as the period
endfunction
