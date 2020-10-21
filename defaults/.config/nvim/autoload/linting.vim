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
		nnoremap <plug>make_project :NeomakeProject<cr>
		nnoremap <plug>make_file :Neomake<cr>
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

  let g:neomake_tempfile_dir = g:std_cache_path . '/neomake'
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
				\ 'cwd': '%:p:h'
				\ }

  let g:neomake_cmakelint_maker = {
        \ 'exe': 'cmakelint',
        \ 'cwd': '%:p:h',
        \ 'append_file' : 1,
        \ }
  let g:neomake_cmake_enabled_makers = ['cmakelint']

	let g:neomake_make_maker = {
				\ 'exe': 'make',
				\ 'cwd': '%:p:h',
				\ 'args': ['--build', '-j`nproc`'],
				\ 'append_file' : 0,
				\ 'errorformat': '%f:%l:%c: %m',
				\ }

  " Python linters. Pylint is slow but catches stuff pylama doesnt
  let g:neomake_python_enabled_makers = ['python', 'frosted', 'pylama', 'pylint']
  let g:neomake_python_pyling_args = [
        \ '--output-format=text',
        \ '--msg-template="{path}:{line}:{column}:{C}: [{symbol}] {msg} [{msg_id}]"',
        \ '--reports=no',
        \ '--jobs=0',
        \ ]

	"  Very usefull for when using CMake
	"  ----
	" -C build - means build inside build directory
	"  and build only the name of the current file (%:t:r)
	let g:neomake_make_unix_maker = {
				\ 'exe': 'make',
				\ 'args': ['-C', 'build', '-j`nproc`', '%:t:r'],
				\ 'append_file' : 0,
				\ 'errorformat': '%f:%l:%c: %m',
				\ }
	let g:neomake_ninja_unix_maker = {
				\ 'exe': 'ninja',
				\ 'args': ['-C', 'build'],
				\ 'append_file' : 0,
				\ 'errorformat': '%f:%l:%c: %m',
				\ }

	let g:neomake_msbuild_maker = {
				\ 'exe' : 'msbuild',
				\ 'cwd': '%:p:h',
				\ 'append_file' : 0,
				\ 'errorformat': '%f(%l): %t%*[^ ] C%n: %m [%.%#]',
				\ }

	let g:neomake_qpdfview_maker = {
				\ 'exe' : 'qpdfview',
				\ 'append_file' : 0,
				\ }

	" Fri Nov 03 2017 19:05: Finally understood the concept of neomake and linting 
	" in general. NeomakeFile is suppose to run as it names says in only a single 
	" file.  And that is what you should configure on a per buffer basis. Look at 
	" ftplugin/markdown.vim for a good example.
	" To make entire projects use NeomakeProject. The later by default and the way 
	" it should be uses makeprg. Therefore configure that to build your entire 
	" project, do it through setting compiler and compiler plugins. Such as 
	" borland. But run Neomake automatically. Having said this still use 
	" `<LocalLeader>m` to make entire projects, meaning to run your project 
	" builder.
	" Fri Nov 03 2017 19:20: For vim linting use: `pip install vim-vint --user`
	let g:neomake_plantuml_enabled_makers = ['plantuml']

	" java setup
	" install maven checkstyle uncrustify gradle
	" for gradle make sure that the `gradlew` script in your project is executable
	let g:neomake_java_checkstyle_xml =
				\ g:std_config_path . '/java_checkstyle_SWENG861.xml'
	" Sun Dec 09 2018 19:18:
	" Not necessary. neomake picks it up automatically
	" let g:neomake_java_checkstyle_executable = 'checkstyle'
	" let g:neomake_java_maven_executable = 'mvn'

  " Too much logging. Only enable when needed
	" let g:neomake_logfile = g:std_cache_path . '/neomake.log'
	let s:msg = ''
	augroup custom_neomake
		autocmd!
		autocmd User NeomakeFinished call s:neomake_finished()
		autocmd User NeomakeJobFinished call s:neomake_job_finished()
		" Thu Nov 09 2017 10:17: Not needed when using neomake native statusline 
		" function
		" autocmd User NeomakeJobStarted call utils#NeomakeJobStartd()
	augroup END

	if exists('g:lightline')
		let g:lightline.active.right[2] += [ 'neomake' ]
		let g:lightline.component_function['neomake'] =
					\ string(function('s:neomake_native_status_line'))
		" let g:lightline.component_function['neomake'] = 
		" 'lightline_neomake#component'
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

function! s:neomake_native_status_line() abort
  " Check if neomake is disabled
  let disabled = get(b:, 'neomake', {})
  if !empty(disabled) && get(disabled, 'disabled', 0)
    return ''
  end

	return neomake#statusline#get(
				\ exists('g:actual_curbuf') ? g:actual_curbuf : bufnr("%"),
				\ {'format_running': (exists('g:valid_device') ? "\uf188" : '') .
				\ ' {{running_job_names}} ' .
				\ (exists('g:valid_device') ? "\uf0e4" : ''),
				\ 'format_quickfix_issues':
				\ (exists('g:valid_device') ? "\uf188" : '') . ' qf:%s',
				\ 'format_quickfix_ok': '',
				\ 'format_quickfix_type_E':
				\ (exists('g:valid_device') ? " \uf057" : '{{type}}') . ':{{count}} ',
				\ 'format_quickfix_type_W':
				\ (exists('g:valid_device') ? " \uf071" : '{{type}}') . ':{{count}} ',
				\ 'format_quickfix_type_I':
				\ (exists('g:valid_device') ? " \uf449" : '{{type}}') . ':{{count}} ',
				\ 'format_loclist_issues':
				\ (exists('g:valid_device') ? "\uf188" : ''). ' loc:%s',
				\ 'format_loclist_type_E':
				\ (exists('g:valid_device') ? " \uf188" : '{{type}}') . ':{{count}} ',
				\ 'format_loclist_type_W':
				\ (exists('g:valid_device') ? " \uf071" : '{{type}}') . ':{{count}} ',
				\ 'format_loclist_type_I':
				\ (exists('g:valid_device') ? " \uf449" : '{{type}}') . ':{{count}} ',
				\ 'format_loclist_ok':
				\ (exists('g:valid_device') ? "\uf188" : '').
				\ ' loc: ' . (exists('g:valid_device') ? "\uf058" : 'ok'),
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

" type - {pdf, docx}
" If you want to change the template use b:neomake_pandoc_template for that
" I.e: `let b:neomake_pandoc_template = 'eisvogel'`
" That above is the default
" If you want to pass extra args use:
" `let b:neomake_pandoc_extra_args = ['--number-sections']`
" Or:
" `let b:neomake_pandoc_extra_args = ['--listings']`
" Or:
" `let b:neomake_pandoc_extra_args = ['--number-sections', '--toc']`
" And then call the function again
function! linting#SetNeomakePandocMaker(type) abort
	if !executable('pandoc')
		if !exists('g:portable_vim')
			echomsg '[linting#SetNeomakePandocMaker]: Pandoc is not executable'
		endif
		return -1
	endif

  " A Makefile present in the current file folder takes precedence over all
	if !empty(glob(expand('%:p:h') . '/Makefile'))
		let b:neomake_markdown_enabled_makers = ['make']
		return
	endif

	" By default, pandoc produces a document fragment. To produce a standalone document (e.g. a valid
	" HTML file including <head> and <body>), use the -s or --standalone flag:
	" Listing is used to produce code snippets
	let l:argu = [
				\ '--from', 'markdown+simple_tables+table_captions+yaml_metadata_block+smart+citations',
				\ '--standalone',
				\ '--number-sections',
				\ '--listings',
				\ ]
  " No need for this setting. '-V', 'geometry:margin=.5in'
	" It can be added as part of the YAML header

	if executable('pandoc-citeproc')
		" Obtain list of bib files
		" Read pandoc manual about citations. Can be added to yaml header.
		" let l:bibl = glob(expand('%:p:h') . '/*.bib', 0, 1)
		" if !empty(l:bibl)
			let l:argu += ['--filter',
						\ 'pandoc-citeproc',
						\	]
		" endif
	endif

	if a:type ==# 'pdf'
		" Set template
		if !has('unix')
			let l:cc = substitute(g:std_cache_path, "[\\/]", '\\\\', 'g') . '\\\\'
			let l:argu += [
						\ '--pdf-engine-opt', '-aux-directory=' . l:cc
						\ ]
		endif
		" '--number-sections', '--listings',
		let l:argu += [
					\ '--template', (!exists('b:neomake_pandoc_template') ? 'eisvogel' : b:neomake_pandoc_template),
					\ '--write', 'latex', '--output', '%:t:r.pdf', '%:t'
					\ ]
	elseif a:type ==# 'docx'
		" let l:wrte = 'docx'
		" let l:out = '%:r.docx'
		let l:argu += ['--write', 'docx', '--output', '%:t:r.docx', '%:t']
	elseif a:type ==# 'html'
		" let l:wrte = 'html'
		" let l:out = '%:r.html'
		let l:argu += ['--write', 'html', '--output', '%:t:r.html', '%:t']
	elseif a:type ==# 'pdf_slides'
		" let l:wrte = 'pdf'
		" let l:out = '%:r.pdf'
		let l:argu = [ '--write', 'beamer', '--output', '%:t:r.pdf', '%:t']
	elseif a:type ==# 'pptx_slides'
		" let l:wrte = 'pptx'
		" let l:out = '%:r.pptx'
		let l:argu = [ '--write', 'pptx', '--output', '%:t:r.pptx', '%:t']
	else
		if &verbose > 0
			echomsg '[linting#SetNeomakePandocMaker]: Not a recognized a:type variable'
		endif
		return -2
	endif

	if exists('b:neomake_pandoc_extra_args') && !empty(b:neomake_pandoc_extra_args)
		let l:argu += b:neomake_pandoc_extra_args
	endif

	" Setup neomake variables
	if &verbose > 0
		echomsg '[linting#SetNeomakePandocMaker]: l:argu = ' . string(l:argu)
	endif

	let l:maker = 'pandoc_' . a:type
	let b:neomake_{l:maker}_maker = {
				\ 'exe': 'pandoc',
				\ 'args': l:argu,
				\ 'append_file' : 0,
				\ 'cwd': '%:p:h'
				\ }

  " Too fancy to enable multiple markdown makers. Just enable this one and call it the
	" day. If you want others just call on them
	let b:neomake_markdown_enabled_makers = [l:maker]
endfunction

function! linting#SetNeomakePdfLatex() abort
	let &l:makeprg='pdflatex -interaction=nonstopmode'
endfunction

function! linting#SetNeomakeXeLatex() abort
	let &l:makeprg='xelatex'
endfunction

function! linting#SetNeomakeMakeMaker() abort
	if !exists('b:neomake_cpp_enabled_makers')
		let b:neomake_cpp_enabled_makers = []
	endif

	" Run make inside the build folder
	let &l:makeprg='make -C build -j`nproc`'
	let b:neomake_cpp_enabled_makers += ['make_unix']
endfunction

function! linting#SetNeomakeNinjaMaker() abort
	if !exists('b:neomake_cpp_enabled_makers')
		let b:neomake_cpp_enabled_makers = []
	endif

	" Run make inside the build folder
	let &l:makeprg='ninja -C build'
	let b:neomake_cpp_enabled_makers += ['ninja_unix']
endfunction

function! linting#SetNeomakeClangMaker() abort
	if !exists('b:neomake_cpp_enabled_makers')
		let b:neomake_cpp_enabled_makers = []
	endif

	let b:neomake_cpp_enabled_makers +=
				\ executable('clang') ? ['clangtidy', 'clangcheck'] : []
	let b:neomake_cpp_enabled_makers += executable('cppcheck') ? ['cppcheck'] : []
	let b:neomake_cpp_enabled_makers += executable('cpplint') ? ['cpplint'] : []
	let b:neomake_cppcheck_args = '--quiet --language=c++ --enable=all'
	let b:neomake_clangtidy_args = ["-checks='*'", '%:p']
	let b:neomake_clangcheck_args = ['-analyze', '%:p']
	if has('win32') && executable('clang')
		" Tue Aug 21 2018 15:12 
		" clang-cl is the frontend that uses MSVC cl-like arguments
		" https://clang.llvm.org/docs/UsersManual.html#clang-cl
		" /GX Enable exceptions
		let b:neomake_cpp_enabled_makers += ['clang']
		let b:neomake_clang_args = '-Wall -Wextra /std:c++17 /GX'
		let b:neomake_clang_exe = 'clang-cl'
		let b:neomake_clang_cwd = '%:p:h'
	endif
endfunction

function! linting#SetNeomakeBorlandMaker() abort
	command! -buffer UtilsUpdateBorlandMakefile call utils#UpdateBorlandMakefile()
	augroup Borland
		autocmd! * <buffer>
		autocmd BufWritePre <buffer> call utils#UpdateBorlandMakefile()
	augroup end

	" Settings for NeoamkeProject
	let b:current_compiler = "borland"
	" let prog = C:\Program Files (x86)\Borland\CBuilder6\Bin\make.exe
	let prog ='make'
	let &l:makeprg=prog
	setlocal errorformat=%*[^0-9]\ %t%n\ %f\ %l:\ %m

	" For Borland use only make
	let b:neomake_cpp_enabled_makers = ['make']
	let b:neomake_make_args = ['%:r.obj']
	let b:neomake_make_errorformat = &errorformat
endfunction

function! linting#SetNeomakeMsBuildMaker() abort
	compiler msbuild
	let l:ms = 'msbuild'
	let l:ms_switches = '/nologo /v:q /maxcpucount /target:Build'
	let &l:makeprg= l:ms . ' ' . l:ms_switches
	let &l:errorformat='%f(%l): %t%*[^ ] C%n: %m [%.%#]'

	" Wed Apr 04 2018 11:10: Alternative errorformat found somewhere:
	" \ 'errorformat': '%E%f(%l\,%c): error CS%n: %m [%.%#],'.
	" \                '%W%f(%l\,%c): warning CS%n: %m [%.%#]',

	" Compose VS project name base on the root folder of the current file
	let l:proj_name = glob(expand('%:p:h') . '/*.vcxproj')
	if empty(l:proj_name)
		return
	endif

	" MSbuild does this automagically
	" let response_file = glob(expand('%:p:h') . '/*.rsp')

	" Fix make_program
	" /m uses all available cores for build
	let &l:makeprg= l:ms . ' ' . l:proj_name . ' ' . l:ms_switches

	let b:neomake_cpp_enabled_makers = ['msbuild']

			" \ '/property:GenerateFullPaths=true',
	let b:neomake_cpp_msbuild_args = [
				\ l:proj_name,
				\ '/target:ClCompile',
				\ '/nologo',
				\ '/verbosity:quiet',
				\ '/property:SelectedFiles=%']
endfunction
