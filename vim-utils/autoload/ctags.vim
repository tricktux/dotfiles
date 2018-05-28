" File:ctags.vim
"	Description: All functions related to creation/deletion/update/loading of ctags and cscope
" Author:Reinaldo Molina <rmolin88@gmail.com>
" Version:1.0.0
" Last Modified: Thu May 25 2017 08:39
" Created: Sat Apr 01 2017 17:04

if !exists('g:ctags_use_spell_for')
	let g:ctags_use_spell_for = ['c', 'cpp']
endif

if !exists('g:ctags_use_cscope_for')
	let g:ctags_use_cscope_for = ['c', 'cpp', 'java']
endif

"	Your current directory should be at the root of you code
" TODO-[RM]-(Fri May 18 2018 09:16):
" - Get rid of lcd
" -
function! ctags#NvimSyncCtags() abort
	if !executable('rg')
		echomsg string("Ctags dependens on ripgrep. I know horrible")
		return
	endif

	if !executable('ctags')
		echomsg string("Ctags dependens on ctags. duh?!?!!")
		return
	endif

	if !executable('cscope')
		echomsg string("Ctags dependens on cscope")
		return
	endif

	let files_loc = g:std_data_path . "/ctags/"
	let cwd_rg = getcwd()
	if has('win32')
		let cwd_rg = substitute(cwd_rg, "\\", "/", "g") " Fix cwd for the rg command
		let files_loc = substitute(files_loc, "\\", "/", "g") " Fix cwd for the rg command
	endif

	echo "Create tags for '" . cwd_rg . "'?: (j|y)es (any)no"
	let response = nr2char(getchar())
	if response !=# 'y' && response !=# 'j'
		echo 'Canceled'
		return
	endif

	let nvim_ft = &filetype
	if !s:create_cscope_files(cwd_rg, nvim_ft)
		echomsg "Failed to create cscope.files"
		return
	endif

	let ctags_lang = s:nvim_ft_to_ctags_ft(&filetype)

	" Create unique tag file name based on cwd_rg
	let tag_name = substitute(cwd_rg, "\\", '_', 'g')
	let tag_name = substitute(tag_name, ':', '_', 'g')
	let tag_name = substitute(tag_name, "/", '_', 'g')

	if !s:create_tags(tag_name, ctags_lang)
		echomsg "Failed to create tags file: " . tag_name
		return
	endif


	call s:add_tags(tag_name)

	let valid = 0
	for type in g:ctags_use_cscope_for
		if type ==# nvim_ft
			let valid = 1
			break
		endif
	endfor

	if valid == 0
		if &verbose > 0
			echomsg 'nvim_ft = ' . nvim_ft . ' not found'
		endif
		return
	endif

	" Create cscope db as well
	let cs_db = g:std_data_path . '/ctags/' . tag_name

	" Create spelllang as well
	call s:create_spell_from_tags(cs_db, nvim_ft)

	let files_name = fnameescape(g:std_cache_path .
				\ (has('unix') ? '/' : "\\")
				\ . 'cscope.files')

	let cs_db .= '.out'
	if !empty(glob(cs_db)) " If we are updating an existing tag. Close only that connection
		execute "silent! cs kill " . cs_db
	endif

	let cscope_cmd = 'cscope -f ' . cs_db . ' -bqi ' . files_name
	if &verbose > 0
		echomsg 'cscope_cmd = ' . cscope_cmd
	endif
	echo 'Creating cscope database...'
	let res_cs = systemlist(cscope_cmd)
	if v:shell_error || getfsize(cs_db) < 1
		if !empty(res_cs)
			cexpr res_cs
		endif
		echomsg 'Cscope command failed'
		return
	endif

	execute "cs add " . cs_db
endfunction

" TODO.RM-Fri Mar 24 2017 16:49: This function is suppose to be async version of ctags#NvimSyncCtags
" Right now there is no support jobstart() in windows so its kinda difficult to make
function! ctags#NvimAsyncCtags() abort
	" if has('unix')
		" !rm cscope.files cscope.out cscope.po.out cscope.in.out
		" !find . -iregex '.*\.\(c\|cpp\|java\|cc\|h\|hpp\)$' > cscope.files
	" else
		" !del /F cscope.files cscope.in.out cscope.po.out cscope.out
		" !dir /b /s *.java *.cpp *.h *.hpp *.c *.cc *.cs > cscope.files
	" endif
	" First create the cscope.files
	let ft = Nvim_ft2ripgrep_ft()
	let cwd_rg = substitute(getcwd(), "\\", "/", "g") " Fix cwd for the rg command
	let callbacks = {
				\ 'on_stdout': function('s:JobHandler'),
				\ 'on_stderr': function('s:JobHandler'),
				\ 'on_exit': function('s:JobHandler'),
				\ 'cwd': g:std_data_path . '/ctags'
				\ }
	if executable('rg')
		let files_cmd = 'rg -t ' . ft . ' --files ' . "\"" . cwd_rg . "\"" . ' > cscope.files'
	endif

	call jobstart(files_cmd, callbacks)

	" let job1 = jobstart(['bash'], extend({'shell': 'shell 1'}, s:callbacks))
	" let job2 = jobstart(['bash', '-c', 'for i in {1..10}; do echo hello $i!; sleep 1; done'], extend({'shell': 'shell 2'}, s:callbacks))

	echomsg files_cmd

	" !cscope -b -q -i cscope.files
	" if !filereadable('cscope.out')
		" echoerr "Couldnt create cscope.out files"
		" return
	" endif

	" silent! cs kill -1
	" cs add cscope.out
	" " The extra=+q option is to highlight memebers
	" " Keep in mind that you are forcing the tags to be c++
	" silent !ctags -R -L cscope.files -f .tags --sort=yes --c++-kinds=+pl --fields=+iaS --extra=+q --language-force=C++
	" set tags+=.tags
endfunction

function! s:nvim_ft_to_rg_ft(ft) abort
	let rg_ft = a:ft
	if a:ft =~ 'vim'
		let rg_ft = 'vimscript'
	elseif a:ft =~ 'python'
		let rg_ft = 'py'
	endif
	return rg_ft
endfunction

" function! s:JobHandler(job_id, data, event) dict
	" " if a:event == 'stdout'
		" " let str = self.shell.' stdout: '.join(a:data)
	" " elseif a:event == 'stderr'
		" " let str = self.shell.' stderr: '.join(a:data)
	" " else
		" " let str = self.shell.' exited'
	" " endif

	" " call append(line('$'), str)
	" " cexpr str
	" cexpr printf('%s: %s',a:event,string(a:data))
" endfunction

function! s:nvim_ft_to_ctags_ft(ft) abort
	if a:ft == 'cpp'
		let lang = 'C++'
	elseif a:ft == 'vim'
		let lang = 'Vim'
	elseif a:ft == 'python'
		let lang = 'Python'
	elseif a:ft == 'java'
		let lang = 'Java'
	elseif a:ft == 'c'
		let lang = 'C'
	else
		return ''
	endif

	return lang
endfunction

" Original Version
function! s:update_ctags() abort
	if !executable('cscope') || !executable('ctags')
		echoerr "Please install cscope and/or ctags before using this application"
		return
	endif

	if executable('rg') && has('nvim') && has('python3') " Use asynch nvim call instead
		" call UpdateTagsRemote()
		" return
		" elseif has('python3')			" If python3 is available use it
		" if has('python3')			" If python3 is available use it
		call python#UpdateCtags()
		return
	endif

	silent! cs kill -1
	if has('unix')
		!rm cscope.files cscope.out cscope.po.out cscope.in.out
		!find . -iregex '.*\.\(c\|cpp\|java\|cc\|h\|hpp\)$' > cscope.files
	else
		!del /F cscope.files cscope.in.out cscope.po.out cscope.out
		!dir /b /s *.java *.cpp *.h *.hpp *.c *.cc *.cs > cscope.files
	endif
	!cscope -b -q -i cscope.files
	if !filereadable('cscope.out')
		echoerr "Couldnt create cscope.out files"
		return
	endif
	cs add cscope.out
	" The extra=+q option is to highlight memebers
	" Keep in mind that you are forcing the tags to be c++
	silent !ctags -R -L cscope.files -f .tags --sort=yes --c++-kinds=+pl --fields=+iaS --extra=+q --language-force=C++
	" set tags+=.tags
endfunction

function! s:list_tags_files() abort
	" Obtain full path list of all files in ctags folder
	let tags_loc = g:std_data_path . "/ctags/"
	let potential_tags = map(utils#ListFiles(tags_loc), "tags_loc . v:val")
	if len(potential_tags) == 0
		" echomsg tags_loc . " is empty"
		return
	endif

	return potential_tags
endfunction

" Creates cscope.files in ~\.cache\ctags\
function! s:create_cscope_files(cwd_rg, nvim_ft) abort
	let rg_ft = s:nvim_ft_to_rg_ft(a:nvim_ft)
	" Get cscope files location
	let files_name = fnameescape(g:std_cache_path .
				\ (has('unix') ? '/' : "\\")
				\ . 'cscope.files')

	" Cscope db are not being created properly therefore making cscope.files filetype specific no matter what
	let files_cmd = 'rg -t ' . rg_ft . ' --files ' . a:cwd_rg .' > ' . files_name

	if &verbose > 0
		echomsg string(files_cmd)
	endif
	let res = ''
	if has('nvim')
		let res = systemlist(files_cmd)
	else
		silent! execute "!" . files_cmd
	endif
	if getfsize(files_name) < 1
		if !empty(res)
			cexpr res
		endif
		return
	endif
	return 1
endfunction

function! s:create_tags(tags_name, ctags_lang) abort
	let tags_loc = g:std_data_path . '/ctags/' . a:tags_name
	let files_name = fnameescape(g:std_cache_path .
				\ (has('unix') ? '/' : "\\")
				\ . 'cscope.files')

	if a:ctags_lang ==# 'C++'
		let ctags_cmd = 'ctags -L ' . files_name . ' -f ' . tags_loc .
					\ ' --sort=no --recurse=yes --c-kinds=+pl' .
					\ ' --c++-kinds=+pl --fields=+iaSl extras=+q' .
					\ ' --language-force=C++'
	else
		let ctags_cmd = 'ctags -L ' . files_name . ' -f ' . tags_loc .
					\  ' --sort=no --recurse=yes'
	endif

	echo 'Creating tags ...'
	if &verbose > 0
		echomsg 'ctags_cmd = ' . ctags_cmd
	endif

	let res = systemlist(ctags_cmd)
	if v:shell_error || getfsize(tags_loc) < 1
		if &verbose > 0
			echomsg 'cmd failed'
		endif

		if !empty(res)
			cexpr res
		endif
		return
	endif

	return 1
endfunction

function! ctags#LoadCscopeDatabse() abort
	if &modifiable == 0
		return
	endif

	" Local cscope.out has priority
	if !empty(glob('cscope.out'))
		cs add cscope.out
		return 1
	endif

	if !exists('g:root_dir') || empty(g:root_dir)
		let dir = expand('%:h')
	else
		let dir = g:root_dir
	endif

	let cs_db = utils#GetPathFolderName(dir)
	if empty(cs_db)
		" echomsg "Failed to obtain current folder name"
		return
	endif

	" Load tags as well
	call s:add_tags('tags_' . cs_db)

	let cs_db .= '.out'
	let cs_loc = g:std_data_path . '/ctags/' . cs_db

	redir => output
	execute 'silent cs show'
	redir END

	" If connection doesnt exist and file exists
	if output !~# cs_db && !empty(glob(cs_loc))
		execute 'silent cs add ' . cs_loc
	endif
endfunction

function! s:add_tags(tags_name) abort
	" Add new tag file if not already on the list
	let list_tags = tagfiles()
	let tag_present = 0
	for tag in list_tags
		if tag =~# a:tags_name
			let tag_present = 1
			break
		endif
	endfor
	if tag_present == 0
		execute "set tags+=" . g:std_data_path . '/ctags/' . a:tags_name
	endif
endfunction


" Depends on the being in the same folder as the tags_name
function! s:create_spell_from_tags(tags_name, vim_ft) abort
	if !get(g:, 'ctags_create_spell', 0) || !has('python') || !exists('g:ctags_spell_script') ||
				\ empty(glob(g:ctags_spell_script)) || empty(glob(a:tags_name))
		if &verbose > 0
			echomsg 'vim_ft = ' . a:vim_ft
		endif
		return
	endif

	let spell_cmd = 'python ' . shellescape(expand(g:ctags_spell_script)) .
				\ ' -t ' . a:tags_name . ' ' . a:tags_name

	if &verbose > 0
		echomsg string(getcwd())
		echomsg spell_cmd
	endif

	echo 'Creating spell file...'
	let res = systemlist(spell_cmd)
	if v:shell_error
		cexpr res
		return
	endif

	let &l:spell=1
	let &l:spelllang .= ',' . a:tags_name
endfunction
