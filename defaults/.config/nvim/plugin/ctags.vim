" File:ctags.vim
"	Description: All functions related to creation/deletion/update/loading of ctags and cscope
" Author:Reinaldo Molina
" Version:1.0.0
" Last Modified: Fri Aug 30 2024 09:46
" Created: Sat Apr 01 2017 17:04

if exists('g:loaded_my_ctags')
	finish
endif

let g:loaded_my_ctags = 1

if !exists('g:ctags_use_cscope_for')
	let g:ctags_use_cscope_for = ['c', 'cpp', 'java']
endif

if !exists('g:ctags_output_dir')
	let g:ctags_output_dir =
				\ (has('unix') ? '/tmp/' : expand($TMP) . '\ctags\' )
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

function! s:get_full_path_as_name(folder) abort
	" Create unique tag file name based on cwd
	let l:ret = substitute(a:folder, "\\", '_', 'g')
	let l:ret = substitute(l:ret, ':', '_', 'g')
	let l:ret = substitute(l:ret, ' ', '_', 'g')
	return substitute(l:ret, "/", '_', 'g')
endfunction

function! s:list_files(dir) abort
	let l:directory = globpath(a:dir, '*')
	if empty(l:directory)
		" echohl ErrorMsg | echom a:dir . " is not a valid directory name" | echohl None
		return []
	endif
	return map(split(l:directory,'\n'), "fnamemodify(v:val, ':t')")
endfunction

function! s:ctags.update_vars() abort
	let self.files_list = tempname()
	let self.cwd = getcwd()
	let self.cwd_as_name = s:get_full_path_as_name(self.cwd)
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
function! ctags#NvimSyncCtagsCscope() abort
	let response = confirm('Create tags for current folder?', "&Jes\n&Lo", 2)
	if response != 1
		return
	endif

	let tag_name = s:get_full_path_as_name(getcwd())

	if !s:create_tags(tag_name)
		echomsg "Failed to create tags file: " . tag_name
		return
	endif

	call s:create_cscope(tag_name)
endfunction

function! ctags#VimFt2RgFt() abort
	let rg_ft = &filetype
	if rg_ft ==? 'python'
		return 'py'
	endif
	return rg_ft
endfunction

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

function! s:list_tags_files() abort
	" Obtain full path list of all files in ctags folder
	let potential_tags = map(s:list_files(g:ctags_output_dir), "g:ctags_output_dir . v:val")
	if len(potential_tags) == 0
		" echomsg tags_loc . " is empty"
		return
	endif

	return potential_tags
endfunction

" Creates cscope.files in ~\.cache\ctags\
function! s:create_cscope_files(quote_files) abort
	if !executable('fd')
		echomsg string("cscope dependens on fd.... I know horrible")
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

	if v:shell_error
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
		echoerr "Failed to create cscope files"
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

	if &verbose > 0
		echomsg 'ctags_cmd = ' . ctags_cmd
	endif

	let res = systemlist(ctags_cmd)
	if v:shell_error
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

	let tag_name = s:get_full_path_as_name(getcwd())

	if s:add_tags(tag_name) != 1
		call s:create_tags(tag_name)
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

	if s:load_cscope_db(tag_name . '.out') == 0
		call s:create_cscope(tag_name)
	endif
endfunction

function! s:add_tags(tags_name) abort
	if empty(glob(g:ctags_output_dir . a:tags_name))
		if &verbose > 0
			echomsg 'Tags file doesnt exist: ' . g:ctags_output_dir . a:tags_name
		endif
		return 0
	endif

	execute "set tags=" . g:ctags_output_dir . a:tags_name
	echomsg "Updated tags: " &tags
	return 1
endfunction

function! s:get_cwd() abort
	let cwd_rg = getcwd()
	if !has('unix')
		let cwd_rg = substitute(cwd_rg, "\\", "/", "g") " Fix cwd for the rg command
	endif

	return cwd_rg
endfunction

function! s:create_cscope(tag_name) abort
	if has('nvim')
		if exists(':Cs')
		endif
		return
	endif

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
	let cscope_cmd = 'cscope -Rbcq -f ' . cs_db . ' -i ' . '"' . s:files_list . '"'
	if &verbose > 0
		echomsg 'cscope_cmd = ' . cscope_cmd
	endif
	let res_cs = systemlist(cscope_cmd)
	if v:shell_error
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
		return -1
	endif

	let cs_db = g:ctags_output_dir . a:tag_name
	if empty(glob(cs_db))
		if &verbose > 0
			echomsg 'No cscope database ' . cs_db
		endif
		return 0
	endif

	try
		execute 'silent cs add ' . cs_db
	catch /^Vim(cscope):/
		return -2
	endtry
	return 1
endfunction

function! s:get_filetype_extentions() abort
	let l:ft = &filetype

	if l:ft ==# 'cpp' || l:ft ==# 'c'
		return "\"\.(c|cpp|c++|cc|h|hpp)$\""
	elseif l:ft ==# 'vim'
		return "\"\.(vim)$\""
	elseif l:ft ==# 'python'
		return "\"\.(py)$\""
	elseif l:ft ==# 'java'
		return "\"\.(java)$\""
	else
		return ""
	endif
endfunction
