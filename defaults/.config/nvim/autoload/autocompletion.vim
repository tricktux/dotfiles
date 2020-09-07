" File:autocompletion.vim
" Description: Choose and setup autocompletion engine
" Author:Reinaldo Molina <rmolin88@gmail.com>
" Version:2.0.0
" Last Modified:		Wed Apr 04 2018 16:01
" Original Modified: Apr 04 2017 23:58

function! autocompletion#SetCompl(compl) abort
	let s:completion_choice = a:compl
	if a:compl ==# 'ycm'
		call s:set_ycm()
	elseif a:compl ==# 'completion_nvim'
    call s:set_completion_lua()
    " call s:set_nvim_lsp()
    call s:set_neosnippets()
  elseif a:compl ==# 'nvim_compl_manager'
		" call s:set_ncm()
		call s:set_ncm2()
		" call s:set_ulti_snips()
		if has('nvim-0.5.0') && get(g:, 'ncm2_supports_lsp', 0)
			call s:set_nvim_lsp()
		else
			" Tue Feb 25 2020 13:33 
			" No sense in enabling for windows
			if has('unix')
				call s:set_language_client(has('unix'))
			endif
		endif
		call s:set_neosnippets()
		Plug 'ncm2/ncm2-neosnippet'
  elseif a:compl ==# 'shuogo_deo'
    call s:set_shuogo_deo_neo_options()
    " if has('unix')
      " call s:set_language_client(has('unix'))
    " endif
    call s:set_shuogo_sources()
    call s:set_neosnippets()
  elseif a:compl ==# 'shuogo_neo'
    call s:set_shuogo_neo()
    call s:set_shuogo_sources()
    call s:set_neosnippets()
    " call s:set_vim_clang()
    " Wed Apr 04 2018 16:33: Without a compile_commands.json lsp is useless for clangd
    " Do not setup clangd on windows
    " if !has('unix') | call s:set_clang_compl('rip_clang_complete') | endif
	elseif a:compl ==# 'autocomplpop'
		Plug 'vim-scripts/AutoComplPop'
		inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
		inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
		call s:set_clang_compl('rip_clang_complete')
	elseif a:compl ==# 'completor'
		if v:version < 800 || !has('python3')
			echomsg 'autocompletion#SetCompl(): Cannot set completor autcompl_engine. Setting SuperTab'
			call s:set_tab()
			return
		endif
		Plug 'maralla/completor.vim'
		inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
		inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
		inoremap <expr> <cr> pumvisible() ? "\<C-y>\<cr>" : "\<cr>"
		let g:completor_clang_binary = 'c:/Program Files/LLVM/bin/clang.exe'
	elseif a:compl ==# 'asyncomplete'
		call s:set_async()
	elseif a:compl ==# 'neo_clangd'
		let g:clangd#completions_enabled = 0
		call s:set_shuogo()
		call s:set_clangd_lsp()
	elseif a:compl ==# 'coc'
		call s:set_coc_nvim()
	else
		echomsg 'autocompletion#SetCompl(): Not a recognized value therefore setting SuperTab'
		call s:set_tab()
		return -1
	endif
	return 1
endfunction

" Settings for Rip-Rip/clang_complete and friends
function! s:set_clang_compl(type) abort
	if !has('python3') || !executable('clang++')
		echomsg 's:set_clang_compl(): Clang not installed or no python'
		return
	endif

	if a:type ==# 'rip_clang_complete'
		Plug 'Rip-Rip/clang_complete'
	elseif a:type ==# 'roxma_clang_complete'
		Plug 'roxma/clang_complete'
	else
		echomsg 's:set_clang_compl(): Not a recognized clang_complete type'
	endif

	let g:omnifunc_clang ='ClangComplete'
	" Why I switched to Rip-Rip because it works
	" Steps to get plugin to work:
	" 1. Make sure that you can compile a program with clang++ command
	" a. Example: clang++ -std=c++14 -stdlib=libc++ -pedantic -Wall hello.cpp -v
	" 2. To get this to work I had to install libc++-dev package in unix
	" 3. install libclang-dev package. See g:clang_library_path to where it gets
	" installed. Also I had to make sym link: ln -s libclang.so.1 libclang.so
	let g:clang_user_options = '-std=c++14 -stdlib=libc++ -Wall -pedantic'
	let g:clang_close_preview = 1
	let g:clang_make_default_keymappings = 0
	let g:clang_snippets = 1
	let g:clang_snippets = 'clang_complete'

	augroup close_complete
		autocmd!
		autocmd CompleteDone * pclose!
	augroup END
	" let g:clang_complete_copen = 1
	" let g:clang_periodic_quickfix = 1
	" let g:clang_complete_auto = 0
	if has('win32')
		" clang using mscv for target instead of mingw64
		let g:clang_cpp_options = '-target x86_64-pc-windows-gnu -std=c++17 -pedantic -Wall'
		let g:clang_c_options = '-target x86_64-pc-windows-gnu -std=gnu11 -pedantic -Wall'
	else
		if exists('g:libclang_path') && !empty(glob(g:libclang_path))
			let g:clang_library_path= g:usr_path . '/lib/libclang.so'
		else
			echomsg "s:set_clang_compl(): g:usr_path not set or libclang not existent"
		endif
	endif
endfunction

function! s:set_shuogo_neo() abort
	" Vim exclusive plugins
	" Wed Sep 19 2018 11:13: I dont normally install lua on my pcs. Therefore, this
	" wouldnt be recognized 
	if !has('lua') " Neocomplete
		echomsg 's:set_shuogo_neo(): Lua53 not installed'
		return
	endif

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
	let g:neocomplete#data_directory = g:std_cache_path . '/neocomplete'
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
endfunction

function! s:set_tab() abort
	Plug 'ervandew/supertab' " Activate Supertab
	let g:SuperTabDefaultCompletionType = "context"
	if has('python') && executable('clang')
		call s:set_clang_compl('rip_clang_complete')
	endif
endfunction

function! s:set_omni_cpp() abort
	Plug 'vim-scripts/OmniCppComplete'
	let g:OmniCpp_NamespaceSearch = 1
	let g:OmniCpp_GlobalScopeSearch = 1
	let g:OmniCpp_ShowAccess = 1
	let g:OmniCpp_ShowPrototypeInAbbr = 1 " show function parameters
	let g:OmniCpp_MayCompleteDot = 1 " autocomplete after .
	let g:OmniCpp_MayCompleteArrow = 1 " autocomplete after ->
	let g:OmniCpp_MayCompleteScope = 1 " autocomplete after ::
	let g:OmniCpp_DefaultNamespaces = ["std", "_GLIBCXX_STD"]
endfunction

function! s:set_async_compl() abort
	if exists('*asyncomplete#register_source')
		call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
					\ 'name': 'buffer',
					\ 'whitelist': ['*'],
					\ 'blacklist': ['go'],
					\ 'completor': function('asyncomplete#sources#buffer#completor'),
					\ }))
		call asyncomplete#register_source(asyncomplete#sources#necosyntax#get_source_options({
					\ 'name': 'necosyntax',
					\ 'whitelist': ['*'],
					\ 'completor': function('asyncomplete#sources#necosyntax#completor'),
					\ }))
		call asyncomplete#register_source(asyncomplete#sources#necovim#get_source_options({
					\ 'name': 'necovim',
					\ 'whitelist': ['vim'],
					\ 'completor': function('asyncomplete#sources#necovim#completor'),
					\ }))
		call asyncomplete#register_source(asyncomplete#sources#neosnippet#get_source_options({
					\ 'name': 'neosnippet',
					\ 'whitelist': ['*'],
					\ 'completor': function('asyncomplete#sources#neosnippet#completor'),
					\ }))
		if has('python3')
			call asyncomplete#register_source(asyncomplete#sources#ultisnips#get_source_options({
						\ 'name': 'ultisnips',
						\ 'whitelist': ['*'],
						\ 'completor': function('asyncomplete#sources#ultisnips#completor'),
						\ }))
		endif
	else
		echomsg "s:set_async_compl(): AsynComplete not installed yet"
	endif
endfunction

" Fri Sep 29 2017 12:22: This plugin is still not ready
function! s:set_clangd_lsp() abort
	if !has('python3') || !executable('clangd')
		echomsg 'autocompoletion#SetClangdLSP(): Clangd not installed or no python'
		return
	endif

	Plug 'Chilledheart/vim-clangd'
	let g:clangd#codecomplete_timeout = 500
	let g:omnifunc_clang ='clangd#OmniCompleteAt'
endfunction

function! s:set_mutt_omni_wrap(findstart, base) abort
	let l:ret = muttaliases#CompleteMuttAliases(a:findstart, a:base)
	if type(l:ret) == type([])
		let i=0
		while i<len(l:ret)
			let l:ret[i]['snippet'] = l:ret[i]['word']
			let l:ret[i]['word'] = l:ret[i]['abbr']
			let i+=1
		endwhile
	endif
	return l:ret
endfunction

function! s:set_language_client(has_unix) abort
	" New version simply broke down. Try the `next` branch from time to time
        " \ 'tag': '0.1.155',
	Plug 'autozimu/LanguageClient-neovim', {
      \ 'branch': 'next',
			\ 'do': has('unix') ? 'bash install.sh' :
			\   'powershell -executionpolicy bypass -File install.ps1',
			\ }

	" Wed Apr 04 2018 16:25: clangd depends on a compile_commands.json databse.
	" If you can't generate that. Then its no use.
	let g:LanguageClient_autoStart = 1
	let g:LanguageClient_serverCommands = {}
	let g:LanguageClient_diagnosticsList = 'Location'
	" Multi-entry selection UI. FZF
	" Setup servers
	" Java server
	" arch: install jdtls

	" C++ server
	" Sat Jan 27 2018 11:11: Settings coming from:
	" https://github.com/cquery-project/cquery/wiki/Neovim
	" Wed Apr 04 2018 16:21 All these settings are for cquery
	" Wed Apr 04 2018 17:02: the cquery project has an excellent page on generating
	" compile_commands.json on its wiki
	" let g:LanguageClient_loadSettings = 1 " Use an absolute configuration path if you want system-wide settings
	" let g:LanguageClient_settingsPath = g:std_config_path . '/settings.json'
	let l:cquery = [ 'cquery', '--language-server', '--log-file=/tmp/cq.log' ]
	let l:clangd_args = [
				\		'clangd', 
				\		'--all-scopes-completion=true', 
				\		'--background-index=true',
				\		'--clang-tidy=true',
				\		'--completion-style=detailed',
				\		'--fallback-style="LLVM"',
				\		'--pch-storage=memory',
				\		'--suggest-missing-includes',
				\		'--header-insertion=iwyu',
				\		'-j=12',
				\		'--header-insertion-decorators=false',
				\ ]
  let l:lua_language_server = [
        \ 'lua-language-server'
        \ ]
  let l:jdtls = [
        \ 'jdtls'
        \ ]
  let l:pyls = [
        \ 'pyls'
        \ ]
  let l:cmake_language_server = [
        \ 'cmake-language-server'
        \ ]

  let l:chosen_cmake_server = {
        \ 'cmake': l:cmake_language_server
        \ }
  let l:chosen_java_server = {
        \ 'java': l:jdtls
        \ }
  let l:chosen_python_server = {
        \ 'python3': l:pyls,
        \ 'python':  l:pyls,
        \ }
  let l:chosen_lua_server = {
        \ 'lua' : l:lua_language_server
        \ }
	let l:chosen_cpp_server = {
				\ 'cpp': l:clangd_args,
				\ 'c': l:clangd_args,
				\ }

	" Tue Aug 07 2018 16:41: There is a new cpp player in town. `ccls`. Based of 
	" `cquery` 
	if executable(l:chosen_cpp_server.cpp[0]) && a:has_unix
		call extend(g:LanguageClient_serverCommands, l:chosen_cpp_server)
	endif

	if executable(l:chosen_python_server.python3[0])
		call extend(g:LanguageClient_serverCommands, l:chosen_python_server)
	endif

	if executable(l:chosen_java_server.java[0])
		call extend(g:LanguageClient_serverCommands, l:chosen_java_server)
	endif

  if executable(l:chosen_lua_server.lua[0])
    call extend(g:LanguageClient_serverCommands, l:chosen_lua_server)
  endif
  " Mon Apr 27 2020 05:06: Does not really do anything 
  " if executable(l:chosen_cmake_server.cmake[0])
    " call extend(g:LanguageClient_serverCommands, l:cmake_language_server)
  " endif

	let g:LanguageClient_hasSnippetSupport = 1
	" let g:LanguageClient_useVirtualText = 1 " new version uses enum instead of 
	" boolean
	let g:LanguageClient_virtualTextPrefix = ' > '

	let g:LanguageClient_completionPreferTextEdit = 1
	if exists('g:lightline')
		let g:lightline.active.left[2] += [ 'lsp' ]
		let g:lightline.component_function['lsp'] = 'LanguageClient#statusLine'
	endif
	return 1
endfunction

function! autocompletion#AdditionalLspSettings() abort
	if (!exists('s:completion_choice') && !empty(s:completion_choice))
		if &verbose > 0
			echoerr 'Missing s:completion_choice variable'
		endif
		return
	endif

	if s:completion_choice ==# 'nvim_compl_manager'
		if has('nvim-0.5.0') && get(g:, 'ncm2_supports_lsp', 0)
			return <sid>set_nvim_lsp_mappings()
		else
			return <sid>set_language_client_mappings()
		endif
  endif
  if s:completion_choice ==# 'coc'
		return <sid>set_coc_nvim_mappings()
  endif
  if s:completion_choice ==# 'shuogo_deo'
    return <sid>set_language_client_mappings()
  endif
  if s:completion_choice ==# 'completion_nvim' && get(g:, 'nvim_lsp_support', 0)
    return <sid>set_nvim_lsp_mappings()
	endif
endfunction

function! s:set_language_client_mappings() abort
	if !exists('g:LanguageClient_serverCommands')
		if &verbose > 0
			echoerr 'LanguageClient plugin not installed'
		endif
		return
	endif

	let l:key = get(g:LanguageClient_serverCommands, &filetype, '')
	if empty(l:key)
		if &verbose > 0
			echoerr 'LanguageClient server for ' . &filetype . ' not defined'
		endif
		return
	endif

	if !executable(get(l:key, 0, ''))
		if &verbose > 0
			echoerr 'LanguageClient server for ' .
						\ &filetype . ': ' .get(l:key, 0, ''). ' not executable'
		endif
		return
	endif

	nnoremap <buffer> <localleader>ld
				\ :call LanguageClient#textDocument_definition()<CR>
	nnoremap <buffer> <localleader>lD
				\ :call LanguageClient#textDocument_typeDefinition()<CR>
	nnoremap <buffer> <localleader>lh
				\ :call LanguageClient#textDocument_hover()<CR>
	nnoremap <buffer> <localleader>lf
				\ :call LanguageClient#textDocument_formatting()<cr>
	nnoremap <buffer> <localleader>lR
				\ :call LanguageClient#textDocument_references()<CR>
	nnoremap <buffer> <localleader>ls
				\ :call LanguageClient#textDocument_documentSymbol()<CR>
	nnoremap <buffer> <localleader>lr
				\ :call LanguageClient#textDocument_rename()<CR>
	nnoremap <buffer> <localleader>lc
				\ :call LanguageClient_contextMenu()<CR>
	nnoremap <buffer> <localleader>li
				\ :call LanguageClient#textDocument_implementation()<CR>
	nnoremap <buffer> <localleader>la
				\ :call LanguageClient#textDocument_codeAction()<CR>
endfunction

function! s:set_vim_clang() abort
	if !executable('clang++')
		echomsg 's:set_clang_compl(): Clang not installed'
		return
	endif
	Plug 'justmao945/vim-clang'
	let g:clang_auto = 1
	" let g:clang_debug = 4
	let g:clang_diagsopt = ''
	let g:clang_c_completeopt = 'menuone,longest,preview,noselect,noinsert'
	let g:clang_cpp_completeopt = 'menuone,longest,preview,noselect,noinsert'
	if has('win32')
		" clang using mscv for target instead of mingw64
		let g:clang_cpp_options = '-target x86_64-pc-windows-gnu -std=c++17 -pedantic -Wall'
		let g:clang_c_options = '-target x86_64-pc-windows-gnu -std=gnu11 -pedantic -Wall'
	else
		if exists('g:libclang_path') && !empty(glob(g:libclang_path))
			let g:clang_library_path= g:usr_path . '/lib/libclang.so'
		else
			echomsg "s:set_clang_compl(): g:usr_path not set or libclang not existent"
		endif
	endif
endfunction

function! s:set_neosnippets() abort
	Plug 'Shougo/neosnippet'
	imap <plug>snip_expand <Plug>(neosnippet_expand_or_jump)
	smap <plug>snip_expand <Plug>(neosnippet_expand_or_jump)
	xmap <plug>snip_expand <Plug>(neosnippet_expand_target)
	smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
				\ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
	" Tell Neosnippet about the other snippets
	let g:neosnippet#snippets_directory= [
				\ g:vim_plugins_path . '/vim-snippets/snippets',
				\ g:std_config_path . '/snippets/',
				\ ]
	" Fri Oct 20 2017 21:47: Not really data but cache
	let g:neosnippet#data_directory = g:std_cache_path . '/neosnippets'
	" Used by nvim-completion-mgr
	let g:neosnippet#enable_completed_snippet=1
	" Tue Jan 14 2020 20:29: For language client completion 
  let g:neosnippet#enable_complete_done = 0

	" Only contain snippets
	Plug 'Shougo/neosnippet-snippets'
	Plug 'honza/vim-snippets'
	let g:snips_author = 'Reinaldo Molina'
	let g:snips_email = 'rmolin88 at gmail dot com'
	let g:snips_github = 'rmolin88'
endfunction

function! s:set_ncm() abort
	" Optional but useful python3 support
	" pip3 install --user neovim jedi mistune psutil setproctitle
	" if has('win32')
	" call s:set_tab()
	" return -1
	" endif

	if !has('nvim') || !has('python3')
		echomsg 'nvim_compl_manager doesnt work with vim or you do not have python3'
		return
	endif

	if has('unix')
		" Plug 'autozimu/LanguageClient-neovim', { 'do': ':UpdateRemotePlugins' }
		" let g:LanguageClient_serverCommands = {
		" \ 'cpp': ['clangd'],
		" \ }
		" let g:LanguageClient_autoStart = 1
		" ncm's filtering is based on word, so it's better to convert results of
		" muttaliases#CompleteMuttAliases into snippet expension
		augroup NCM
			autocmd!
			autocmd User CmSetup call cm#register_source({'name' : 'mutt',
						\ 'priority': 9,
						\ 'cm_refresh_length': -1,
						\ 'cm_refresh_patterns': ['^\w+:\s+'],
						\ 'cm_refresh': {'omnifunc': function('s:set_mutt_omni_wrap')},
						\ })
		augroup END
	endif

	Plug 'roxma/nvim-completion-manager'
	" nvim-completion-manager also added suppport for this
	" Sources for deoplete/neocomplete to autocomplete vim variables and functions
	Plug 'Shougo/neco-vim'
	Plug 'Shougo/neco-syntax'
	" Thu Jul 20 2017 21:02: Causes nvim_compl_manager to freeze
	" Plug 'Shougo/neoinclude.vim'
	" Sat Oct 26 2019 05:32: Crashes all the time
	" Plug 'roxma/ncm-github'
	Plug 'Shougo/echodoc.vim'
	" Plug 'roxma/ncm-clang'

	inoremap <expr> <CR> (pumvisible() ? "\<c-y>\<cr>" : "\<CR>")
	inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
	" if has('unix') " Automatic completion on unix
	inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
	" let g:cm_auto_popup = 1
	" else " but not anywhere else
	" let g:cm_auto_popup = 0
	" imap <silent> <Tab> <Plug>(cm_force_refresh)
	" endif

	call s:set_clang_compl('roxma_clang_complete')
endfunction

function! s:set_ncm2() abort
	Plug 'ncm2/ncm2'
	" ncm2 requires nvim-yarp
	Plug 'roxma/nvim-yarp'

	if !has('nvim')
		Plug 'roxma/vim-hug-neovim-rpc'
	endif

	augroup ncm_buff
		autocmd!
		autocmd BufEnter * call ncm2#enable_for_buffer()
	augroup END
	
	set completeopt+=noinsert

	inoremap <expr> <CR> (pumvisible() ? "\<c-y>\<cr>" : "\<CR>")
	inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
	inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

	Plug 'ncm2/ncm2-bufword'
	Plug 'ncm2/ncm2-path'
	if (has('unix'))
		" Thu Aug 01 2019 16:08
		" Nice to have plugin. We dont need to be making too many http requests 
		" on the work computer
		Plug 'ncm2/ncm2-github'
		if (executable('look'))
			Plug 'filipekiss/ncm2-look.vim'
		endif
	endif
	if (has('win32')) " Unix uses LSP
		Plug 'ncm2/ncm2-jedi'
	endif
	Plug 'ncm2/ncm2-vim'
		Plug 'Shougo/neco-vim' " Sources for deoplete/neocomplete to
		" autocomplete vim variables and functions
	Plug 'ncm2/ncm2-syntax'
		Plug 'Shougo/neco-syntax' " Sources for deoplete/neocomplete to
		" autocomplete vim variables and functions
	" Plug 'ncm2/ncm2-neoinclude'
	
	if exists('##CompleteChanged')
		Plug 'ncm2/float-preview.nvim'
	endif

	if !has('nvim') || has('unix')
		Plug 'ncm2/ncm2-match-highlight'
			let g:ncm2#match_highlight = 'bold'
	endif
	" Fenced code block detection in markdown files for ncm2
	Plug 'ncm2/ncm2-markdown-subscope'
	Plug 'ncm2/ncm2-tagprefix'
	if executable('tmux')
		Plug 'ncm2/ncm2-tmux'
	endif

	" Sun Apr 21 2019 23:03: When the LanguageClient is available we dont really 
	" need this
	if executable('clang') && !has('unix')
		" For C++
		Plug 'ncm2/ncm2-pyclang'
		" let g:ncm2_pyclang#library_path = "\"C:\\Program 
		" Files\\LLVM\\bin\\libclang.dll\""
		if has('unix')
			let g:ncm2_pyclang#library_path = '/usr/lib/libclang.so'
			let g:ncm2_pyclang#database_path = [
						\ 'compile_commands.json',
						\ 'build/compile_commands.json',
						\ 'builddir/compile_commands.json'
						\ ]
		else
			let g:ncm2_pyclang#library_path = 'C:\Program Files\LLVM\bin\libclang.dll'
		endif
	endif
endfunction

function! s:set_ulti_snips() abort
	Plug 'ncm2/ncm2-ultisnips'
	Plug 'SirVer/ultisnips'
	Plug 'honza/vim-snippets'

	inoremap <silent> <expr> <CR> (
				\ (pumvisible() && empty(v:completed_item)) ?  
				\ "\<c-y>\<cr>" : 
				\ (!empty(v:completed_item) ?
				\ ncm2_ultisnips#expand_or("", 'n') : "\<CR>" )
				\ )
	let g:UltiSnipsSnippetDirectories= [
				\ g:vim_plugins_path . '/vim-snippets/snippets',
				\ g:std_config_path . '/snippets/',
				\ ]

	" c-j c-k for moving in snippet
	" imap <plug>snip_expand :call ncm2_ultisnips#completed_is_snippet()<cr>
	imap <expr> <plug>snip_expand
				\ ncm2_ultisnips#expand_or("\<Plug>(ultisnips_expand)", 'm')
	smap <plug>snip_expand <Plug>(ultisnips_expand)
	
	let g:UltiSnipsExpandTrigger		= "<Plug>(snip_expand)"
	let g:UltiSnipsJumpForwardTrigger	= "<c-j>"
	let g:UltiSnipsJumpBackwardTrigger	= "<c-k>"
	let g:UltiSnipsRemoveSelectModeMappings = 0
endfunction

function! s:set_ycm() abort
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
endfunction

" Used by async
function! s:check_back_space() abort
	let col = col('.') - 1
	return !col || getline('.')[col - 1]  =~# '\s'
endfunction

function! s:set_async() abort
	if v:version < 800
		echomsg
					\ 'autocompletion#SetCompl(): Cannot set AsynComplete autcompl_engine. Setting SuperTab'
		call s:set_tab()
		return
	endif

	Plug 'prabirshrestha/asyncomplete.vim'
	" Tab Completion
	inoremap <silent><expr> <TAB>
				\ pumvisible() ? "\<C-n>" :
				\ <SID>check_back_space() ? "\<TAB>" :
				\ asyncomplete#force_refresh()
	inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
	inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<cr>"
	" Buffer
	Plug 'prabirshrestha/asyncomplete-buffer.vim'
	" Syntax
	Plug 'Shougo/neco-syntax'
	Plug 'prabirshrestha/asyncomplete-necosyntax.vim'
	" Vim
	Plug 'Shougo/neco-vim'
	Plug 'prabirshrestha/asyncomplete-necovim.vim'
	Plug 'prabirshrestha/asyncomplete-neosnippet.vim'
	if has('python3')
		Plug 'prabirshrestha/asyncomplete-ultisnips.vim'
	endif
	call s:set_clang_compl('rip_clang_complete')

	augroup AsynComplete
		autocmd!
		autocmd User asyncomplete_setup call s:set_async_compl()
	augroup END
endfunction

function! s:set_shuogo_sources() abort
	" List of sources Plugins
	" and jedi for autocompletion, `pip install jedi --user`
	Plug 'Shougo/neco-vim' " Sources for deoplete/neocomplete to autocomplete vim variables and functions
	Plug 'Shougo/neco-syntax' " Sources for deoplete/neocomplete to autocomplete vim variables and functions
	" Plug 'Shougo/echodoc.vim' " Pop for functions info
		" let g:echodoc#enable_at_startup = 1
		" let g:echodoc#type = 'echo'

	" Mon Jan 15 2018 05:55: Not working very well
	" Plug 'SevereOverfl0w/deoplete-github' " Pop for functions info
	" Plug 'fszymanski/deoplete-emoji' " Pop for functions info
	" Email Completion, Has a bug that I need to report
	" Plug 'fszymanski/deoplete-abook'
	Plug 'Shougo/context_filetype.vim'
	" Tue Oct 31 2017 08:54: Going to attempt to use the other clang
	"  deoplete-clang
	" if exists('g:libclang_path') && exists('g:clangheader_path')
	" Plug 'zchee/deoplete-clang'
	" let g:deoplete#sources#clang#libclang_path = g:libclang_path
	" let g:deoplete#sources#clang#clang_header = g:clangheader_path
	" endif
  if exists('##CompleteChanged')
    Plug 'ncm2/float-preview.nvim'
  endif
  Plug 'zchee/deoplete-zsh', { 'for' : 'zsh' }
  Plug 'Shougo/deoplete-lsp'
  Plug 'neovim/nvim-lspconfig'
  let g:nvim_lsp_support = 1
  " if has('win32')
    " Plug 'deoplete-plugins/deoplete-jedi', { 'for' : 'python' }
    " Plug 'Shougo/deoplete-clangx'
    " " Super slow plugin
    " " Plug 'Shougo/neoinclude.vim/'
  " else
  " endif

  " This source didnt really work
	let l:address_book_loc = '~/.config/neomutt/data/addressbook'
	if (filereadable(expand(l:address_book_loc)))
    " This plugin expects abook format abook
		" Sample command:
		" abook --convert --informat mutt --infile ~/.config/neomutt/data/aliases.txt \
		"		--outformat abook --outfile ~/.abook/addressbook
		Plug 'fszymanski/deoplete-abook', { 'for' : 'mail' }
			let g:deoplete#sources#abook#datafile = expand(l:address_book_loc)
	endif
endfunction

function! s:set_shuogo_deo_neo_options() abort
  if !has('python3')
    echomsg 's:set_shuogo_deo_neo_options(): Python3 not installed'
    return
  endif

  Plug 'Shougo/deoplete.nvim'
  if !has('nvim')
    " Requirements For Vim 8:
    " - roxma/vim-hug-neovim-rpc
    " - g:python3_host_prog pointed to your python3 executable, or echo exepath('python3') is not empty.
    " - neovim python client (pip3 install pynvim)
    Plug 'roxma/nvim-yarp'
    Plug 'roxma/vim-hug-neovim-rpc'
    let g:deoplete#enable_yarp = 1
  endif

  let g:deoplete#enable_at_startup = 1
  inoremap <expr><C-h> deoplete#smart_close_popup()."\<C-h>"
  inoremap <expr><BS> deoplete#smart_close_popup()."\<C-h>"
  " Regular settings
  inoremap <silent><expr> <TAB>
        \ pumvisible() ? "\<C-n>" :
        \ <SID>check_back_space() ? "\<TAB>" :
        \ deoplete#mappings#manual_complete()

  augroup CompleteionTriggerCharacter
    autocmd!
    autocmd CompleteDone * if pumvisible() == 0 | pclose | endif
  augroup end
endfunction

function! s:set_shuogo_deo() abort
	if !has('python3')
		echomsg 's:set_shuogo_deo(): Python3 not installed'
		return
	endif

	Plug 'Shougo/deoplete.nvim'
	if !has('nvim')
		" Requirements For Vim 8:
		" - roxma/vim-hug-neovim-rpc
		" - g:python3_host_prog pointed to your python3 executable, or echo exepath('python3') is not empty.
		" - neovim python client (pip3 install pynvim)
		Plug 'roxma/nvim-yarp'
		Plug 'roxma/vim-hug-neovim-rpc'
		let g:deoplete#enable_yarp = 1
	endif

  " If it is nvim deoplete requires python3 to work
  let g:deoplete#enable_at_startup = 1
	" Mon Jan 08 2018 14:49: New options:
	" - They seem to be working. Specially the enable_yarp one.
	let g:deoplete#auto_complete_start_length = 3
	let g:deoplete#max_abbr_width = 18
	" let g:deoplete#max_menu_width = 18
	" Note: If you get autocomplete autotriggering issues keep increasing this option below.
	" Next value to try is 150. See:https://github.com/Shougo/deoplete.nvim/issues/440
	" let g:deoplete#auto_complete_delay=15 " Fixes issue where Autocompletion triggers
	let g:deoplete#auto_complete_delay=50 " Fixes issue where Autocompletion triggers

	" New settings
	let g:deoplete#enable_ignore_case = 1
	let g:deoplete#enable_smart_case = 1
	" let g:deoplete#enable_camel_case = 1
	" Note: Changed this here to increase speed
	let g:deoplete#enable_refresh_always = 0
	let g:deoplete#max_list = 18
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
endfunction

function! s:set_coc_nvim() abort
	" Use tab for trigger completion with characters ahead and navigate.
	" Use command ':verbose imap <tab>' to make sure tab is not mapped by 
	" other plugin.
	if (!has('unix'))
		echoerr 'Wrong autocompletion engine selected!!!'
		return
	endif

	" Extensions that need to be installed
	" NOTE: coc-snippets is another
	Plug 'neoclide/coc-json'
	Plug 'iamcco/coc-vimlsp'
	Plug 'neoclide/coc-highlight'
	Plug 'neoclide/coc-python'
	Plug 'neoclide/coc-java'
	
	" Sources
	Plug 'zidhuss/coc-lbdbq'
	Plug 'Shougo/neco-vim'
	Plug 'neoclide/coc-neco'
	Plug 'neoclide/coc-sources'
	Plug 'neoclide/coc.nvim', {'tag': '*', 'do': './install.sh'}

	inoremap <silent><expr> <TAB>
				\ pumvisible() ? "\<C-n>" :
				\ <SID>check_back_space() ? "\<TAB>" :
				\ coc#refresh()
	inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

	" Use <c-space> to trigger completion.
	inoremap <silent><expr> <c-space> coc#refresh()

	if exists('g:lightline')
		let g:lightline.active.left[2] += [ 'cocstatus' ]
		let g:lightline.component_function['cocstatus'] = 'coc#status'
	endif
endfunction

function! s:set_coc_snippets() abort
	" TODO add custom snippets folder. see: set_neosnippets
	Plug 'neoclide/coc-snippets'
	Plug 'Shougo/neosnippet-snippets'
	Plug 'honza/vim-snippets'

	imap <plug>snip_expand <plug>(coc-snippets-expand-jump)
	vmap <plug>snip_expand <plug>(coc-snippets-select)
	" xmap <plug>snip_expand <plug>(neosnippet_expand_target)
	" Use <C-j> for jump to next placeholder, it's default of coc.nvim
	let g:coc_snippet_next = '<c-k>'

	" Use <C-k> for jump to previous placeholder, it's default of coc.nvim
	let g:coc_snippet_prev = '<c-j>'
	inoremap <silent><expr> <TAB>
				\ pumvisible() ? coc#_select_confirm() :
				\ coc#expandableOrJumpable() ?
				\ "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
				\ <sid>check_back_space() ? "\<TAB>" :
				\ coc#refresh()
	let g:snips_author = 'Reinaldo Molina'
	let g:snips_email = 'rmolin88 at gmail dot com'
	let g:snips_github = 'rmolin88'
endfunction

function! s:set_coc_nvim_mappings() abort
	nmap <buffer> <localleader>d <Plug>(coc-definition)
	nmap <buffer> <localleader>lh 
				\ :call <sid>coc_show_documentation()<cr>
	nmap <buffer> <localleader>lR <plug>(coc-references)
	nmap <buffer> <localleader>lr <plug>(coc-rename)
	nmap <buffer> <localleader>lf <plug>(coc-format-selected)
	xmap <buffer> <localleader>lf <plug>(coc-format-selected)
	" nmap <buffer> <localleader>ls
				" \ :call LanguageClient#textDocument_documentSymbol()<CR>
	
	augroup CocHighlight
		" this one is which you're most likely to use?
		autocmd CursorHold * silent call CocActionAsync('highlight')
	augroup end
endfunction

function! s:coc_show_documentation()
	if (index(['vim','help'], &filetype) >= 0)
		execute 'h '.expand('<cword>')
	else
		call CocAction('doHover')
	endif
endfunction

function! autocompletion#SetOmniSharp() abort
	Plug 'OmniSharp/omnisharp-vim'

	" Use the stdio OmniSharp-roslyn server
	let g:OmniSharp_server_stdio = 1

	" Timeout in seconds to wait for a response from the server
	let g:OmniSharp_timeout = 5

	" Update semantic highlighting on BufEnter and InsertLeave
	let g:OmniSharp_highlight_types = 2

	" Enable snippet completion
	" let g:OmniSharp_want_snippet=1

	if exists(':Files')
		let g:OmniSharp_selector_ui = 'fzf'
	elseif exists(':CltrP')
		let g:OmniSharp_selector_ui = 'ctrlp'
	else
		let g:OmniSharp_selector_ui = ''
	endif
endfunction

function! s:set_nvim_lsp() abort
	Plug 'neovim/nvim-lsp'

  let g:nvim_lsp_support = 1
endfunction


" Called from afterconfig plugin
function! autocompletion#SetNvimLsp() abort
lua << EOF
local nvim_lsp = require'nvim_lsp'
nvim_lsp.pyls.setup{
  on_attach=require'completion'.on_attach,
  filetypes= "py",
  root_dir= nvim_lsp.utils.root_pattern(".git", ".svn")
  -- root_dir=get_curr_dir() 
}
nvim_lsp.clangd.setup{
  on_attach=require'completion'.on_attach,
	cmd = { 
			 "clangd", 
			 "--all-scopes-completion=true", 
			 "--background-index=true",
			 "--clang-tidy=true",
			 "--completion-style=detailed",
			 "--fallback-style=\"LLVM\"",
			 "--pch-storage=memory",
			 "--suggest-missing-includes",
			 "--header-insertion=iwyu",
			 "-j=12",
			 "--header-insertion-decorators=false"
		},
  filetypes= { "c", "cpp" },
  root_dir= nvim_lsp.utils.root_pattern(".git", ".svn")
  -- root_dir=get_curr_dir()
}
EOF
endfunction

function! autocompletion#set_nvim_lsp_mappings() abort
	" This doesnt work. Set omnifunc from augroups
	" set omnifunc=v:lua.vim.lsp.omnifunc
	nnoremap <silent> <buffer> <localleader>lr <cmd>lua vim.lsp.buf.rename()<cr>
	nnoremap <silent> <buffer> <localleader>le <cmd>lua vim.lsp.buf.declaration()<cr>
	nnoremap <silent> <buffer> <localleader>ld <cmd>lua vim.lsp.buf.definition()<cr>
	nnoremap <silent> <buffer> <localleader>lh <cmd>lua vim.lsp.buf.hover()<cr>
	nnoremap <silent> <buffer> <localleader>li <cmd>lua vim.lsp.buf.implementation()<cr>
	nnoremap <silent> <buffer> <localleader>lH <cmd>lua vim.lsp.buf.signature_help()<cr>
	nnoremap <silent> <buffer> <localleader>lD <cmd>lua vim.lsp.buf.type_definition()<cr>
	nnoremap <silent> <buffer> <localleader>lR <cmd>lua vim.lsp.buf.references()<cr>
	nnoremap <silent> <buffer> <localleader>lf <cmd>lua vim.lsp.buf.formatting()<cr>
	nnoremap <silent> <buffer> <localleader>lS <cmd>lua vim.lsp.stop_all_clients()<cr>
endfunction

function! s:set_completion_lua() abort
  Plug 'nvim-lua/completion-nvim'
  Plug 'neovim/nvim-lspconfig'
  Plug 'steelsojka/completion-buffers'
  Plug 'nvim-lua/diagnostic-nvim'
  Plug 'nvim-lua/lsp-status.nvim'

  " imap <c-j> <Plug>(completion_next_source)
  " " imap <c-k> <Plug>(completion_prev_source)
endfunction
