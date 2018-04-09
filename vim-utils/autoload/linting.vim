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
		nnoremap <Plug>MakeProject :NeomakeProject<cr>
		nnoremap <Plug>MakeFile :Neomake<cr>
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
	let g:neomake_error_sign = {'text': "\uf057", 'texthl': 'ErrorMsg'}
	let g:neomake_warning_sign = {
				\   'text': "\uf071",
				\   'texthl': 'WarningMsg',
				\ }
	let g:neomake_info_sign = {'text': "\uf449", 'texthl': 'NeomakeInfoSign'}

	let g:neomake_plantuml_maker = {
				\ 'exe': 'plantuml',
				\ 'errorformat': '%EError line %l in file: %f,%Z%m',
				\ }
	let g:neomake_makeborland_maker = {
				\ 'exe' : 'make',
				\ 'args' : ['%:r.obj'],
				\ 'append_file' : 0,
				\ }

	let g:neomake_makepandoc_maker = {
				\ 'exe' : 'make',
				\ 'args' : ['%:r.pdf'],
				\ 'append_file' : 0,
				\ }

	let g:neomake_cpp_msbuild_maker = {
				\ 'exe' : 'msbuild',
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
	let g:neomake_markdown_enabled_makers = ['makepandoc']
	let g:neomake_plantuml_enabled_makers = ['plantuml']

	augroup custom_neomake
		autocmd User NeomakeJobFinished call utils#NeomakeJobFinished()
		" Thu Nov 09 2017 10:17: Not needed when using neomake native statusline function
		" autocmd User NeomakeJobStarted call utils#NeomakeJobStartd()
	augroup END
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

		" call ale#linter#Define(filetype, linter)
		" let linter = {  }
		" call ale#linter#Define('cpp', linter)
endfunction
