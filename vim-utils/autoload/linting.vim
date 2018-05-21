" File:           liniting.vim
" Description:    Choose tool to automagically make your code
" Author:		    Reinaldo Molina
" Email:          rmolin88 at gmail dot com
" Revision:	    0.0.0
" Created:        Wed Feb 07 2018 15:25
" Last Modified:  Wed Feb 07 2018 15:25

" Choices are neomake, and ale
function! linting#Set(choice) abort
	if !has('nvim') && v:version < 800
		echoerr 'Async Linting depends on nvim or vim8'
		return
	endif

	if a:choice ==# 'neomake'
		nnoremap <Plug>make_project :NeomakeProject<cr>
		nnoremap <Plug>make_file :Neomake<cr>
		call s:set_neomake()
	elseif a:choice ==# 'ale'
		call s:set_ale()
	endif
endfunction

function! s:set_neomake() abort
	" Plugins for All (nvim, linux, win32)
	Plug 'neomake/neomake'
	" Fri Oct 27 2017 14:39: neomake defaults are actually pretty amazing. If
	" you need to change it. Do it on a per buffer basis. Look on c.vim for
	" example
	let g:neomake_error_sign = {'text':
				\ (exists('g:valid_device') ? "\uf057" : 'X'),
				\ 'texthl': 'ErrorMsg'}
	let g:neomake_warning_sign = {
				\   'text':
				\ (exists('g:valid_device') ? "\uf071" : 'W'),
				\   'texthl': 'WarningMsg',
				\ }
	let g:neomake_info_sign = {'text':
				\ (exists('g:valid_device') ? "\uf449" : 'I'),
				\ 'texthl': 'NeomakeInfoSign'}

	let g:neomake_plantuml_maker = {
				\ 'exe': 'plantuml',
				\ 'errorformat': '%EError line %l in file: %f,%Z%m',
				\ }

	let g:neomake_make_maker = {
				\ 'exe': 'make',
				\ 'args': ['--build'],
				\ 'errorformat': '%f:%l:%c: %m',
				\ }

	let g:neomake_msbuild_maker = {
				\ 'exe' : 'msbuild',
				\ 'append_file' : 0,
				\ }

	let g:neomake_qpdfview_maker = {
				\ 'exe' : 'qpdfview',
				\ 'append_file' : 0,
				\ }

	" Fri Nov 03 2017 19:05: Finally understood the concept of neomake and linting in
	" general. NeomakeFile is suppose to run as it names says in only a single file.
	" And that is what you should configure on a per buffer basis. Look at
	" ftplugin/markdown.vim for a good example.
	" To make entire projects use NeomakeProject. The later by default and the way it should
	" be uses makeprg. Therefore configure that to build your entire project, do it
	" through setting compiler and compiler plugins. Such as borland. But run
	" Neomake automatically. Having said this still use `<LocalLeader>m` to make entire
	" projects, meaning to run your project builder.
	" Fri Nov 03 2017 19:20: For vim linting use: `pip install vim-vint --user`
	let g:neomake_plantuml_enabled_makers = ['plantuml']

	let g:neomake_logfile = g:std_cache_path . '/neomake.log'
	let s:msg = ''
	augroup custom_neomake
		autocmd!
		autocmd User NeomakeFinished call s:neomake_finished()
		autocmd User NeomakeJobFinished call s:neomake_job_finished()
		" Thu Nov 09 2017 10:17: Not needed when using neomake native statusline function
		" autocmd User NeomakeJobStarted call utils#NeomakeJobStartd()
	augroup END

	if exists('g:lightline')
		let g:lightline.active.left[2] += [ 'neomake' ]
		let g:lightline.component_function['neomake'] = 'linting#NeomakeNativeStatusLine'
		" let g:lightline.component_function['neomake'] = 'lightline_neomake#component'
		" let g:lightline.component_type['neomake'] = 'error'
	endif
endfunction

function! s:neomake_finished() abort
	echomsg s:msg
	let s:msg = ''
endfunction

function! s:neomake_job_finished() abort
	if !exists('g:neomake_hook_context.jobinfo')
		return -1
	endif

	let m = g:neomake_hook_context.jobinfo
	let s:msg .= printf("%s: %d ", m.maker.name, m.exit_code)
endfunction

function! linting#NeomakeNativeStatusLine() abort
	return neomake#statusline#get(bufnr("%"), {
				\ 'format_running':
				\ (exists('g:valid_device') ? "\uf188" : '')
				\ .' {{running_job_names}} ' .
				\ (exists('g:valid_device') ? "\uf0e4" : ''),
				\ 'format_quickfix_issues':
				\ (exists('g:valid_device') ? "\uf188" : '') .' qf:%s',
				\ 'format_quickfix_type_E': ' {{type}}:{{count}}',
				\ 'format_quickfix_type_W': ' {{type}}:{{count}}',
				\ 'format_quickfix_type_I': ' {{type}}:{{count}}',
				\ 'format_loclist_issues':
				\ (exists('g:valid_device') ? "\uf188" : '')
				\ .' loc:%s',
				\ 'format_loclist_type_E': ' {{type}}:{{count}}',
				\ 'format_loclist_type_W': ' {{type}}:{{count}}',
				\ 'format_loclist_type_I': ' {{type}}:{{count}}',
				\ 'format_loclist_ok':
				\ (exists('g:valid_device') ? "\uf188" : '')
				\ .' loc: ✓',
				\ 'format_quickfix_ok': '',
				\ 'format_loclist_unknown': '',
				\ })
endfunction

function! linting#CheckNeomakeStatus() abort
	return exists('g:neomake_lightline') ? g:neomake_lightline : ''
endfunction

function! s:set_ale() abort
	" Main with ale is that is a "as you type" linter
	Plug 'maximbaz/lightline-ale'
		let g:lightline#ale#indicator_warnings = "\uf071"
		let g:lightline#ale#indicator_errors = "\uf05e"
		let g:lightline#ale#indicator_ok = "\uf00c"
	Plug 'w0rp/ale'
		let g:ale_lint_on_text_changed = 'never'
		let g:ale_lint_on_enter = 0
		let g:ale_lint_on_filetype_changed = 0

		let g:lightline.component_expand = {
					\  'linter_warnings': 'lightline#ale#warnings',
					\  'linter_errors': 'lightline#ale#errors',
					\  'linter_ok': 'lightline#ale#ok',
					\ }
		let g:lightline.component_type = {
					\     'linter_warnings': 'warning',
					\     'linter_errors': 'error',
					\     'linter_ok': 'left',
					\ }
		call insert(g:lightline.active.right[0], 'linter_errors')
		call insert(g:lightline.active.right[0], 'linter_warnings')
		call insert(g:lightline.active.right[0], 'linter_ok' )
		" call ale#linter#Define(filetype, linter)
		" let linter = {  }
		" call ale#linter#Define('cpp', linter)
endfunction
