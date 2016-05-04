
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
