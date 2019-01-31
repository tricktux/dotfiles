" File:           ctags.vim
" Description:    New version 8800 of the ctags plugin
" Author:		    Reinaldo Molina
" Email:          rmolin88 at gmail dot com
" Revision:	    88.0.0
" Created:        Tue Jan 29 2019 17:11
" Last Modified:  Tue Jan 29 2019 17:11

" if exists('g:loaded_ctags')
	" finish
" endif

let g:loaded_ctags = 1

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

if !exists('g:ctags_use_ft')
	let g:ctags_use_ft = 1
endif

if !exists('g:ctags_language_specific_extra_options')
	let g:ctags_language_specific_extra_options = {
				\ 'cpp' : '--c-kinds=+pl --c++-kinds=+pl --fields=+iaSl --extras=+q',
				\ }
endif

let l:rg_to_vim_filetypes = {
			\ 'vim' : 'vimscript',
			\ 'python' : 'py',
			\ 'markdown' : 'md',
			\ }

let l:ctags_to_vim_filetypes = {
			\ 'cpp' : 'C++',
			\ 'vim' : 'Vim',
			\ 'python' : 'Python',
			\ 'java' : 'Java',
			\ 'c' : 'C',
			\ }

let s:grep = {
			\ 'executable' : 'rg',
			\ 'is_executable' : executable('rg'),
			\ 'args' : [
			\   '--vimgrep',
			\		'--follow',
			\		'--hidden',
			\		'--iglob',
			\		(has('unix') ? "'!.{git,svn,sync}'" : '!.{git,svn}')
			\ ],
			\ 'filetype_support' : 1,
			\ 'filetype_map' : l:rg_to_vim_filetypes,
			\ 'filetype_option' : '--type',
			\ }

let s:ctags = {
			\ 'files_list' : '',
			\ 'cwd' : '',
			\ 'name' : '',
			\ 'path' : g:ctags_output_dir,
			\ 'full_path' : '',
			\ 'filetype_name' : '',
			\ 'executable' : 'ctags',
			\ 'is_executable' : executable('ctags'),
			\ 'filetype_support' : 1,
			\ 'filetype_map' : l:ctags_to_vim_filetypes,
			\ 'filetype_option' : '--language-force',
			\ }

function! s:grep.init() abort
	if (!self.is_executable)
		echomsg "ERROR: " self.executable " is not executable"
		return
	endif

	let self.cmd = self.executable .
				\ (self.use_type_option ? ' -t ' . self.filetype_name : '') .
				\ ' --files "' . s:ctags.cwd .'"' .
				\ ' > ' .	s:ctags.files_list

	return 1
endfunction

function! s:grep.get_files_list() abort
	if (self.exec < 1)
		if (s:debug)
			echomsg "[grep.get_files_list()]: ERROR: ripgrep is not executable"
		endif
		return
	endif
	
	if (s:debug)
		echomsg "[grep.get_files_list]: INFO: cmd = " string(self.cmd)
	endif

	let rc = ''
	if has('nvim')
		let rc = systemlist(self.cmd)
	else
		silent execute "!" . self.cmd
	endif

	if ((!empty(rc)) || (v:shell_error))
		if (s:debug)
			echomsg "[grep.get_files_list]: files_list = " s:ctags.files_list
			if (!empty(rc))
				echomsg "[grep.get_files_list]: ERROR: cmd failed" string(rc)
			else
				echomsg "[grep.get_files_list]: ERROR: cmd failed"
			endif
		endif
		return
	endif

	return 1
endfunction

function! s:ctags.init() abort
	if (!self.is_executable)
		echomsg "ERROR: " self.executable " is not executable"
		return
	endif

	if (empty(glob(self.path)))
		echomsg "ERROR: ctags output path: " g:ctags_output_dir " not accessible"
		return
	endif

	let s:debug = &verbose > 0

	let self.files_list = tempname()
	let self.cwd = getcwd()
	let self.name = utils#GetFullPathAsName(self.cwd)
	let self.full_path = self.path . self.name
	let self.filetype_name = self.vim_ft_to_ctags_ft(&filetype)
	let self.cmd = self.executable . ' ' .
				\ '-L ' . self.files_list . ' ' .
				\ '-f ' . self.full_path . ' ' .
				\ '--sort=yes --recurse=yes '

	let self.cmd .= has_key(g:ctags_language_specific_extra_options, &filetype) ?
				\ g:ctags_language_specific_extra_options[&filetype] : ''

	if (s:grep.init() != 1)
		return
	endif
	return 1
endfunction

function! s:ctags.vim_ft_to_ctags_ft(ft) abort
	if a:ft ==? 'cpp'
		return 'C++'
	elseif a:ft ==? 'vim'
		return 'Vim'
	elseif a:ft ==? 'python'
		return 'Python'
	elseif a:ft ==? 'java'
		return 'Java'
	elseif a:ft ==? 'c'
		return 'C'
	endif

	return a:ft
endfunction

function! s:ctags.confirm() abort
	let msg = "Create tags for folder:\n\t" .
				\ "\"" . self.cwd . "\""
	return confirm(msg, "&JYes\n&LNo", 2)
endfunction

function! s:ctags.execute() abort
	
endfunction

function! s:ctags.create() abort
	if (self.init() != 1)
		return
	endif

	if (self.confirm() != 1)
		return
	endif

	if (s:grep.get_files_list() < 1)
		echomsg "Error: Failed to fill up list of files"
		return
	endif
endfunction

command! UtilsCtagsCreate call s:ctags.create()
