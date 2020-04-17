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

if !exists('g:ctags_create_spell')
	let g:ctags_create_spell=0
endif

if !exists('g:ctags_spell_script')
	let g:ctags_spell_script=''
endif

if !exists('g:ctags_spell_output_dir')
	let g:ctags_spell_output_dir = $HOME .
				\ (has('unix') ? '/.vim/' : '/vimfiles/') .
				\ 'spell/'
endif

if !exists('g:ctags_output_dir')
	let g:ctags_output_dir =
				\ (has('unix') ? '~/.cache/ctags/' : expand($TMP) . '\ctags\' )
endif

if !exists('g:ctags_rg_use_ft')
	let g:ctags_rg_use_ft = 1
endif

let s:files_list = tempname()

let s:ctags = {
			\ 'files_list' : '',
			\ 'cwd' : '',
			\ 'cwd_as_name' : '',
			\ }

function! s:ctags.update_vars() abort
	let self.files_list = tempname()
	let self.cwd = getcwd()
	let self.cwd_as_name = utils#GetFullPathAsName(self.cwd)
endfunction

function! s:ctags.confirm() abort
	let msg = 'Create tags for folder:\n' .
				\ "\"" . self.cwd . "\""
	return confirm(msg, "&JYes\n&LNo", 2)
endfunction

function! s:ctags.create() abort
	if (self.confirm() != 1)
		return
	endif

	call self.update_vars()
endfunction

"	Your current directory should be at the root of you code
function! ctags#NvimSyncCtags() abort
	let response = confirm('Create tags for current folder?', "&Jes\n&Lo", 2)
	if response != 1
		return
	endif

	let tag_name = utils#GetFullPathAsName(getcwd())

	if !s:create_tags(tag_name)
		echomsg "Failed to create tags file: " . tag_name
		return
	endif

	" Create spelllang as well
	" call s:create_spell_from_tags(tag_name)

	call s:create_cscope(tag_name)
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

function! ctags#VimFt2RgFt() abort
	let rg_ft = &filetype
	if rg_ft ==? 'python'
		return 'py'
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

function! s:vim_ft_to_ctags_ft(ft) abort
	if a:ft ==? 'cpp'
		let lang = 'C++'
	elseif a:ft ==? 'vim'
		let lang = 'Vim'
	elseif a:ft ==? 'python'
		let lang = 'Python'
	elseif a:ft ==? 'java'
		let lang = 'Java'
	elseif a:ft ==? 'c'
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
	let potential_tags = map(utils#ListFiles(g:ctags_output_dir), "g:ctags_output_dir . v:val")
	if len(potential_tags) == 0
		" echomsg tags_loc . " is empty"
		return
	endif

	return potential_tags
endfunction

" Creates cscope.files in ~\.cache\ctags\
function! s:create_cscope_files(quote_files) abort
	if !executable('fd')
		echomsg string("Ctags dependens on ripgrep. I know horrible")
		return
	endif

	let l:sed = ' | sed -e ' .
				\ shellescape("s/\\(.*\\)/\"\\1\"/g", 1) .
				\ ' '
				" \ ' -e ' . shellescape("s/\\\\\\\\/\\\\\\\\\\\\\\\\/g", 1) .
	let rg_ft = ctags#VimFt2RgFt()
	" Cscope db are not being created properly therefore making cscope.files filetype specific no matter what
				" \ (!has('unix') ? '--path-separator \\\\' : '') .
	" let files_cmd = 'rg ' .
				" \ (g:ctags_rg_use_ft == 1 ? '-t ' . rg_ft : '') .
				" \ ' --files "' . getcwd() .'"' .
				" \ ' > ' .	s:files_list
	let files_cmd = 'fd' . ' ' .
				\ '--type file' . ' ' .
				\ '--follow --hidden --absolute-path' . ' ' .
				\ '--exclude ".{sync,git,svn}"' . ' ' .
				\ (g:ctags_rg_use_ft == 1 ?  s:get_filetype_extentions() : '') . ' ' .
				\ '> ' .	s:files_list
				" \ (!has('unix') ? ' --path-separator /' : '') .
				" \ (executable('sed') && a:quote_files == 1 ? l:sed : ' ') .

	if &verbose > 0
		echomsg string(files_cmd)
	endif
	let res = ''
	if has('nvim')
		let res = systemlist(files_cmd)
	else
		silent execute "!" . files_cmd
	endif

	if getfsize(s:files_list) < 1
		if !empty(res)
			cexpr res
		endif
		return
	endif

	return 1
endfunction

function! s:create_tags(tags_name) abort
	if !executable('ctags')
		echomsg string("Ctags dependens on ctags. duh?!?!!")
		return
	endif

	" Do not quote file names
	if !s:create_cscope_files(1)
		return
	endif

	let ctags_lang = s:vim_ft_to_ctags_ft(&filetype)

	let tags_loc = g:ctags_output_dir . a:tags_name

	" Default command
	" Fri Aug 31 2018 16:31: 
	" - See 'tagbsearch' for the enabled sort option 
	" - Also added relative to match vim's 'tagrelative'
	" - NOTE: Keep in mind to leav a space at end of each chunk
	" Tue Jan 29 2019 15:31:
	" - Relative thing doesnt make much sense
	let ctags_cmd = 'ctags -L ' . s:files_list . ' -f ' . tags_loc .
				\  ' --sort=yes --recurse=yes --tag-relative=no --output-format=e-ctags '

	if ctags_lang ==# 'C++'
		let ctags_cmd .= '--c-kinds=+pl --c++-kinds=+pl --fields=+iaSl --extras=+q '
	endif

	" Do not force the language so that you get tags for everything
	" if !empty(ctags_lang)
		" let ctags_cmd .= '--language-force=' . ctags_lang
	" endif

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

	call s:add_tags(a:tags_name)

	return 1
endfunction

function! ctags#LoadCscopeDatabse() abort
	if &modifiable == 0
		return
	endif

	" Local cscope.out has priority
	if !empty(glob('cscope.out'))
		try
			cs kill -1
			cs add cscope.out
		catch 
			return -1
		endtry
		return 1
	endif

	let tag_name = utils#GetFullPathAsName(getcwd())

	call s:add_tags(tag_name)

	call s:load_cscope_db(tag_name . '.out')

	" call s:load_tag_spelllang(tag_name)
	
	" call s:load_cctree_cscope_db(tag_name . '.xref')
endfunction

function! s:add_tags(tags_name) abort
	if empty(glob(g:ctags_output_dir . a:tags_name))
		if &verbose > 0
			echomsg 'Tags file doesnt exist: ' . g:ctags_output_dir . a:tags_name
		endif
		return
	endif

	" Add new tag file if not already on the list
	let list_tags = tagfiles()
	let tag_present = 0
	for tag in list_tags
		if tag ==? a:tags_name
			let tag_present = 1
			break
		endif
	endfor
	if tag_present == 0
		if &verbose > 0
			echomsg 'Adding tags: ' . g:ctags_output_dir . a:tags_name
		endif
		execute "set tags+=" . g:ctags_output_dir . a:tags_name
	endif
endfunction

" tags_name - ctags file name
function! s:create_spell_from_tags(tags_name) abort
	if !get(g:, 'ctags_create_spell', 0)
		if &verbose > 0
			echomsg 'g:ctags_create_spell = 0'
		endif
		return
	endif

	if !has('python')
		if &verbose > 0
			echomsg 'No python available'
		endif
		return
	endif

	if	!exists('g:ctags_spell_script') ||
				\ empty(glob(g:ctags_spell_script))
		if &verbose > 0
			echomsg 'Spell creator python script not found'
		endif
		return
	endif

	let tags_loc = g:ctags_output_dir . a:tags_name

	if empty(glob(tags_loc))
		if &verbose > 0
			echomsg 'Ctags file not found = ' . tags_loc
		endif
		return
	endif

	" Check if it is a spell type
	let valid = 0
	for type in g:ctags_use_spell_for
		if type ==? &filetype
			let valid = 1
			break
		endif
	endfor

	if valid == 0
		if &verbose > 0
			echomsg 'Current &filetype not for spell'
		endif
		return
	endif

	if empty(glob(g:ctags_spell_output_dir))
		if exists('*mkdir')
			call mkdir(fnameescape(g:ctags_spell_output_dir))
		elseif &verbose > 0
			echomsg 'Spell output folder doesnt exists and I cannot create it'
		endif
		return
	endif

	let spell_cmd = 'python ' . shellescape(expand(g:ctags_spell_script)) .
				\ ' -t ' . tags_loc . ' ' . a:tags_name

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

function! s:get_cwd() abort
	let cwd_rg = getcwd()
	if !has('unix')
		let cwd_rg = substitute(cwd_rg, "\\", "/", "g") " Fix cwd for the rg command
	endif

	return cwd_rg
endfunction

function! s:create_cscope(tag_name) abort
	if !executable('cscope')
		echomsg string("Ctags dependens on cscope")
		return
	endif

	if !has('unix')
		let choice = confirm('Run cscope?', "&Jes\n&Ko", 2)
		if (choice != 1)
			return
		endif
	endif

	let valid = 0
	for type in g:ctags_use_cscope_for
		if type ==? &filetype
			let valid = 1
			break
		endif
	endfor

	if valid == 0
		if &verbose > 0
			echomsg 'Not creating cscope db for ' . &filetype
		endif
		return
	endif

	" Create cscope db as well
	let cs_db = g:ctags_output_dir . a:tag_name . '.out'

	if !empty(glob(cs_db))
		" If we are updating an existing tag. Silently attempt to close connection
		try
			execute 'silent cs kill ' . cs_db
		catch /^Vim(cscope):/
		endtry
	endif

	" Recreate files and now quote them
	" Redundant
	" if !s:create_cscope_files(1)
		" return
	" endif

	" -b            Build the cross-reference only.
	" -c            Use only ASCII characters in the cross-ref file (don't compress).
	" -q            Build an inverted index for quick symbol searching.
	" -f reffile    Use reffile as cross-ref file name instead of cscope.out.
	" -i namefile   Browse through files listed in namefile, instead of cscope.files
	let cscope_cmd = 'cscope -Rbcq -f "' . cs_db . '" -i ' . '"' . s:files_list . '"'
	if &verbose > 0
		echomsg 'cscope_cmd = ' . cscope_cmd
	endif
	echo 'Creating cscope database...'
	" execute '!' . cscope_cmd
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

function! s:load_cscope_db(tag_name) abort
	if !exists('g:ctags_output_dir') || empty('g:ctags_output_dir')
		if &verbose > 0
			echoerr '[load_cscope_db]: Failed to get g:ctags_output_dir path'
		endif
		return
	endif

	let cs_db = g:ctags_output_dir . a:tag_name
	if empty(glob(cs_db))
		if &verbose > 0
			echomsg 'No cscope database ' . cs_db
		endif
		return
	endif

	try
		execute 'silent cs add ' . cs_db
	catch /^Vim(cscope):/
		return
	endtry
endfunction

function! ctags#LoadCctreeDb() abort
	if !exists(':CCTreeLoadDB')
		echoerr '[ctags#LoadCctreeDb]: CCTree not loaded'
		return
	endif

	let l:tag_name = utils#GetFullPathAsName(getcwd()) . '.out'

	return s:load_cctree_cscope_db(l:tag_name)
endfunction

function! s:load_cctree_cscope_db(tag_name) abort
	if !exists('g:ctags_output_dir') || empty('g:ctags_output_dir')
		if &verbose > 0
			echoerr '[load_cctree_cscope_db]: Failed to get g:ctags_output_dir path'
		endif
		return
	endif

	if !exists(':CCTreeLoadDB')
		if &verbose > 0
			echoerr '[load_cctree_cscope_db]: CCTree not loaded'
		endif
		return
	endif

	let cs_db = g:ctags_output_dir . a:tag_name
	if empty(glob(cs_db))
		if &verbose > 0
			echomsg 'No cctree database ' . cs_db
		endif
		return
	endif

	try
		execute 'CCTreeLoadXRefDB ' . cs_db
	catch /^Vim(cscope):/
		return
	endtry
endfunction

function! s:load_tag_spelllang(tags_name) abort
	let spellar = g:ctags_spell_output_dir . a:tags_name
	if empty(glob(spellar . '*.*'))
		if &verbose > 0
			echomsg 'No spelllang ' . spellar
		endif
		return
	endif

	let &l:spell=1
	let &l:spelllang .= ',' . a:tags_name
endfunction

function! s:get_filetype_extentions() abort
	let l:ft = &filetype

	if l:ft ==# 'cpp'
		return "\"\.(c|cpp|c++|cc|h|hpp)$\""
	elseif l:ft ==# 'vim'
		return "\"\.(vim)$\""
	elseif l:ft ==# 'python'
		return "\"\.(py)$\""
	elseif l:ft ==# 'java'
		return "\"\.(java)$\""
	endif
endfunction
