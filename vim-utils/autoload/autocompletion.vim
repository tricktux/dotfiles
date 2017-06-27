
" File:tsautocompletion.vim
"	Description: Choose and setup autocompletion engine		
" Author:autocompletionReinaldo Molina <rmolin88@gmail.com>
" Version:gmail1.0.0
" Last Modified: Apr 04 2017 23:58

function! autocompletion#SetCompl() abort
	let compl = get(g:, 'autcompl_engine', '')

	if !has('python3') || exists('g:android') || empty(compl)
		call autocompletion#SetTab()
		return -1
	endif

	if compl ==# 'ycm'
			Plug 'Valloric/YouCompleteMe', { 'on' : 'YcmDebugInfo' }
			"" turn on completion in comments
			let g:ycm_complete_in_comments=0
			"" load ycm conf by default
			let g:ycm_confirm_extra_conf=0
			"" turn on tag completion
			let g:ycm_collect_identifiers_from_tags_files=1
			"" only show completion as a list instead of a sub-window
			" set completeopt-=preview
			"" start completion from the first character
			let g:ycm_min_num_of_chars_for_completion=2
			"" don't cache completion items
			let g:ycm_cache_omnifunc=0
			"" complete syntax keywords
			let g:ycm_seed_identifiers_with_syntax=1
			" let g:ycm_global_ycm_extra_conf = '~/.dotfiles/vim-utils/.ycm_extra_conf.py'
			let g:ycm_autoclose_preview_window_after_completion = 1
			let g:ycm_semantic_triggers =  {
			\   'c' : ['->', '.'],
			\   'objc' : ['->', '.'],
			\   'ocaml' : ['.', '#'],
			\   'cpp,objcpp' : ['->', '.', '::'],
			\   'perl' : ['->'],
			\   'php' : ['->', '::'],
			\   'cs,javascript,d,python,perl6,scala,vb,elixir,go' : ['.'],
			\   'java,jsp' : ['.'],
			\   'vim' : ['re![_a-zA-Z]+[_\w]*\.'],
			\   'ruby' : ['.', '::'],
			\   'lua' : ['.', ':'],
			\   'erlang' : [':'],
			\ }
			
		Plug 'rdnetto/YCM-Generator', { 'branch': 'stable'}
	elseif compl ==# 'nvim_compl_manager'
		" Optional but useful python3 support
		" pip3 install --user neovim jedi mistune psutil setproctitle
		" if has('win32')
			" call autocompletion#SetTab()
			" return -1
		" endif

		if has('vim')
			Plug 'roxma/vim-hug-neovim-rpc'
		endif

		if has('unix')
			Plug 'autozimu/LanguageClient-neovim', { 'do': ':UpdateRemotePlugins' }
				let g:LanguageClient_autoStart = 1
		endif

		Plug 'roxma/nvim-completion-manager'
		" nvim-completion-manager also added suppport for this
		Plug 'Shougo/neco-vim' " Sources for deoplete/neocomplete to autocomplete vim variables and functions
		Plug 'Shougo/neco-syntax'
		Plug 'Shougo/neoinclude.vim'
		Plug 'roxma/ncm-github'

		" ncm's filtering is based on word, so it's better to convert results of
		" muttaliases#CompleteMuttAliases into snippet expension
		func! g:MuttOmniWrap(findstart, base)
			let ret = muttaliases#CompleteMuttAliases(a:findstart, a:base)
			if type(ret) == type([])
				let i=0
				while i<len(ret)
					let ret[i]['snippet'] = ret[i]['word']
					let ret[i]['word'] = ret[i]['abbr']
					let i+=1
				endwhile
			endif
			return ret
		endfunc

		au User CmSetup call cm#register_source({'name' : 'mutt',
					\ 'priority': 9, 
					\ 'cm_refresh_length': -1,
					\ 'cm_refresh_patterns': ['^\w+:\s+'],
					\ 'cm_refresh': {'omnifunc': 'g:MuttOmniWrap'},
					\ })

		inoremap <expr> <CR> (pumvisible() ? "\<c-y>\<cr>" : "\<CR>")
		inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
		" if has('unix') " Automatic completion on unix
		inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
		" let g:cm_auto_popup = 1
		" else " but not anywhere else
			" let g:cm_auto_popup = 0
			" imap <silent> <Tab> <Plug>(cm_force_refresh)
		" endif

		if executable('clang')
			Plug 'roxma/clang_complete', { 'as': 'roxma_clang_complete' }
			call autocompletion#SetClang()
		endif
	elseif compl ==# 'shuogo'
		call autocompletion#SetShuogo()
	elseif compl ==# 'autocomplpop'
		Plug 'vim-scripts/AutoComplPop'
		inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
		inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
		if executable('clang')
			Plug 'Rip-Rip/clang_complete', { 'as': 'rip_clang_complete' }
			call autocompletion#SetClang()
		endif
	else
		call autocompletion#SetTab()
		return -1
	endif
	return 1
endfunction

" Settings for Rip-Rip/clang_complete and friends
function! autocompletion#SetClang() abort
	" Why I switched to Rip-Rip because it works
	" Steps to get plugin to work:
	" 1. Make sure that you can compile a program with clang++ command
	" a. Example: clang++ -std=c++14 -stdlib=libc++ -pedantic -Wall hello.cpp -v
	" 2. To get this to work I had to install libc++-dev package in unix
	" 3. install libclang-dev package. See g:clang_library_path to where it gets
	" installed. Also I had to make sym link: ln -s libclang.so.1 libclang.so
	let g:clang_user_options = '-std=c++14 -stdlib=libc++ -Wall -pedantic'
	let g:clang_close_preview = 1
	autocmd CompleteDone * pclose!
	" let g:clang_complete_copen = 1
	" let g:clang_periodic_quickfix = 1
	" let g:clang_complete_auto = 0
	if has('win32')
		" clang using mscv for target instead of mingw64
		let g:clang_cpp_options = '-target x86_64-pc-windows-gnu -std=c++17 -pedantic -Wall'
		let g:clang_c_options = '-target x86_64-pc-windows-gnu -std=gnu11 -pedantic -Wall'
	else
		let g:clang_library_path= g:usr_path . '/lib/libclang.so'
	endif
endfunction

function! autocompletion#SetShuogo() abort
	" Vim exclusive plugins
	
	if !has('nvim') && has('lua') " Neocomplete
		Plug 'Shougo/neocomplete'
		" All new stuff
		let g:neocomplete#enable_at_startup = 1
		let g:neocomplete#enable_cursor_hold_i=1
		let g:neocomplete#skip_auto_completion_time="1"
		let g:neocomplete#sources#buffer#cache_limit_size=5000000000
		let g:neocomplete#max_list=8
		let g:neocomplete#auto_completion_start_length=2
		let g:neocomplete#enable_auto_close_preview=1

		let g:neocomplete#enable_smart_case = 1
		let g:neocomplete#data_directory = g:cache_path . 'neocomplete'
		" Define keyword.
		if !exists('g:neocomplete#keyword_patterns')
			let g:neocomplete#keyword_patterns = {}
		endif
		let g:neocomplete#keyword_patterns['default'] = '\h\w*'
		" Recommended key-mappings.
		" <CR>: close popup and save indent.
		inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
		function! s:my_cr_function()
			return (pumvisible() ? "\<C-y>" : "" ) . "\<CR>"
		endfunction
		" <TAB>: completion.
		inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
		" <C-h>, <BS>: close popup and delete backword char.
		inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
		" Enable heavy omni completion.
		if !exists('g:neocomplete#sources#omni#input_patterns')
			let g:neocomplete#sources#omni#input_patterns = {}
		endif
		let g:neocomplete#sources#omni#input_patterns.tex =
					\ '\v\\%('
					\ . '\a*cite\a*%(\s*\[[^]]*\]){0,2}\s*\{[^}]*'
					\ . '|\a*ref%(\s*\{[^}]*|range\s*\{[^,}]*%(}\{)?)'
					\ . '|includegraphics\*?%(\s*\[[^]]*\]){0,2}\s*\{[^}]*'
					\ . '|%(include%(only)?|input)\s*\{[^}]*'
					\ . ')'
		let g:neocomplete#sources#omni#input_patterns.php =
					\ '[^. \t]->\%(\h\w*\)\?\|\h\w*::\%(\h\w*\)\?'
		let g:neocomplete#sources#omni#input_patterns.perl =
					\ '[^. \t]->\%(\h\w*\)\?\|\h\w*::\%(\h\w*\)\?'
		let g:neocomplete#sources#omni#input_patterns.java = '\h\w*\.\w*'

		if !exists('g:neocomplete#force_omni_input_patterns')
			let g:neocomplete#force_omni_input_patterns = {}
		endif
		let g:neocomplete#force_omni_input_patterns.c =
					\ '[^.[:digit:] *\t]\%(\.\|->\)\w*'
		let g:neocomplete#force_omni_input_patterns.cpp =
					\ '[^.[:digit:] *\t]\%(\.\|->\)\w*\|\h\w*::\w*'
		let g:neocomplete#force_omni_input_patterns.objc =
					\ '\[\h\w*\s\h\?\|\h\w*\%(\.\|->\)'
		let g:neocomplete#force_omni_input_patterns.objcpp =
					\ '\[\h\w*\s\h\?\|\h\w*\%(\.\|->\)\|\h\w*::\w*'
		" all new stuff
		if !exists('g:neocomplete#delimiter_patterns')
			let g:neocomplete#delimiter_patterns= {}
		endif
		let g:neocomplete#delimiter_patterns.vim = ['#']
		let g:neocomplete#delimiter_patterns.cpp = ['::']
		if executable('clang')
			Plug 'Rip-Rip/clang_complete', { 'as': 'rip_clang_complete' }
			call autocompletion#SetClang()
		endif
	elseif has('nvim')
		let b:deoplete_loaded = 1
		Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
			" If it is nvim deoplete requires python3 to work
			let g:deoplete#enable_at_startup = 1
			" Autoclose preview window
			autocmd CompleteDone * pclose!
			" Note: If you get autocomplete autotriggering issues keep increasing this option below. 
			" Next value to try is 150. See:https://github.com/Shougo/deoplete.nvim/issues/440
			let g:deoplete#auto_complete_delay=15 " Fixes issue where Autocompletion triggers
			" New settings
			let g:deoplete#enable_ignore_case = 1
			let g:deoplete#enable_smart_case = 1
			let g:deoplete#enable_camel_case = 1
			" Note: Changed this here to increase speed
			let g:deoplete#enable_refresh_always = 0
			let g:deoplete#max_list = 10
			" let g:deoplete#max_abbr_width = 0
			" let g:deoplete#max_menu_width = 0
			let g:deoplete#omni#input_patterns = get(g:,'deoplete#omni#input_patterns',{})
			let g:deoplete#omni#input_patterns.java = [
						\'[^. \t0-9]\.\w*',
						\'[^. \t0-9]\->\w*',
						\'[^. \t0-9]\::\w*',
						\]
			let g:deoplete#omni#input_patterns.jsp = ['[^. \t0-9]\.\w*']
			let g:deoplete#omni#input_patterns.php = '\h\w*\|[^. \t]->\%(\h\w*\)\?\|\h\w*::\%(\h\w*\)\?'
			let g:deoplete#ignore_sources = {}
			let g:deoplete#ignore_sources.java = ['omni']
			let g:deoplete#ignore_sources.c = ['omni']
			let g:deoplete#ignore_sources._ = ['around']
			"call deoplete#custom#set('omni', 'min_pattern_length', 0)
			inoremap <expr><C-h> deoplete#mappings#smart_close_popup()."\<C-h>"
			inoremap <expr><BS> deoplete#mappings#smart_close_popup()."\<C-h>"
			" Regular settings
			inoremap <silent><expr> <TAB>
						\ pumvisible() ? "\<C-n>" :
						\ <SID>check_back_space() ? "\<TAB>" :
						\ deoplete#mappings#manual_complete()
			function! s:check_back_space() abort
				let col = col('.') - 1
				return !col || getline('.')[col - 1]  =~ '\s'
			endfunction
			" ----------------------------------------------
		"  deoplete-clang
		if exists('g:libclang_path') && exists('g:clangheader_path')
			Plug 'zchee/deoplete-clang'
			let g:deoplete#sources#clang#libclang_path = g:libclang_path
			let g:deoplete#sources#clang#clang_header = g:clangheader_path
		endif

		" and jedi for autocompletion, `pip install jedi --user`
		Plug 'zchee/deoplete-jedi'
	endif
	Plug 'Shougo/neco-vim' " Sources for deoplete/neocomplete to autocomplete vim variables and functions
	Plug 'Shougo/echodoc' " Pop for functions info
endfunction

function! autocompletion#SetTab() abort
	Plug 'ervandew/supertab' " Activate Supertab
	let g:SuperTabDefaultCompletionType = "context"
	if has('python') && executable('clang')
		Plug 'Rip-Rip/clang_complete', { 'as': 'rip_clang_complete' }
		call autocompletion#SetClang()
	endif
endfunction
