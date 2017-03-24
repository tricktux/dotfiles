
" Plugin 'Shougo/neocomplete.vim' {{{
"Note: This option must set it in .vimrc(_vimrc).  NOT IN .gvimrc(_gvimrc)!
" Disable AutoComplPop.
"if has('win32')
""if !has('nvim')
"" Disable vim-clang auto complete and diagnostic
"let g:clang_auto = 0
"let g:clang_diagsopt = ''

"let g:acp_enableAtStartup = 0
"" Use neocomplete.
"let g:neocomplete#enable_at_startup = 1
"" Use smartcase.
"let g:neocomplete#enable_smart_case = 1
"let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'
"" Define dictionary.
"let g:neocomplete#sources#dictionary#dictionaries = {
"\ 'default' : '',
	"\ 'vimshell' : $HOME.'/.vimshell_hist',
	"\ 'scheme' : $HOME.'/.gosh_completions'
	"\ }
	"let g:neocomplete#data_directory = s:personal_path . 'neocomplete'  " let neocomplete
	"" Define keyword.
	"if !exists('g:neocomplete#keyword_patterns')
	"let g:neocomplete#keyword_patterns = {}
	"endif
	"let g:neocomplete#keyword_patterns['default'] = '\h\w*'
	"" Plugin key-mappings.
	"inoremap <expr><C-g>     neocomplete#undo_completion()
	"inoremap <expr><C-l>     neocomplete#complete_common_string()
	"" Recommended key-mappings.
	"" <CR>: close popup and save indent.
	"inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
	"function! s:my_cr_function()
	"return (pumvisible() ? "\<C-y>" : "" ) . "\<CR>"
	"" For no inserting <CR> key.
	""return pumvisible() ? "\<C-y>" : "\<CR>"
	"endfunction
	"" <TAB>: completion.
	"inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
	"" <C-h>, <BS>: close popup and delete backword char.
	"inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
	"inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
	"" Enable heavy omni completion.
	"if !exists('g:neocomplete#sources#omni#input_patterns')
	"let g:neocomplete#sources#omni#input_patterns = {}
	"endif
	"let g:neocomplete#sources#omni#input_patterns.tex =
	"\ '\v\\%('
	"\ . '\a*cite\a*%(\s*\[[^]]*\]){0,2}\s*\{[^}]*'
	"\ . '|\a*ref%(\s*\{[^}]*|range\s*\{[^,}]*%(}\{)?)'
	"\ . '|includegraphics\*?%(\s*\[[^]]*\]){0,2}\s*\{[^}]*'
	"\ . '|%(include%(only)?|input)\s*\{[^}]*'
	"\ . ')'
	"if !exists('g:neocomplete#force_omni_input_patterns')
	"let g:neocomplete#force_omni_input_patterns = {}
	"endif
	"let g:neocomplete#sources#omni#input_patterns.php =
	"\ '[^. \t]->\%(\h\w*\)\?\|\h\w*::\%(\h\w*\)\?'
	"let g:neocomplete#sources#omni#input_patterns.c =
	"\ '[^.[:digit:] *\t]\%(\.\|->\)\%(\h\w*\)\?'
	"let g:neocomplete#sources#omni#input_patterns.cpp =
	"\ '[^.[:digit:] *\t]\%(\.\|->\)\%(\h\w*\)\?\|\h\w*::\%(\h\w*\)\?'
	"" For perlomni.vim setting.
	"" https://github.com/c9s/perlomni.vim
	"let g:neocomplete#sources#omni#input_patterns.perl =
	"\ '[^. \t]->\%(\h\w*\)\?\|\h\w*::\%(\h\w*\)\?'

	"" all new stuff
	"if !exists('g:neocomplete#delimiter_patterns')
	"let g:neocomplete#delimiter_patterns= {}
	"endif
	"let g:neocomplete#delimiter_patterns.vim = ['#']
	"let g:neocomplete#delimiter_patterns.cpp = ['::']

	"if !exists('g:neocomplete#sources')
	"let g:neocomplete#sources = {}
	"endif
	"let g:neocomplete#sources._ = ['buffer']
	"let g:neocomplete#sources.cpp = ['buffer', 'dictionary']
	" For smart TAB completion.
	"imap <expr><TAB>  pumvisible() ? "\<C-n>" :
	"\ <SID>check_back_space() ? "\<TAB>" :
	"\ neocomplete#start_manual_complete()
	"function! s:check_back_space() 
	"let col = col('.') - 1
	"return !col || getline('.')[col - 1]  =~ '\s'
	"endfunction
	"else
	"let g:deoplete#enable_at_startup = 1	
	"let g:deoplete#enable_smart_case = 1
	"" <C-h>, <BS>: close popup and delete backword char.
	"inoremap <expr><C-h> deoplete#mappings#smart_close_popup()."\<C-h>"
	"inoremap <expr><BS>  deoplete#mappings#smart_close_popup()."\<C-h>"
	"" <CR>: close popup and save indent.
	"inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
	"function! s:my_cr_function() abort
	"return deoplete#mappings#close_popup() . "\<CR>"
	"endfunction
	"inoremap <silent><expr> <Tab>
	"\ pumvisible() ? "\<C-n>" :
	"\ deoplete#mappings#manual_complete()
	endif
	" }}}

	" Plugin 'Shougo/neocomplete-snippets.vim' {{{
	" Plugin key-mappings.
	"imap <C-k>     <Plug>(neosnippet_expand_or_jump)
	"smap <C-k>     <Plug>(neosnippet_expand_or_jump)
	"xmap <C-k>     <Plug>(neosnippet_expand_target)
	"" SuperTab like snippets behavior.
	""imap <expr><TAB>
	"" \ pumvisible() ? "\<C-n>" :
	"" \ neosnippet#expandable_or_jumpable() ?
	"" \    "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
	"smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
	"\ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
	"let g:neosnippet#enable_snipmate_compatibility = 1
	"let g:neosnippet#snippets_directory= s:plugged_path . 'vim-snippets'
	" }}}
	"
	"
	" Plugin 'Netrw' VIM built in Explorer {{{
	"nnoremap <Leader>no :Rex<CR>
	""nnoremap <Leader>nb :exe("normal ". v:count . "gb")<CR>
	"let g:netrw_sort_sequence='[\/]$,*,\.bak$,\.o$,\.h$,\.info$,\.swp$,\.obj$'
	""let g:netrw_localcopydircmd	="copy"
	""let g:netrw_cygwin= 1
	"let g:netrw_bufsettings="noma nomod nonu nobl nowrap ro rnu"
	"let g:netrw_liststyle= 3
	" }}}

	" Plugin 'nathanaelkane/vim-indent-guides'  {{{
	"let g:indent_guides_enable_on_vim_startup = 1
	"let g:indent_guides_auto_colors = 1
	"let g:indent_guides_guide_size = 1
	"let g:indent_guides_start_level = 3
	"let g:indent_guides_faster = 1
	" }}}
	" Plug 'junegunn/rainbow_parentheses.vim' {{{
	let g:rainbow#max_level = 16
	let g:rainbow#pairs = [['(', ')'], ['[', ']'], ['{', '}']]
	" List of colors that you do not want. ANSI code or #RRGGBB
	let g:rainbow#blacklist = [233, 234]
	" }}}
	"
	"
	"/	OmniSharp Stuff {{{
	"Timeout in seconds to wait for a response from the server
	let g:OmniSharp_timeout = 1
	"Showmatch significantly slows down omnicomplete
	"when the first match contains parentheses.
	set noshowmatch
	"Move the preview window (code documentation) to the bottom of the screen, so it doesn't move the code!
	"You might also want to look at the echodoc plugin
	set splitbelow
	" Get Code Issues and syntax errors
	let g:syntastic_cs_checkers = ['syntax', 'semantic', 'issues']
	"Set autocomplete function to OmniSharp (if not using YouCompleteMe completion plugin)
	" Builds can also run asynchronously with vim-dispatch installed
	noremap <leader>ob :wa!<cr>:OmniSharpBuildAsync<cr>
	" automatic syntax check on events (TextChanged requires Vim 7.4)
	" this setting controls how long to wait (in ms) before fetching type / symbol information.
	set updatetime=500
	" Remove 'Press Enter to continue' message when type information is longer than one line.
	set cmdheight=1
	noremap <leader>oi :OmniSharpFindImplementations<cr>
	noremap <leader>ot :OmniSharpFindType<cr>
	noremap <leader>os :OmniSharpFindSymbol<cr>
	noremap <leader>ou :OmniSharpFindUsages<cr>
	"" rename with dialog
	nnoremap <leader>or :OmniSharpRename<cr>
	"" Force OmniSharp to reload the solution. Useful when switching branches etc.
	nnoremap <leader>ol :OmniSharpReloadSolution<cr>
	"" (Experimental - uses vim-dispatch or vimproc plugin) - Start the omnisharp server for the current solution
	"nnoremap <leader>ss :OmniSharpStartServer<cr>
	"nnoremap <leader>sp :OmniSharpStopServer<cr>
	let g:OmniSharp_server_type = 'v1'
	"" Add syntax highlighting for types and interfaces
	"nnoremap <leader>th :OmniSharpHighlightTypes<cr>
	"""Don't ask to save when changing buffers (i.e. when jumping to a type definition)
	" }}}


	" Plugin 'Vim-R-plugin' {{{
	" http://cran.revolutionanalytics.com
	" Install R, Rtools 
	" git clone https://github.com/jalvesaq/VimCom.git // Do this in command to
	" download the library then in R do the bottom command by substituting path
	" with your path to where you downloaded vimcom
	" install.packages("<location>", type = "source", repos = NULL)
	" put this in your InstallationRdir/etc/Rprofile.site
	" example C:\Program Files\R\etc\Rprofile.site
	"options(vimcom.verbose = 1)
	"library(vimcom)
	" }}}

	" Plug 'vimwiki/vimwiki', {'branch': 'dev'} {{{
	" personal wiki configuraton. 
	" you can configure multiple wikis
	" see :h g:vimwiki_list
	" also look at vimwiki.vim vimwiki_defaults for all possible options
	nnoremap <Leader>wtt :call <SID>WikiTable()<CR>
	let wiki = {}
	let wiki.path = s:personal_path . 'wiki'
	"let wiki.index = 'main'
	let wiki.auto_tags = 1
	let wiki.nested_syntaxes = {'python': 'python', 'c++': 'cpp'}
	let g:vimwiki_list = [wiki]

	let g:vimwiki_hl_cb_checked=1
	let g:vimwiki_menu=''
	let g:vimwiki_folding='expr'
	let g:vimwiki_table_mappings=0
	let g:vimwiki_use_calendar=0
	function! VimwikiLinkHandler(link)
		if match(a:link, ".cpp") != -1
			let l:neolink = strpart(a:link, 5)
			execute "e " . l:neolink
		endif
	endfunction
	" }}}
	" Plug Super-Tab{{{
    function! MyTagContext()
      if filereadable(expand('%:p:h') . '/tags')
        return "\<c-x>\<c-]>"
      endif
      " no return will result in the evaluation of the next
      " configured context
    endfunction
    let g:SuperTabCompletionContexts =
        \ ['MyTagContext', 's:ContextText', 's:ContextDiscover']
	let g:SuperTabContextTextOmniPrecedence = ['&omnifunc', '&completefunc']
	let g:SuperTabContextDiscoverDiscovery =
				\ ["&completefunc:<c-x><c-u>", "&omnifunc:<c-x><c-o>"]

	" }}}
	" Wiki specific mappings
	"autocmd FileType vimwiki nmap <buffer> <Leader>wn <Plug>VimwikiNextLink
	"autocmd FileType vimwiki nmap <buffer> <Leader>wp <Plug>VimwikiPrevLink
	"autocmd FileType vimwiki nmap <buffer> == <Plug>VimwikiAddHeaderLevel
	"autocmd FileType vimwiki nmap <buffer> ++ <Plug>VimwikiRemoveHeaderLevel
	"autocmd FileType vimwiki nmap <buffer> >> <Plug>VimwikiIncreaseLvlSingleItem
	"autocmd FileType vimwiki nmap <buffer> << <Plug>VimwikiDecreaseLvlSingleItem
	"autocmd FileType vimwiki nmap <buffer> <Leader>wa <Plug>VimwikiTabIndex
	"autocmd FileType vimwiki nmap <buffer> <Leader>wf <Plug>VimwikiFollowLink
	"autocmd FileType vimwiki setlocal spell spelllang=en_us
	" Latex
	" vim-tmux-navigator
		let g:tmux_navigator_no_mappings = 0
		let g:tmux_navigator_save_on_switch = 1

		nnoremap <silent> <Leader>h :TmuxNavigateLeft<cr>
		nnoremap <silent> <Leader>j :TmuxNavigateDown<cr>
		nnoremap <silent> <Leader>k :TmuxNavigateUp<cr>
		nnoremap <silent> <Leader>l :TmuxNavigateRight<cr>
		nnoremap <silent> <Leader>. :TmuxNavigatePrevious<cr>
		" vim-tmux-navigator shit a lot of trouble with remote terminals
	" Wiki specific mappings
	"autocmd FileType vimwiki nmap <buffer> <Leader>wn <Plug>VimwikiNextLink
	"autocmd FileType vimwiki nmap <buffer> <Leader>wp <Plug>VimwikiPrevLink
	"autocmd FileType vimwiki nmap <buffer> == <Plug>VimwikiAddHeaderLevel
	"autocmd FileType vimwiki nmap <buffer> ++ <Plug>VimwikiRemoveHeaderLevel
	"autocmd FileType vimwiki nmap <buffer> >> <Plug>VimwikiIncreaseLvlSingleItem
	"autocmd FileType vimwiki nmap <buffer> << <Plug>VimwikiDecreaseLvlSingleItem
	"autocmd FileType vimwiki nmap <buffer> <Leader>wa <Plug>VimwikiTabIndex
	"autocmd FileType vimwiki nmap <buffer> <Leader>wf <Plug>VimwikiFollowLink
	"autocmd FileType vimwiki setlocal spell spelllang=en_us
	"function! s:LinuxVIMRCFix() abort
		":w ++ff=unix
		":e
		":so %
	"endfunction
	"nnoremap <Leader>fl <SID>LinuxVIMRCFix()<CR>
	"let OmniCpp_MayCompleteDot = 1 " autocomplete after .
	"let OmniCpp_MayCompleteArrow = 1 " autocomplete after ->
	"let OmniCpp_MayCompleteScope = 1 " autocomplete after ::
		cnoreabbrev csa cs add
		cnoreabbrev csf cs find
		cnoreabbrev csk cs kill
		cnoreabbrev csr cs reset
		cnoreabbrev css cs show
		cnoreabbrev csh cs help
	" record undo history in this path
	"if has('persistent_undo')
		"let dir= s:personal_path . 'undodir'
		"" Create undo dir if it doesnt exist
		"if !isdirectory(dir) 
			"if exists("*mkdir") 
				"call mkdir(dir, "p")
				"let &undodir= dir
				"set undofile
				"set undolevels=10000
				"set undoreload=10000
			"else
				"set noundofile
				"echo "Failed to create undodir"
			"endif
		"endif
	"endif
	" binary
	"autocmd BufNewFile,BufReadPost *.bin setlocal ft=xxd
	"autocmd BufWritePre xxd %!xxd -r | setlocal binary | setlocal ft=modibin
	"autocmd FileType xxd %!xxd
	" Netwr
	autocmd FileType netrw nmap <buffer> e <cr>
	"autocmd GUIEnter * simalt ~x
	"autocmd VimEnter * bro old
	"autocmd FileType tex setlocal conceallevel=0  " never hide anything
	"autocmd FileType cs OmniSharpHighlightTypes
	" move windows positions
	"nnoremap <Leader>H <C-w>H
	"nnoremap <Leader>J <C-w>J
	"nnoremap <Leader>K <C-w>K
	"nnoremap <Leader>L <C-w>L
	"" expand windows positions
	"nnoremap <Leader>. <C-w>>
	"nnoremap <Leader>, <C-w><
	"nnoremap <Leader>- <C-w>-
	"nnoremap <Leader>= <C-w>+
	" vim-hex
	"nnoremap <Leader>hr :%!xxd<CR>
					"\:set ft=xxd<CR>
	"nnoremap <Leader>hw :%!xxd -r<CR>
					"\:set binary<CR>
					"\:set ft=<CR>

	"noremap <Tab> i<Tab><Esc>
	" Hard coded git version control
	"nnoremap <Leader>gp :call <SID>GitCommit()<CR>
	"nnoremap <Leader>gu :!git pull origin master<CR>
	"nnoremap <Leader>gP :!git add .<CR>
				"\:!git commit -F commit_msg.wiki<CR>
				"\:!git push CppTut master<CR>
	" }}}
	"
	" Plug Super-Tab{{{
		function! MyTagContext()
			if filereadable(expand('%:p:h') . '/tags')
				return "\<c-x>\<c-]>"
			endif
			" no return will result in the evaluation of the next
			" configured context
		endfunction
		let g:SuperTabCompletionContexts =
			\ ['MyTagContext', 's:ContextText', 's:ContextDiscover']
		let g:SuperTabContextTextOmniPrecedence = ['&omnifunc', '&completefunc']
		let g:SuperTabContextDiscoverDiscovery =
					\ ["&completefunc:<c-x><c-u>", "&omnifunc:<c-x><c-o>"]
		" Airline
		autocmd User AirlineAfterInit call OnlyBufferNameOnAirline()
	" Plugin 'bling/vim-airline' " Status bar line 
		set laststatus=2
		"let g:airline_section_b = '%{strftime("%c")}'
		let g:airline#extensions#bufferline#enabled = 1
		let g:airline#extensions#bufferline#overwrite_variables = 1
		let g:airline#extensions#branch#format = 2
		function! OnlyBufferNameOnAirline() abort
			let g:airline_section_c = airline#section#create(['%{pathshorten(bufname("%"))}'])
		endfunction
		let g:airline#extensions#whitespace#checks = ['trailing']
		let g:airline_theme='PaperColor'
	function! s:FormatFile() abort
		let g:clang_format_path='~/.clang-format'
		let l:lines="all"
		let l:format = s:personal_path . 'clang-format.py' 
		if filereadable(l:format) > 0
			exe "pyf " . l:format
		else	
			echo "File \"" . l:format . "\" does not exist"
		endif
	endfunction
	nnoremap <Leader>cf :call <SID>FormatFile()<CR>
		" tag wiki files, requires python script on path s:vwtagpy
		let s:vwtagpy = s:personal_path . '/wiki/vwtags.py'
		if filereadable(s:vwtagpy) > 0
			let g:tagbar_type_vimwiki = {
					\   'ctagstype':'vimwiki'
					\ , 'kinds':['h:header']
					\ , 'sro':'&&&'
					\ , 'kind2scope':{'h':'header'}
					\ , 'sort':0
					\ , 'ctagsbin':s:vwtagpy
					\ , 'ctagsargs': 'all'
					\ }
		endif
	function! s:WikiTable() abort
		if &ft =~ 'wiki'
			exe ":VimwikiTable " . input("Enter col row:")
		else
			echo "Current buffer is not of wiki filetype"
		endif
	endfunction
	" Vim-Clang
		let g:clang_auto = 0
		let g:clang_check_syntax_auto = 1
		" uncomment when using clang_diagsopt
		let g:clang_cpp_options = '-std=c++14 -stdlib=libc++ -pedantic -Wall'
		let g:clang_c_options = '-std=gnu11 -pedantic -Wall'
		let g:clang_include_sysheaders_from_gcc = 1
        let g:clang_diagsopt = 'rightbelow:6'
	"TODO:
	nnoremap <Leader>mz :call <SID>SaveSession()<CR>
	function! s:SaveSession() abort
		let l:path = "\"" . s:personal_path . "\sessions\""
		exe "let g:func = <SID>CheckFileOrDir(1, " . l:path . ")"
		if g:func > 0
			exe "cd " . l:path 
			exe "mksession! " . input("Save Session as:","","file")
			cd!
		else
			echo "Failed to save session"
		endif
	endfunction

	nnoremap <Leader>mx :call <SID>LoadSession()<CR>
	function! s:LoadSession() abort
		cd s:personal_path . "sessions"\"
		exe "mksession! " . input("Save Session as:","","file")
		cd!
	endfunction
	function! s:InsertStrncpy() abort
		echo "Usage: Yank dst into @0 and src into @1\n"
		echo "Choose 1.strncpy, 2.strncmp, 3.strncat\n"
		let l:type = nr2char(getchar())
		if l:type == 1
			let l:type = "strncpy"
		elseif l:type == 2
			let l:type = "strncmp"
			"TODO: fix this stuff here. each function has different behavior 
			exe "normal i" . l:type . "(". @0 . ", ". @1 .", sizeof(". @0 .")-1);\<Esc>"
		elseif l:type == 3
			let l:type = "strncat"
		else
			echo "Wrong Choice!!"
			return
		endif
		exe "normal i" . l:type . "(". @0 . ", ". @1 .", sizeof(". @0 ."));\<CR>\<Esc>"
		if match(l:type, "cat") < 0
			exe "normal i". @0 . "[sizeof(" . @0 . ")-1] = \'\\0\';  // Null terminating cpy\<Esc>"
		endif
	endfunction
	nnoremap <Leader>cy :call <SID>InsertStrncpy()<CR>
	function! s:InsertTODO() abort
		exe "normal i\<C-c>\<Space>TODO:\<Space>"
	endfunction
	nnoremap <Leader>mt <ESC>:call <SID>InsertTODO()<CR>
	function! s:CheckFileOrDirwPrompt(type,name) abort
		if !has('file_in_path')  " sanity check 
			echo "CheckFileOrDir(): This vim install has no support for +find_in_path"
			return -10
		endif
		if a:type == 0  " use 0 for file, 1 for dir
			let l:func = findfile(a:name,",,")  " see :h cd for ,, 
		else
			let l:func = finddir(a:name,",,") 
		endif
		if !empty(l:func)
			return 1
		else
			exe "echo \"Folder " . escape(a:name, '\') . "does not exists.\n\""
			exe "echo \"Do you want to create it (y)es or (n)o\""
			let l:decision = nr2char(getchar())
			if l:decision == "y"
				if exists("*mkdir") 
					if has('win32') " on win prepare name by escaping '\' 
						let l:esc_name = escape(a:name, '\')
						exe "call mkdir(\"". l:esc_name . "\", \"p\")"
					else  " have to test check works fine on linux 
						exe "call mkdir(\"". a:name . "\", \"p\")"
					endif
					return 1
				else
					return -1
				endif
			endif
			return -1
		endif
	endfunction

		"let g:neocomplete#enable_auto_select=1
		"let g:neocomplete#enable_auto_delimiter=1
		"let g:neocomplete#enable_refresh_always=1
		"
    " Still clang stuff but this is to use their python script
    " let g:clang_format_fallback_style = 'Google'
    " function! s:ClangFormatFile()
      " let l:lines="all"
      " pyf ~/vimrc/scripts/clang-format.py
    " endfunction
		nnoremap <Leader>ff za
		onoremap <Leader>ff <C-C>za
		nnoremap <Leader>ff zf
  function! Hex2Dec() abort
    execute "normal :echo str2nr('\<c-r>\<c-w>', 16)\<CR>" 
  endfunction

  " 8FFFF
  function! Dec2Hex() abort
    let l:sValue = expand("<cword>")
    echo l:sValue
    execute "normal :echo printf('%04X', '". l:sValue . "') str2nr('". l:sValue . "', 16) str2nr('". l:sValue . "', 2)\<CR>" 
  endfunction
  " F0
  " 240
  " Conque-GDB
    let g:ConqueGdb_Leader = '<Leader>d' " debugging is the idea behing leader>d dl and do taken
    let g:ConqueTerm_Color = 2         " 1: strip color after 200 lines, 2: always with color
    let g:ConqueTerm_CloseOnEnd = 1    " close conque when program ends running
    let g:ConqueTerm_StartMessages = 0 " display warning messages if conqueTerm is configured incorrectly
  function! Hex2Dec() abort
    execute "normal :echo str2nr('\<c-r>\<c-w>', 16)\<CR>" 
  endfunction

  function! Dec2Hex() abort
    let l:sValue = expand("<cword>")
    echo l:sValue
    execute "normal :echo printf('%04X', '". l:sValue . "') str2nr('". l:sValue . "', 16) str2nr('". l:sValue . "', 2)\<CR>" 
    " execute "normal :echo str2nr('". l:sValue . "', 16)\<CR>" 
    " execute "normal :echo str2nr('". l:sValue . "', 2)\<CR>" 
  endfunction

	" Plugin 'lervag/vimtex' " Latex support
		let g:vimtex_view_enabled = 0
		" latexmk
		let g:vimtex_latexmk_continuous=1
		let g:vimtex_latexmk_callback=1
		" AutoComplete
		let g:vimtex_complete_close_braces=1
		let g:vimtex_complete_recursive_bib=1
		let g:vimtex_complete_img_use_tail=1
		" ToC
		let g:vimtex_toc_enabled=1
		let g:vimtex_index_show_help=1

	" Plug Neocomplete
		if !has('nvim')
			if has('lua')
				" All new stuff
				" Vim-clang
        let g:clang_auto = 0
				let g:clang_c_completeopt = 'menuone,preview,noinsert,noselect'
				let g:clang_cpp_completeopt = 'menuone,preview,noinsert,noselect'

				let g:neocomplete#enable_cursor_hold_i=1
				let g:neocomplete#skip_auto_completion_time="1"
				let g:neocomplete#sources#buffer#cache_limit_size=5000000000
				let g:neocomplete#max_list=8
				let g:neocomplete#auto_completion_start_length=2
				" TODO: need to fix this i dont like the way he does it need my own for now is good I guess
				let g:neocomplete#enable_auto_close_preview=1

				let g:neocomplete#enable_at_startup = 1
				let g:neocomplete#enable_smart_case = 1
				let g:neocomplete#data_directory = s:personal_path . 'neocomplete'
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

			else
        echoerr "No lua installed so falling back to having only clang autocomplete"
				let g:clang_auto = 1
			endif
		elseif has('python3')
			" if it is nvim deoplete requires python3 to work
			let g:clang_auto = 0
			let g:deoplete#enable_at_startup = 1
		else
      echoerr "No python3 installed so falling back to having only clang autocomplete"
			" so if it doesnt have it activate clang instaed
			let g:deoplete#enable_at_startup = 0
			let g:clang_auto = 1
		endif

			" NeoSnippets
		" Plugin key-mappings.
		imap <C-k>     <Plug>(neosnippet_expand_or_jump)
		smap <C-k>     <Plug>(neosnippet_expand_or_jump)
		xmap <C-k>     <Plug>(neosnippet_expand_target)
		smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
		\ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
		" Tell Neosnippet about the other snippets
		let g:neosnippet#snippets_directory= s:plugged_path . '/vim-snippets/snippets'
		let g:neosnippet#data_directory = s:personal_path . 'neosnippets'

" OmniCpp_SETINGS
	" OmniCpp
	let OmniCpp_NamespaceSearch = 1
	let OmniCpp_GlobalScopeSearch = 1
	let OmniCpp_ShowAccess = 1
	let OmniCpp_ShowPrototypeInAbbr = 1 " show function parameters
  let OmniCpp_MayCompleteDot = 1 " autocomplete after .
  let OmniCpp_MayCompleteArrow = 1 " autocomplete after ->
  let OmniCpp_MayCompleteScope = 1 " autocomplete after ::
	let OmniCpp_DefaultNamespaces = ["std", "_GLIBCXX_STD"]

	" Plug Vim-R-plugin {{{
		let vimrplugin_r_path = 'C:\\Program Files\\R\\R-3.2.3\\bin\\i386'

    " Vim-clang
      let g:clang_cpp_options = '-std=c++17 -pedantic -Wall'
      let g:clang_c_options = '-std=gnu11 -pedantic -Wall'
				"
				" Vim-clang
        let g:clang_auto = 0
				let g:clang_c_completeopt = 'menuone,preview,noinsert,noselect'
				let g:clang_cpp_completeopt = 'menuone,preview,noinsert,noselect'
		let g:clang_diagsopt = '' " no syntax check
    let g:clang_format_style ='file'
    nnoremap <c-f> :ClangFormat<CR>
	" Only works in vimwiki filetypes
	" Input: empty- It will ask you what type of file you want to search
	" 		 String- "1", "2", or specify files in which you want to search
	function! s:GlobalSearch(type) abort
		try
			"echomsg string(a:type)  " Debugging purposes
			if a:type == "0"
				echo "Search Filetypes:\n\t1.Any\n\t2.Cpp\n\t3.Wiki"
				let l:file = nr2char(getchar())
			else
				let l:file = a:type
			endif
			if !executable('ag') " use ag if possible
				if l:file == 1
					let l:file = "**/*"
				elseif l:file == 2
					let l:file = "**/*.cpp **/*.h **/*.c **/*.hpp **/*.cc"
				elseif l:file == 3
					let l:file = "**/*.wiki"
				endif
				execute "vimgrep /" . input("Search in \"" . getcwd() . "\" for:") . "/ " . l:file
			else
				if l:file == 1
					let l:file = ""
				elseif l:file == 2
					let l:file = "--cpp"
				endif " relays on set grepprg=ag
				execute "silent grep! " . l:file . " " . input("Search in \"" . getcwd() . "\" for:")
			endif
			copen 20
		catch
			echohl ErrorMsg
			redraw " prevents the msg from misteriously dissapearing
			echomsg "GlobalSearch(): " . matchstr(v:exception, ':\zs.*')
			echohl None
		endtry
	endfunction
    " Plugin ack
      " only active if ag present
      if s:ack == 1
        " TODO if no ack still search with grep or vimgrep. but without the
        " plugin
        " Bring back SearchGlobal function. Just change the command for Ack!
        " when ack is present and leave as is when is not. Option to do this
        " is to add another variable to the function. i.e: pass in ack so that
        " you know which version type to run
        let g:ackprg = "ag --vimgrep"
        let g:ackhighlight = 1
        " let g:ack_use_dispatch = 1
        let g:ack_autofold_results = 1

    " Plug 'wsdjeg/vim-cheat' " depends on simplecheats
      " Based of this plugin created my own vim-wiki
    " Plug 'artur-shaik/simplecheats', { 'dir' : '$HOME/.cheat' }
      " not needed just copied info
    " Plug 'sentientmachine/erics_vim_syntax_and_color_highlighting', { 'for' : 'java' }
      " Dont notice the difference in highlight honestly
		" This is done automagically if you set filetype indent on
		autocmd FileType c,cpp setlocal cindent
	" tabs
	" This settings are handled by either smartindent or indent.vim files
	set tabstop=2     " a tab is four spaces
	set softtabstop=2
  set expandtab " turns tabs into spaces
	set shiftwidth=2  " number of spaces to use for autoindenting
	set shiftround    " use multiple of shiftwidth when indenting with '<' and '>'

  " Set up only for win32 at the moment
  " augroup EnvironMent
    " autocmd!
    " " local vimrc files
    " autocmd BufReadPost,BufNewFile * call <SID>SetupEnvironment()
    " autocmd SessionLoadPost * call <SID>SetupEnvironment()
  " augroup END
  " Performance warning on this function. If necesary disable and just make
  " function calls
  " Note: Keep in mind vim modelines for vim type of files
  " Input: Pass in any argument to the variable to force Wings indent settings
  " to take effect
  function! s:SetupEnvironment(...)
    let l:path = expand('%:p')
    " use this as an example. just substitute NeoOneWINGS with your project
    " specific folder name
    " Pass any random argument to the function to force wings settings
    if match(l:path,'NeoOneWINGS') > 0 || match(l:path,'NeoWingsSupportFiles') > 0 || a:0>0
      " set a g:local_vimrc_name in you local vimrc to avoid local vimrc
      " reloadings
      " TODO this entire thing needs to be redone
      if !exists('g:local_vimrc_wings') || a:0>0
        if exists('g:local_vimrc_personal')
          unlet g:local_vimrc_personal
        endif
        echomsg "Loading settings for Wings..."
        set tabstop=4     " a tab is four spaces
        set softtabstop=4
        set shiftwidth=4  " number of spaces to use for autoindenting
        set textwidth=120
        let g:local_vimrc_wings = 1
      endif
      if match(l:path,'Source') > 0
        compiler bcc
      elseif match(l:path,'sandbox') > 0
        set makeprg=mingw32-make
        set errorformat&
      else
        compiler msbuild
        " Some helpful compiler swithces /t:Rebuild
        " compiler's errorformat is not good
        set errorformat&
      endif
    " elseif match(l:path,'sep_calc') > 0 || match(l:path,'snippets') > 0 || match(l:path,'wiki') > 0
      " TODO create command to undo all this settings. See :h ftpplugin
    else
      if exists('g:local_vimrc_personal') && !exists('g:local_vimrc_personal')
        unlet g:local_vimrc_wings
        echomsg "Loading regular settings..."
        " tab settings
        set tabstop=2
        set softtabstop=2
        set shiftwidth=2
        set textwidth=80
        let g:local_vimrc_personal = 1
      endif
    endif
  endfunction

		" autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
		" autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
		" autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
		" autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
		" autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
	" function! s:GlobalSearch(type) abort
		" try
			" " Set grepprg at the beggning only
			" " Then depending on the search type use ucg if available and search is
			" " of code or ag if search all files
			" " Make a .agingnore and .ucgrc file to ignore searching arduino file and
			" " the others that you moved to MyServer folder
			" if a:type ==# "all"
				" " use ag
				" echo "Search Filetypes:\n\t1.Any\n\t2.Cpp"
				" let l:file = nr2char(getchar())
			" elseif a:type ==# "code"

				" let l:file = a:type
			" endif
			" if !executable('ag') " use ag if possible
				" if l:file == 1
					" let l:file = "**/*"
				" elseif l:file == 2
					" let l:file = "**/*.cpp **/*.h **/*.c **/*.hpp **/*.cc"
				" " reserve for future use of other languages
				" " elseif l:file == 3
					" " let l:file = "**/*.wiki"
				" endif
				" execute "vimgrep /" . input("Search in \"" . getcwd() . "\" for:") . "/ " . l:file
			" else
				" if l:file == 1
					" let l:file = ""
				" elseif l:file == 2
					" let l:file = "--cpp"
				" endif " relays on set grepprg=ag
				" execute "grep " . l:file . " " . input("Search in \"" . getcwd() . "\" for:")
			" endif
			" copen 20
		" catch
			" echohl ErrorMsg
			" redraw " prevents the msg from misteriously dissapearing
			" echomsg "GlobalSearch(): " . matchstr(v:exception, ':\zs.*')
			" echohl None
		" endtry
	" endfunction
      " if executable('ucg')
        " set grepprg=ucg\ --nocolor\ --noenv
      " endif
        " ctrlp with ag
        " see :Man ag for help
        " set grepprg=ag\ --nogroup\ --nocolor\ --smart-case\ --all-text\ --vimgrep\ $*
        " set grepformat=%f:%l:%c:%m
        "Use the -t option to search all text files; -a to search all files; and -u to search all, including hidden files.
		" Plug 'mrtazz/DoxygenToolkit.vim' " has being moved to plugin folder
				" let g:syntastic_java_javac_classpath='/home/reinaldo/Documents/android-sdk/platforms/android-24/*.jar:
							" \/home/reinaldo/Documents/seafile-client/Seafile/KnowledgeIsPower/udacity/android-projects/BaseballScore/app/build/generated/source/r/debug/com/hq/baseballscore/*.java'
		"	I considere it not necessary
		" Plug 'godlygeek/tabular', { 'for' : 'md' } " required by markdown
		" Plug 'plasticboy/vim-markdown', { 'for' : 'md' }
		" Conflicts with neovim
		autocmd FileType nerdtree setlocal encoding=utf-8 " fixes little arrows
			" Default directory is already .cache
      let g:JavaComplete_BaseDir = s:cache_path . 'java'
		" CSyntaxAfter() not longer needed we got pretty good highlight with
		" native methods. Also gradlew will be set by VimStudio
		" autocmd FileType java call CSyntaxAfter() " Being called from after/syntax
		" autocmd FileType java compiler gradlew
			" Syntastic
				let g:syntastic_c_config_file = s:cache_path . '.syntastic_avrgcc_config'
				" let $CLASSPATH='/home/reinaldo/Documents/android-sdk/platforms/android-24/android.jar'
				
		" Fails too many times
		Plug 'jiangmiao/auto-pairs'
		" Didnt highlight where I wanted it to
		" Plug 'Yggdroot/indentLine'

		" indentLine
			let g:indentLine_char='¦'
			let g:indentLine_color_gui = '#A4E57E'
			let g:indentLine_color_term = 239
			let g:indentLine_fileType = ['c', 'cpp']
			" let g:indentLine_faster=1
			let g:indentLine_indentLevel= 30

			" Couldnt this plugin to expand on cr
			" delimitMate
			let g:delimitMate_expand_cr = 2
			let g:delimitMate_expand_space = 1
			let g:delimitMate_jump_expansion = 1
		" autocmd FileType c,cpp setlocal foldmethod=syntax
		" Indent options
		" autocmd FileType c,cpp setlocal shiftwidth=4 tabstop=4
		" autocmd FileType tex,vim,java,markdown setlocal shiftwidth=2 tabstop=2
		" autocmd FileType * setlocal shiftwidth=2 tabstop=2
		" autocmd FileType markdown setlocal formatoptions+=anro comments+=fb:-
		" autocmd FileType markdown setlocal autoindent formatoptions+=anro comments+=fb:-
		" autocmd FileType markdown setlocal autoindent formatlistpat=^\\s*\\(\\d\\+[\\]:.)}\\t\ ]\\|-\\)\\s*
					" \ formatoptions+=anro comments+=b:-
				" set statusline+=%#warningmsg#
				" set statusline+=%{SyntasticStatuslineFlag()}
				" set statusline+=%*
      " turning this option breaks comments
      "let g:cpp_experimental_template_highlight = 1
		" " " search cpp files
		" nnoremap <Leader>Sc :call <SID>GlobalSearch(2)<CR>
		nnoremap <Leader>w /\<<c-r>=expand("<cword>")<cr>\>
		nnoremap <Leader>W :%s/\<<c-r>=expand("<cword>")<cr>\>/
		" This is a very good to show and search all current but a much better is
		" remaped search to f
		noremap <Leader>sC z=1<CR><CR>
				" Old settings
				" Settings for javacomplete2
				" let g:deoplete#enable_ignore_case = 1
				" let g:deoplete#enable_smart_case = 1
				" let g:deoplete#enable_refresh_always = 1
				" let g:deoplete#omni#input_patterns = get(g:,'deoplete#omni#input_patterns',{})
				" let g:deoplete#omni#input_patterns.java = [
						" \'[^. \t0-9]\.\w*',
						" \'[^. \t0-9]\->\w*',
						" \'[^. \t0-9]\::\w*',
						" \]
				" let g:deoplete#omni#input_patterns.jsp = ['[^. \t0-9]\.\w*']
				" let g:deoplete#ignore_sources = {}
				" let g:deoplete#ignore_sources._ = ['javacomplete2']

		" Netrw
			let g:netrw_home=s:cache_path
			let g:netrw_liststyle = 3
			let g:netrw_browse_split = 4
			let g:netrw_altv = 1
			let g:netrw_winsize = 25
			" let g:netrw_banner = 0
			let g:netrw_list_hide = &wildignore
			" Relative numbers
			let g:netrw_bufsettings="noma nomod nonu nobl nowrap ro rnu"
			let g:netrw_use_errorwindow    = 0
			let g:netrw_usetab=1
			let g:netrw_retmap= 1
			" let g:netrw_browse_split = 4
			let g:netrw_altv = 1
			" let g:netrw_chgwin=0
			function! s:NetrwMappings() abort
				nmap <buffer> <silent> o <CR>
				nmap <buffer> <silent> <nowait> <s-o>  <S-CR>
				nmap <buffer> <c-tab> ZQ
			endfunction
		" Airline 
			set encoding=utf-8

			if !exists('g:airline_symbols')
				let g:airline_symbols = {}
			endif

			" If you ever try a new font and want see if symbols work just go to h
			" airline and check if the symbols display properly there. If they do they
			" will display properly in the bar
			" let g:airline_left_sep = '»'
			let g:airline_left_sep = ''
			" let g:airline_right_sep = '«'
			let g:airline_right_sep = ''
			" let g:airline_symbols.linenr = '¶'
			let g:airline_symbols.linenr = ''
			let g:airline_symbols.maxlinenr = '☰'
			" let g:airline_symbols.maxlinenr = ''
			let g:airline_symbols.paste = 'ρ'
			" let g:airline_symbols.paste = 'Þ'
			" let g:airline_symbols.paste = '∥'
			let g:airline_symbols.whitespace = 'Ξ'
			let g:airline_symbols.crypt = ''
			let g:airline_symbols.branch = ''
			let g:airline_symbols.notexists = ''
			let g:airline_symbols.readonly = ''

		" Airline
			if !exists('g:airline_symbols')
				let g:airline_symbols = {}
			endif
			let g:airline_left_sep = ''
			let g:airline_left_alt_sep = ''
			let g:airline_right_sep = ''
			let g:airline_right_alt_sep = ''
			let g:airline_symbols.branch = ''
			let g:airline_symbols.readonly = ''
			let g:airline_symbols.linenr = ''
			let g:airline_symbols.linenr = '¶'
			let g:airline_symbols.paste = 'ρ'
			let g:airline_symbols.spell = 'Ꞩ'
			let g:airline_symbols.paste = 'Þ'

		" Too many lines of code and overhead
		Plug 'vim-airline/vim-airline'
		Plug 'vim-airline/vim-airline-themes'
		" Airline
			let g:airline_theme="dark"

			let g:airline#extensions#whitespace#checks = []
			let g:airline#extensions#disable_rtp_load = 1
			let g:airline_extensions = ['branch']

		nnoremap <Leader>md :Dox<CR>
			" Name of the Intellij Plugin for AndroidStudio
			" Plug 'vhakulinen/neovim-intellij-complete'
			" Trying to get intellij con nvim didnt work
			Plug 'vhakulinen/neovim-intellij-complete-deoplete'
			Plug 'vhakulinen/neovim-java-client'

				let g:neomake_cpp_make_maker = {
							\ 'exe': 'make',
							\ 'args': ['--build'],
							\ 'errorformat': '%f:%l:%c: %m',
							\ }
				let g:neomake_cpp_enabled_makers = ['make']
			" //////////////7/28/2016 4:09:23 PM////////////////
			" Tried using shell=bash on windows didnt work got all kinds of issues
			" with syntastic and other things.
		" Vim-Man
			" Was causing nvim to start with just nvim
			" runtime! ftplugin/man.vim
			" Sample use: Man 3 printf
			" Potential plug if you need more `vim-utils/vim-man` but this should be
			" enough
" TODO.RM-Wed Nov 30 2016 09:48: Finish all this crap
function! utils#AutoCreateUnixCtags() abort
	if empty(finddir(s:cache_path . "ctags",",,"))
		" Go ahead and create the ctags
		if !executable('ctags')
			echomsg string("Please install ctags")
			return 0
		else
			" Create folder
			if !utils#CheckDirwoPrompt(s:cache_path . "ctags")
				echoerr string("Failed to create ctags dir")
				return 0
			endif
			let l:ctags_cmd = "!ctags -R --sort=yes --fields=+iaS --extra=+q -f "
			" Ordered list that contains folder where tag is and where tag file
			" goes
			let l:list_folders = [
						\"/usr/include",
						\"~/.vim/personal/ctags/tags_sys",
						\"/usr/local/include",
						\"~/.vim/personal/ctags/tags_sys2",
						\'/opt/avr8-gnu-toolchain-linux_x86_64/avr/include',
						\"~/.vim/personal/ctags/tags_avr",
						\'/opt/avr8-gnu-toolchain-linux_x86_64/include',
						\"~/.vim/personal/ctags/tags_avr2",
						\]

			" Create ctags
			" if isdirectory(l:list_folders
			!ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ -f ~/.vim/personal/ctags/tags_sys /usr/include
			!ctags -R --sort=yes --c++-kinds=+pl --fields=+iaS --extra=+q --language-force=C++ -f ~/.cache/tags_sys /usr/include
			!ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ -f ~/.vim/personal/ctags/tags_sys2 /usr/local/include
			if isdirectory('/opt/avr8-gnu-toolchain-linux_x86_64/avr/include')
				set path+=/opt/avr8-gnu-toolchain-linux_x86_64/avr/include
				!ctags -R --sort=yes --fields=+iaS --extra=+q --language-force=C -f ~/.vim/personal/ctags/tags_avr /opt/avr8-gnu-toolchain-linux_x86_64/avr/include
				set tags+=~/.vim/personal/ctags/tags_avr
			endif
			if isdirectory('/opt/avr8-gnu-toolchain-linux_x86_64/include')
				set path+=/opt/avr8-gnu-toolchain-linux_x86_64/include
				!ctags -R --sort=yes --fields=+iaS --extra=+q --language-force=C -f ~/.vim/personal/ctags/tags_avr2 /opt/avr8-gnu-toolchain-linux_x86_64/include
				set tags+=~/.vim/personal/ctags/tags_avr2
			endif
		elseif has('win32') && isdirectory('c:/MinGW')
			set path+=c:/MinGW/include
			execute "!ctags -R --verbose --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q
						\ --language-force=C++ -f " . expand('~/vimfiles/personal/ctags/tags_sys') . " C:\\MinGW\\include"
		else
			echomsg string("Please install MinGW")
		endif
	endif
elseif has('unix')
	if isdirectory('/opt/avr8-gnu-toolchain-linux_x86_64/avr/include')
		set path+=/opt/avr8-gnu-toolchain-linux_x86_64/avr/include
	endif
	set tags+=~/.vim/personal/ctags/tags_sys
	set tags+=~/.vim/personal/ctags/tags_sys2
else
	set tags+=~/vimfiles/personal/ctags/tags_sys
endif
	endfunction
" To update ctags simply delete the ctags folder
" let &tags= s:cache_path . 'ctags/tags'
function! utils#AutoCreateCtags() abort
	if empty(finddir(s:cache_path . "ctags",",,"))
		" Go ahead and create the ctags
		if !executable('ctags')
			echomsg string("Please install ctags")
		else
			" Create folder
			if !utils#CheckDirwoPrompt(s:cache_path . "ctags")
				echoerr string("Failed to create ctags dir")
			endif
			" Create ctags
			if has('unix')
				!ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ -f ~/.vim/personal/ctags/tags_sys /usr/include
				!ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ -f ~/.vim/personal/ctags/tags_sys2 /usr/local/include
				if isdirectory('/opt/avr8-gnu-toolchain-linux_x86_64/avr/include')
					set path+=/opt/avr8-gnu-toolchain-linux_x86_64/avr/include
					!ctags -R --sort=yes --fields=+iaS --extra=+q --language-force=C -f ~/.vim/personal/ctags/tags_avr /opt/avr8-gnu-toolchain-linux_x86_64/avr/include
					set tags+=~/.vim/personal/ctags/tags_avr
				endif
				if isdirectory('/opt/avr8-gnu-toolchain-linux_x86_64/include')
					set path+=/opt/avr8-gnu-toolchain-linux_x86_64/include
					!ctags -R --sort=yes --fields=+iaS --extra=+q --language-force=C -f ~/.vim/personal/ctags/tags_avr2 /opt/avr8-gnu-toolchain-linux_x86_64/include
					set tags+=~/.vim/personal/ctags/tags_avr2
				endif
			elseif has('win32') && isdirectory('c:/MinGW')
				set path+=c:/MinGW/include
				execute "!ctags -R --verbose --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q
							\ --language-force=C++ -f " . expand('~/vimfiles/personal/ctags/tags_sys') . " C:\\MinGW\\include"
			else
				echomsg string("Please install MinGW")
			endif
		endif
	elseif has('unix')
		if isdirectory('/opt/avr8-gnu-toolchain-linux_x86_64/avr/include')
			set path+=/opt/avr8-gnu-toolchain-linux_x86_64/avr/include
		endif
		set tags+=~/.vim/personal/ctags/tags_sys
		set tags+=~/.vim/personal/ctags/tags_sys2
	else
		set tags+=~/vimfiles/personal/ctags/tags_sys
	endif
endfunction

		Plug 'nelstrom/vim-markdown-folding'
			" messes up with neocomplete
			let g:vim_markdown_folding_disabled = 0
			let g:vim_markdown_folding_level = 6
			let g:vim_markdown_conceal = 0
			" let g:markdown_fold_style = 'nested'
			let g:markdown_fold_override_foldtext = 0
" To update ctags simply delete the ctags folder
" Note: There is also avr tags created by vimrc/scripts/maketags.sh
" let &tags= s:cache_path . 'ctags/tags'
function! utils#AutoCreateCtags() abort
	if empty(finddir(s:cache_path . "ctags",",,"))
		" Go ahead and create the ctags
		if !executable('ctags')
			echomsg string("Please install ctags")
		else
			" Create folder
			if !utils#CheckDirwoPrompt(s:cache_path . "ctags")
				echoerr string("Failed to create ctags dir")
			endif
			" Create ctags
			if has('unix')
				!ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ -f ~/.vim/personal/ctags/tags_sys /usr/include
				!ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ -f ~/.vim/personal/ctags/tags_sys2 /usr/local/include
				if isdirectory('/opt/avr8-gnu-toolchain-linux_x86_64/avr/include')
					set path+=/opt/avr8-gnu-toolchain-linux_x86_64/avr/include
					!ctags -R --sort=yes --fields=+iaS --extra=+q --language-force=C -f ~/.vim/personal/ctags/tags_avr /opt/avr8-gnu-toolchain-linux_x86_64/avr/include
					set tags+=~/.vim/personal/ctags/tags_avr
				endif
				if isdirectory('/opt/avr8-gnu-toolchain-linux_x86_64/include')
					set path+=/opt/avr8-gnu-toolchain-linux_x86_64/include
					!ctags -R --sort=yes --fields=+iaS --extra=+q --language-force=C -f ~/.vim/personal/ctags/tags_avr2 /opt/avr8-gnu-toolchain-linux_x86_64/include
					set tags+=~/.vim/personal/ctags/tags_avr2
				endif
			elseif has('win32') && isdirectory('c:/MinGW')
				set path+=c:/MinGW/include
				execute "!ctags -R --verbose --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q
							\ --language-force=C++ -f " . expand('~/vimfiles/personal/ctags/tags_sys') . " C:\\MinGW\\include"
			else
				echomsg string("Please install MinGW")
			endif
		endif
	elseif has('unix')
		if isdirectory('/opt/avr8-gnu-toolchain-linux_x86_64/avr/include')
			set path+=/opt/avr8-gnu-toolchain-linux_x86_64/avr/include
		endif
		set tags+=~/.vim/personal/ctags/tags_sys
		set tags+=~/.vim/personal/ctags/tags_sys2
	else
		set tags+=~/vimfiles/personal/ctags/tags_sys
	endif
endfunction

" Finish all this crap
function! utils#AutoCreateUnixCtags() abort
	if empty(finddir(s:cache_path . "ctags",",,"))
		" Go ahead and create the ctags
		if !executable('ctags')
			echomsg string("Please install ctags")
			return 0
		else
			" Create folder
			if !utils#CheckDirwoPrompt(s:cache_path . "ctags")
				echoerr string("Failed to create ctags dir")
				return 0
			endif
			let l:ctags_cmd = "!ctags -R --sort=yes --fields=+iaS --extra=+q -f "
			" Ordered list that contains folder where tag is and where tag file
			" goes
			let l:list_folders = [
						\"/usr/include",
						\"~/.vim/personal/ctags/tags_sys",
						\"/usr/local/include",
						\"~/.vim/personal/ctags/tags_sys2",
						\'/opt/avr8-gnu-toolchain-linux_x86_64/avr/include',
						\"~/.vim/personal/ctags/tags_avr",
						\'/opt/avr8-gnu-toolchain-linux_x86_64/include',
						\"~/.vim/personal/ctags/tags_avr2",
						\]

			" Create ctags
			" if isdirectory(l:list_folders
			!ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ -f ~/.vim/personal/ctags/tags_sys /usr/include
			!ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ -f ~/.vim/personal/ctags/tags_sys2 /usr/local/include
			if isdirectory('/opt/avr8-gnu-toolchain-linux_x86_64/avr/include')
				set path+=/opt/avr8-gnu-toolchain-linux_x86_64/avr/include
				!ctags -R --sort=yes --fields=+iaS --extra=+q --language-force=C -f ~/.vim/personal/ctags/tags_avr /opt/avr8-gnu-toolchain-linux_x86_64/avr/include
				set tags+=~/.vim/personal/ctags/tags_avr
			endif
			if isdirectory('/opt/avr8-gnu-toolchain-linux_x86_64/include')
				set path+=/opt/avr8-gnu-toolchain-linux_x86_64/include
				!ctags -R --sort=yes --fields=+iaS --extra=+q --language-force=C -f ~/.vim/personal/ctags/tags_avr2 /opt/avr8-gnu-toolchain-linux_x86_64/include
				set tags+=~/.vim/personal/ctags/tags_avr2
			endif
		elseif has('win32') && isdirectory('c:/MinGW')
			set path+=c:/MinGW/include
			execute "!ctags -R --verbose --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q
						\ --language-force=C++ -f " . expand('~/vimfiles/personal/ctags/tags_sys') . " C:\\MinGW\\include"
		else
			echomsg string("Please install MinGW")
		endif
	endif
elseif has('unix')
	if isdirectory('/opt/avr8-gnu-toolchain-linux_x86_64/avr/include')
		set path+=/opt/avr8-gnu-toolchain-linux_x86_64/avr/include
	endif
	set tags+=~/.vim/personal/ctags/tags_sys
	set tags+=~/.vim/personal/ctags/tags_sys2
else
	set tags+=~/vimfiles/personal/ctags/tags_sys
endif
	endfunction

	function! utils#LastCommand() abort
		execute "normal :\<Up>\<CR>"
	endfunction

	function! utils#ListFiles(dir) abort
		let l:directory = globpath(a:dir, '*')
		if empty(l:directory)
			echohl ErrorMsg | echom a:dir . " is not a valid directory name" | echohl None
		endif
		return map(split(l:directory,'\n'), "fnamemodify(v:val, ':t')")
	endfunction

	function! MarkdownLevel()
		if getline(v:lnum) =~ '^# .*$'
			return ">1"
		endif
		if getline(v:lnum) =~ '^## .*$'
			return ">2"
		endif
		if getline(v:lnum) =~ '^### .*$'
			return ">3"
		endif
		if getline(v:lnum) =~ '^#### .*$'
			return ">4"
		endif
		if getline(v:lnum) =~ '^##### .*$'
			return ">5"
		endif
		if getline(v:lnum) =~ '^###### .*$'
			return ">6"
		endif
		return "=" 
	endfunction
								" \ 'inactive': { 
								" \   'right': [ 'neomake' ]
								" \		},
								" \ 'component_type': {
								" \   'neomake': 'error'
								" \ },
		" let g:lightline.component = { 'neomake': '%{neomake#statusline#QflistStatus("qf:\\ ")}' }
		" let g:lightline.component_visible_condition = {'neomake': '(!empty(neomake#statusline#QflistStatus("qf:\ ")))'}

										" \   'neomake': '%{neomake#statusline#QflistStatus('qf:\ ')}',
										" \   'neomake': '(!empty(neomake#statusline#QflistStatus('qf:\ ')))',
			" if executable('clang') && has('python') && !exists('g:android') " clang_complete
				" Plug 'Rip-Rip/clang_complete', { 'for' : ['c' , 'cpp'] }
				" " Why I switched to Rip-Rip because it works
				" " Steps to get plugin to work:
				" " 1. Make sure that you can compile a program with clang++ command
				" " a. Example: clang++ -std=c++14 -stdlib=libc++ -pedantic -Wall hello.cpp -v
				" " 2. To get this to work I had to install libc++-dev package in unix
				" " 3. install libclang-dev package. See g:clang_library_path to where it gets
				" " installed. Also I had to make sym link: ln -s libclang.so.1 libclang.so
				" let g:clang_user_options = '-std=c++14 -stdlib=libc++ -Wall -pedantic'
				" let g:clang_close_preview = 1
				" " let g:clang_complete_copen = 1
				" " let g:clang_periodic_quickfix = 1
				" if has('win32')
					" " clang using mscv for target instead of mingw64
					" let g:clang_cpp_options = '-target x86_64-pc-windows-gnu -std=c++17 -pedantic -Wall'
					" let g:clang_c_options = '-target x86_64-pc-windows-gnu -std=gnu11 -pedantic -Wall'
				" else
					" let g:clang_library_path= g:usr_path . '/lib/libclang.so'
				" endif
			" else
				" echomsg string("No clang and/or python present. Disabling vim-clang")
				" let g:clang_complete_loaded = 1
			" endif
			" else
				" echomsg "No python3 = No Deocomplete. Supertab Activated"
				" " so if it doesnt have it activate clang instaed
				" let g:deoplete#enable_at_startup = 0
				" Plug 'ervandew/supertab' " Activate Supertab
				" let g:SuperTabDefaultCompletionType = "<c-n>"
			" endif
		" Highliting is too inconsistent
		" Plug 'arakashic/chromatica.nvim', { 'do' : ':UpdateRemotePlugins' }
			" let g:chromatica#enable_at_startup = 1
			" let g:chromatica#libclang_path = '/usr/lib/libclang.so'
			" let g:chromatica#highlight_feature_level = 1
	" Dont believe this is having any effect at all
	" Plug 'junegunn/rainbow_parentheses.vim', { 'on' : 'RainbowParentheses' }
		" let g:rainbow#max_level = 16
		" let g:rainbow#pairs = [['(', ')'], ['[', ']']]
" .dotfiles/vim-utils/after/ftplugin/c.vim
" if exists(':RainbowParentheses')
	" RainbowParentheses
" endif
	" Too slow for not async abilities
	Plug 'xolox/vim-easytags', { 'on' : 'HighlightTags' }
		Plug 'xolox/vim-misc' " dependency of vim-easytags
		Plug 'xolox/vim-shell' " dependency of vim-easytags
		set regexpengine=1 " This speed up the engine alot but still not enough
		let g:easytags_file = '~/.cache/ctags'
		let g:easytags_syntax_keyword = 'always'
		let g:easytags_auto_update = 0
		" let g:easytags_cmd = 'ctags'
		" let g:easytags_on_cursorhold = 1
		" let g:easytags_updatetime_min = 4000
		" let g:easytags_auto_update = 1
		" " let g:easytags_auto_highlight = 1
		" let g:easytags_dynamic_files = 1
		" let g:easytags_by_filetype = '~/.cache/easy-tags-filetype'
		" " let g:easytags_events = ['BufReadPost' , 'BufWritePost']
		" let g:easytags_events = ['BufReadPost']
		" " let g:easytags_include_members = 1
		" let g:easytags_async = 1
		" let g:easytags_python_enabled = 1
		" Cpp Neovim highlight
		" Really shitty thing
		" if has("python3") && system('pip3 list | grep psutil') =~ 'psutil'
			" Plug 'c0r73x/neotags.nvim', { 'do' : ':UpdateRemotePlugins' }
				" let g:neotags_enabled = 1
				" let g:neotags_file = g:cache_path . 'tags_neotags'
				" let g:neotags_run_ctags = 0
				" let g:neotags_ctags_timeout = 60
				" let g:neotags_events_highlight = [
								" \   'BufEnter'
								" \ ]
					" let g:neotags_events_update = [
								" \   'BufEnter'
								" \ ]

				" " if executable('rg')
					" " let g:neotags_appendpath = 0
					" " let g:neotags_recursive = 0

					" " let g:neotags_ctags_bin = 'rg -g "" --files '. getcwd() .' | ctags'
					" " let g:neotags_ctags_args = [
								" " \ '-L -',
								" " \ '--fields=+l',
								" " \ '--c-kinds=+p',
								" " \ '--c++-kinds=+p',
								" " \ '--sort=no',
								" " \ '--extra=+q'
								" " \ ]
				" " endif
		" endif
	" It doesnt fold if/while/for..etc. Only functions and classes
	Plug 'tmhedberg/SimpylFold'

	" Wed Mar 22 2017 12:51: Doenst support file type searches. Too bloated
	Plug 'mhinz/vim-grepper'

	" if !(has('win32') && has('nvim'))    " This plugin wont work until neovim supporst system() calls in window
		" Plug 'xolox/vim-easytags'
		" Plug 'xolox/vim-misc' " dependency of vim-easytags
		" Plug 'xolox/vim-shell' " dependency of vim-easytags
		" set regexpengine=1 " This speed up the engine alot but still not enough
		" let g:easytags_file = '~/.cache/ctags'
		" let g:easytags_syntax_keyword = 'always'
		" let g:easytags_auto_update = 0
		" let g:easytags_suppress_ctags_warning = 1
		" let g:easytags_python_enabled = 1
	" " Too sluggish for now. To make it work create the tag manually and added it
	" " to 'tags'
	" else
