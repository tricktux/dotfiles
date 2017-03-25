" File:ctags.vim
"	Description: All functions related to creation/deletion/update/loading of ctags and cscope
" Author:Reinaldo Molina <rmolin88@gmail.com>
" Version:1.0.0
" Last Modified: Fri Mar 24 2017 16:22

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

	let ft = ctags#NvimFt2Rg()
	let cwd_rg = getcwd()
	if has('win32')
		let cwd_rg = substitute(cwd_rg, "\\", "/", "g") " Fix cwd for the rg command
	endif
	" Get cscope files location
	let files_loc = g:cache_path . "ctags/"
	let files_name = files_loc . "cscope.files"
	let files_cmd = 'rg -t ' . ft . ' --files ' .  cwd_rg .  ' > ' . files_name
	" let files_cmd = substitute(files_cmd,"'", "","g")
	call delete(files_name)	 " Delete old/previous cscope.files
	" echomsg string(files_cmd) " Debugging
	call system(files_cmd)
	if getfsize(files_name) < 1 
		echomsg string("Failed to create cscope.files")
		return
	endif
	
	let ctags_lang = ctags#NvimFt2Ctags(&filetype)
	if empty(ctags_lang)
		echomsg string("Failed to obtain ctags lang")
		return
	endif

	" Create unique tag file name based on cwd_rg
	let tags_name = ctags#GetPathFolderName(cwd_rg)
	if empty(tags_name)
		echomsg string("Failed to obtain tags_name")
		return
	endif

	let ctags_cmd = "ctags -L cscope.files -f tags_" . tags_name . " --sort=no --c-kinds=+p --c++-kinds=+p --fields=+l extras=+q --language-force=" . ctags_lang

	" echomsg string(ctags_cmd) " Debugging
	execute "cd " . files_loc
	call system(ctags_cmd)

	if &ft ==# 'cpp' || &ft ==# 'c' || &ft ==# 'java'
		" Create cscope db as well
		execute "silent! cs kill -1"
		let del_files = ['cscope.out', 'cscope.po.out', 'cscope.in.out']
		for item in del_files
			call delete(item)
		endfor
		call system('cscope -b -q')
		if getfsize('cscope.out') < 1 
			echomsg string("Failed to create cscope.out")
			execute "cd " . cwd_rg
			return
		endif
		execute "cs add cscope.out"
	endif

	execute "cd " . cwd_rg
endfunction

function! ctags#GetPathFolderName(curr_dir) abort
 " Strip path to get only root folder name
	let back_slash_index = strridx(a:curr_dir, '/')
	if back_slash_index == -1
		let back_slash_index = strridx(a:curr_dir, '\')
	endif

	if back_slash_index == -1
		echomsg string("No back_slash_index found")
		return
	endif

	return a:curr_dir[back_slash_index+1:]
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
				\ 'cwd': g:cache_path . 'ctags'
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

function! ctags#NvimFt2Rg() abort
	let rg_ft = &ft
	if rg_ft =~ 'vim'
		let rg_ft = 'vimscript'
	elseif rg_ft =~ 'python'
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

function! ctags#NvimFt2Ctags(ft) abort
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
		return
	endif

	return lang
endfunction

" Original Version
function! ctags#UpdateCscope() abort
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

function! ctags#SetTags() abort
	" Obtain full path list of all files in ctags folder
	let potential_tags = map(utils#ListFiles(g:cache_path . 'ctags'), "g:cache_path . 'ctags/' . v:val")
	if len(potential_tags) == 0
		return
	endif
	for item in potential_tags
		if item =~# 'tags_'
			execute "set tags +=" . item
		elseif item =~# 'cscope.out'
			silent! execute "cs add " . item
		endif
	endfor
endfunction

