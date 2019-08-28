
" Change vim colorscheme depending on time of the day
function! flux#Flux() abort
	if get(g:, 'flux_enabled', 1) == 0
		return
	endif

	if !exists('g:colorscheme_night_time') || !exists('g:colorscheme_day_time')
		if &verbose > 1
			echoerr 'Variables not set properly'
		endif
		return
	endif

	if strftime("%H") >= g:colorscheme_night_time || strftime("%H") < g:colorscheme_day_time
		" Its night time
		if	&background !=# 'dark' ||
					\ !exists('g:colors_name') ||
					\ g:colors_name !=# g:colorscheme_night
			call flux#ChangeColors(g:colorscheme_night, 'dark')
		endif
	else
		" Its day time
		if !exists('g:colors_name')
			let g:colors_name = g:colorscheme_day
		endif
		if &background !=# 'light' ||
					\ !exists('g:colors_name') ||
					\ g:colors_name !=# g:colorscheme_day
			call flux#ChangeColors(g:colorscheme_day, 'light')
		endif
	endif
endfunction

function! flux#ChangeColors(scheme, background) abort
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

