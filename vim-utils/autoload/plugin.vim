" File:plugin.vim
" Description:Plugin specific settings
" Author:Reinaldo Molina <rmolin88@gmail.com>
" Version:2.0.1
" Last Modified: Sun Jul 30 2017 13:13
" Created: Fri Jun 02 2017 10:44

function! plugin#Config() abort
	" Vim-Plug
		nnoremap <Leader>Pi :so %<bar>call plugin#Config()<bar>PlugInstall<CR>
		nnoremap <Leader>Pu :PlugUpdate<CR>
					\:PlugUpgrade<CR>
					\:UpdateRemotePlugins<CR>
		" installs plugins; append `!` to update or just :PluginUpdate
		nnoremap <Leader>Ps :PlugSearch<CR>
		" searches for foo; append `!` to refresh local cache
		nnoremap <Leader>Pl :PlugClean<CR>

	if exists('g:portable_vim')
		silent! call plug#begin(g:vim_plugins_path)
	else
		call plug#begin(g:vim_plugins_path)
	endif

	" Set up fuzzy searcher
	if has('unix') && has('nvim')
		" Terminal plugins
		Plug 'kassio/neoterm'
			let g:neoterm_use_relative_path = 1
			let g:neoterm_position = 'vertical'
			let g:neoterm_keep_term_open = 0
			" nnoremap <Leader>To :call neoterm#open()<CR>
			" nnoremap <Leader>Tl :call neoterm#close()<CR>
			" nnoremap <Leader>TL :call neoterm#closeAll()<CR>
			nnoremap <Leader>tk :call neoterm#kill()<CR>

		Plug 'rliang/termedit.nvim'

		Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

		" Sun Jul 30 2017 13:09 
		" Requires `install xdotool' and 'go get -u github.com/termhn/i3-vim-nav'
		" - The thing is that this down here doesnt work
		" Plug 'termhn/i3-vim-nav', { 'do' : 'ln -s ' . g:vim_plugins_path . 'i3-vim-nav/i3-vim-nav ~/.local/bin' }
	endif

	if has('nvim') || v:version >= 800
		" Plugins that support both neovim and vim need separate folders
		Plug 'Shougo/denite.nvim', { 'as' : has('nvim') ? 'nvim_denite' : 'vim_denite' }
			let denite_loaded = 1
			nnoremap <A-;> :Denite command<CR>
			nnoremap <A-e> :Denite help<CR>
			" nnoremap <S-k> :Denite buffer<CR>
			nnoremap <A-p> :Denite file_rec<CR>
		Plug 'ctrlpvim/ctrlp.vim'
			nnoremap <S-k> :CtrlPBuffer<CR>
			nnoremap <C-p> :CtrlPMRU<CR>
			" nnoremap <A-p> :CtrlPRoot<CR>
			nnoremap <A-q> :CtrlPQuickfix<CR>
			" let g:ctrlp_cmd = 'CtrlPMixed'
			let g:ctrlp_cmd = 'CtrlPMRU'
			" submit ? in CtrlP for more mapping help.
			let g:ctrlp_lazy_update = 1
			let g:ctrlp_show_hidden = 1
			let g:ctrlp_match_window = 'bottom,order:btt,min:1,max:10,results:10'
			" It says cache dir but dont want to keep loosing history everytime cache gets cleaned up
			let g:ctrlp_cache_dir = g:std_data_path . '/ctrlp'
			let g:ctrlp_working_path_mode = 'wra'
			let g:ctrlp_max_history = &history
			let g:ctrlp_clear_cache_on_exit = 0
			let g:ctrlp_switch_buffer = 0
			let g:ctrlp_mruf_max = 10000
			if has('win32')
				let g:ctrlp_mruf_exclude = '^C:\\dev\\tmp\\Temp\\.*'
				set wildignore+=*\\.git\\*,*\\.hg\\*,*\\.svn\\*  " Windows ('noshellslash')
				let g:ctrlp_custom_ignore = {
							\ 'dir':  '\v[\/]\.(git|hg|svn)$',
							\ 'file': '\v\.(tlog|log|db|obj|o|exe|so|dll|dfm)$',
							\ 'link': 'SOME_BAD_SYMBOLIC_LINKS',
							\ }
			else
				let g:ctrlp_mruf_exclude =  '/tmp/.*\|/temp/.*'
				set wildignore+=*/.git/*,*/.hg/*,*/.svn/*        " Linux/MacOSX
				let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
			endif
			let g:ctrlp_prompt_mappings = { 
						\ 'PrtBS()': ['<bs>', '<c-h>'], 
						\ 'PrtCurLeft()': ['<left>', '<c-^>'], 
						\ 'PrtCurRight()': ['<right>'],
						\ }
	endif

	if executable('mutt')
		Plug 'guanqun/vim-mutt-aliases-plugin'
	endif

	if executable('gpg') && !exists('g:GuiLoaded') && !has('gui_running')
		" This plugin doesnt work with gvim. Use only from cli
		Plug 'jamessan/vim-gnupg'
		let g:GPGUseAgent = 0
	endif

		" Possible values:
		" - ycm nvim_compl_manager shuogo autocomplpop completor asyncomplete
		call autocompletion#SetCompl(has('nvim') ? 'nvim_compl_manager' : 'shuogo')

		" Possible values:
		" - chromatica easytags neotags color_coded clighter8
		call cpp_highlight#SetCppHighlight(has('nvim') ? 'neotags' : '')

	" Neovim exclusive plugins
	if has('nvim')
		" Note: Thu Aug 24 2017 21:03 This plugin is actually required for the git
		" plugin to work in neovim
		Plug 'radenling/vim-dispatch-neovim'
		" nvim-qt on unix doesnt populate has('gui_running
		Plug 'equalsraf/neovim-gui-shim'
		if executable('lldb')
			Plug 'critiqjo/lldb.nvim'
			" All mappings moved to c.vim
			" Note: Remember to always :UpdateRemotePlugins
			"TODO.RM-Sun May 21 2017 01:14: Create a ftplugin/lldb.vim to disable
			"folding  
		endif
	endif

	Plug 'tpope/vim-dispatch' " Possible Replacement `asyncvim`
	" Vim cpp syntax highlight
	Plug 'octol/vim-cpp-enhanced-highlight', { 'for' : [ 'c' , 'cpp' ] }
		let g:cpp_class_scope_highlight = 1
		let g:cpp_member_variable_highlight = 1
		let g:cpp_class_decl_highlight = 1
		let g:cpp_concepts_highlight = 1
	Plug 'justinmk/vim-syntax-extra'

	" Plugins for All (nvim, linux, win32)
	Plug 'neomake/neomake'
		let g:neomake_warning_sign = {
					\ 'text': '?',
					\ 'texthl': 'WarningMsg',
					\ }

		let g:neomake_error_sign = {
					\ 'text': 'X',
					\ 'texthl': 'ErrorMsg',
					\ }
		let g:neomake_cpp_enabled_makers = ['gcc', 'clang']
		let g:neomake_c_enabled_makers = ['gcc', 'clang']
		let g:neomake_cpp_clang_maker = {
					\ 'args': ['-fsyntax-only', '-std=c++14', '-Wall', '-Wextra'],
					\ 'errorformat':
					\ '%-G%f:%s:,' .
					\ '%f:%l:%c: %trror: %m,' .
					\ '%f:%l:%c: %tarning: %m,' .
					\ '%f:%l:%c: %m,'.
					\ '%f:%l: %trror: %m,'.
					\ '%f:%l: %tarning: %m,'.
					\ '%f:%l: %m',
					\ }
		augroup custom_neomake
			autocmd!
			autocmd User NeomakeFinished echo "Neomake Finished!"
		augroup END

	Plug 'dhruvasagar/vim-table-mode', { 'on' : 'TableModeToggle' }
		" To start using the plugin in the on-the-fly mode use :TableModeToggle
		" mapped to <Leader>tm by default Enter the first line, delimiting columns
		" by the | symbol. In the second line (without leaving Insert mode), enter
		" | twice For Markdown-compatible tables use
		let g:table_mode_corner='|'
		" let g:table_mode_corner = '+'
		let g:table_mode_align_char = ':'
		" TODO.RM-Wed Jul 19 2017 21:10: Fix here these mappings are for terminal  
		let g:table_mode_map_prefix = '<Leader>lt'
		let g:table_mode_disable_mappings = 1
		" nnoremap <Leader>lm :TableModeToggle<CR>
		" <Leader>tr	Realigns table columns

	Plug 'scrooloose/syntastic'
		let g:syntastic_aggregate_errors = 1
		let g:syntastic_always_populate_loc_list = 1
		let g:syntastic_auto_loc_list = 0
		let g:syntastic_check_on_open = 0
		let g:syntastic_check_on_wq = 0
		let g:syntastic_auto_jump = 0
		" Note: Checkers and passive/active mode is handled at after/ftplugin files
		let g:syntastic_cpp_compiler_options = '-std=c++17 -pedantic -Wall'
		let g:syntastic_cpp_include_dirs = [ 'includes', 'headers', 'inc' ]
		let g:syntastic_cpp_clang_check_args = '-extra-arg=-std=c++1z'

		let g:syntastic_c_remove_include_errors = 1
		let g:syntastic_c_compiler_options = '-std=c11 -pedantic -Wall'
		" let g:syntastic_cpp_check_header = 1

	Plug g:location_vim_utils
		" Load the rest of the stuff and set the settings
		let g:svn_repo_url = 'svn://odroid@copter-server/' 
		let g:svn_repo_name = 'UnrealEngineCourse/BattleTanks_2/'
		nnoremap <Leader>vw :call SVNSwitch<CR>
		nnoremap <Leader>vb :call SVNCopy<CR>

		nnoremap <Leader>of :Dox<CR>
		" Other commands
		" command! -nargs=0 DoxLic :call <SID>DoxygenLicenseFunc()
		" command! -nargs=0 DoxAuthor :call <SID>DoxygenAuthorFunc()
		" command! -nargs=1 DoxUndoc :call <SID>DoxygenUndocumentFunc(<q-args>)
		" command! -nargs=0 DoxBlock :call <SID>DoxygenBlockFunc()
		let g:DoxygenToolkit_paramTag_pre=	"	"
		let g:DoxygenToolkit_returnTag=			"Returns:   "
		let g:DoxygenToolkit_blockHeader=""
		let g:DoxygenToolkit_blockFooter=""
		let g:DoxygenToolkit_authorName="Reinaldo Molina <rmolin88@gmail.com>"
		let g:DoxygenToolkit_authorTag =	"Author:				"
		let g:DoxygenToolkit_fileTag =		"File:					"
		let g:DoxygenToolkit_briefTag_pre="Description:		"
		let g:DoxygenToolkit_dateTag =		"Last Modified: "
		let g:DoxygenToolkit_versionTag = "Version:				"
		let g:DoxygenToolkit_commentType = "C++"
		let g:DoxygenToolkit_versionString = "0.0.0"
		" See :h doxygen.vim this vim related. Not plugin related
		let g:load_doxygen_syntax=1

	" misc
	Plug 'chrisbra/vim-diff-enhanced', { 'on' : 'UtilsDiffSet' }

	" FileBrowser
	" Wed May 03 2017 11:31: Tried `vifm` doesnt work in windows. Doesnt
	" follow `*.lnk` shortcuts. Not close to being Replacement for `ranger`.
	" Main reason it looks appealing is that it has support for Windows. But its
	" not very good
	if executable('ranger')
		Plug 'francoiscabrol/ranger.vim'
		let g:ranger_map_keys = 0
		nnoremap <Plug>FileBrowser :RangerCurrentDirectory<CR>
	else
		Plug 'scrooloose/nerdtree'
		nnoremap <Plug>FileBrowser :NERDTree<CR>
		" Nerdtree (Dont move. They need to be here)
		let g:NERDTreeShowBookmarks=1  " B key to toggle
		let g:NERDTreeShowLineNumbers=1
		let g:NERDTreeShowHidden=1 " i key to toggle
		let g:NERDTreeQuitOnOpen=1 " AutoClose after openning file
		let g:NERDTreeBookmarksFile= g:std_data_path . '/.NERDTreeBookmarks'

	endif

	Plug 'scrooloose/nerdcommenter'
		" NerdCommenter
		let g:NERDSpaceDelims=1  " space around comments
		let g:NERDUsePlaceHolders=0 " avoid commenter doing weird stuff
		let g:NERDCommentWholeLinesInVMode=2
		let g:NERDCreateDefaultMappings=0 " Eliminate default mappings
		let g:NERDRemoveAltComs=1 " Remove /* comments
		let g:NERD_c_alt_style=0 " Do not use /* on C nor C++
		let g:NERD_cpp_alt_style=0
		let g:NERDMenuMode=0 " no menu
		let g:NERDCustomDelimiters = {
					\ 'vim': { 'left': '"', 'right': '', 'leftAlt': '#', 'rightAlt': ''},
					\ 'markdown': { 'left': '//', 'right': '' },
					\ 'dosini': { 'left': ';', 'leftAlt': '//', 'right': '', 'rightAlt': '' },
					\ 'csv': { 'left': '#', 'right': '' },
					\ 'wings_syntax': { 'left': '//', 'right': '', 'leftAlt': '//', 'rightAlt': '' }
					\ }

	Plug 'chrisbra/Colorizer', { 'for' : [ 'css','html','xml' ] }
		let g:colorizer_auto_filetype='css,html,xml'
	Plug 'tpope/vim-repeat'
	Plug 'tpope/vim-surround'

	" Fold stuff
	" Fri May 19 2017 12:50 I have tried many times to get 'fdm=syntax' to work
	" on large files but its just not possible. Too slow.
	Plug 'Konfekt/FastFold'
		" Stop updating folds everytime I save a file
		let g:fastfold_savehook = 0
		" To update folds now you have to do it manually pressing 'zuz'
		let g:fastfold_fold_command_suffixes =
					\['x','X','a','A','o','O','c','C','r','R','m','M','i','n','N']

	Plug 'airblade/vim-rooter'
		let g:rooter_manual_only = 1
		nnoremap <Leader>cr :Rooter<CR>
		" nnoremap <Leader>cr :call utils#RooterAutoloadCscope()<CR>
	Plug 'Raimondi/delimitMate'
		let g:delimitMate_expand_cr = 1
		let g:delimitMate_expand_space = 1
		let g:delimitMate_jump_expansion = 1
		" imap <expr> <CR> <Plug>delimitMateCR

	Plug 'sbdchd/neoformat', { 'on' : 'Neoformat' }
		let g:neoformat_c_clangformat = {
					\ 'exe': 'clang-format',
					\ 'args': ['-style=file'],
					\ }
		let g:neoformat_cpp_clangformat = {
					\ 'exe': 'clang-format',
					\ 'args': ['-style=file'],
					\ }

	" cpp
	if get(g:, 'tagbar_safe_to_use', 1)
		Plug 'majutsushi/tagbar'
			let g:tagbar_ctags_bin = 'ctags'
			let g:tagbar_autofocus = 1
			let g:tagbar_show_linenumbers = 2
			let g:tagbar_map_togglesort = "r"
			let g:tagbar_map_nexttag = "<c-j>"
			let g:tagbar_map_prevtag = "<c-k>"
			let g:tagbar_map_openallfolds = "<c-n>"
			let g:tagbar_map_closeallfolds = "<c-c>"
			let g:tagbar_map_togglefold = "<c-x>"
			let g:tagbar_autoclose = 1
	endif

	" python
		" Plug 'python-mode/python-mode', { 'for' : 'python' } " Extremely
		" aggressive

		" pip install isort --user
		Plug 'fisadev/vim-isort', { 'for' : 'python' }
			let g:vim_isort_map = ''
			let g:vim_isort_python_version = 'python3'

	" java
	Plug 'mattn/vim-javafmt', { 'for' : 'java' }
	Plug 'tfnico/vim-gradle', { 'for' : 'java' }
	Plug 'artur-shaik/vim-javacomplete2', { 'branch' : 'master', 'for' : 'java' }
		let g:JavaComplete_ClosingBrace = 1
		let g:JavaComplete_EnableDefaultMappings = 0
		let g:JavaComplete_ImportSortType = 'packageName'
		let g:JavaComplete_ImportOrder = ['android.', 'com.', 'junit.', 'net.', 'org.', 'java.', 'javax.']

	" Autocomplete
	Plug 'Shougo/neosnippet'
		imap <C-k>     <Plug>(neosnippet_expand_or_jump)
		smap <C-k>     <Plug>(neosnippet_expand_or_jump)
		xmap <C-k>     <Plug>(neosnippet_expand_target)
		smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
					\ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
		" Tell Neosnippet about the other snippets
		let g:neosnippet#snippets_directory= [ g:vim_plugins_path . '/vim-snippets/snippets', g:location_vim_utils . '/snippets/', ]
		let g:neosnippet#data_directory = g:std_data_path . '/neosnippets'
		" Used by nvim-completion-mgr
		let g:neosnippet#enable_completed_snippet=1

	" Only contain snippets
	Plug 'Shougo/neosnippet-snippets'
	Plug 'honza/vim-snippets'

	" Version control
	Plug 'tpope/vim-fugitive'
		" Fugitive <Leader>g?
		" use g? to show help
		" nmap here is needed for the <C-n> to work. Otherwise it doesnt know what
		" it means
		nmap <Leader>gs :Gstatus<CR><C-w>L<C-n>
		nnoremap <Leader>gps :Gpush<CR>
		nnoremap <Leader>gpl :Gpull<CR>
		nnoremap <Leader>ga :!git add 
		nnoremap <Leader>gl :silent Glog<CR>
					\:copen 20<CR>

	Plug 'mhinz/vim-signify'
		" Mappings are ]c next differences
		" Mappings are [c prev differences
		let g:signify_disable_by_default = 1
		let g:signify_vcs_list = [ 'git', 'svn' ]
		nnoremap <Leader>jS :SignifyToggle<CR>

	Plug 'juneedahamed/svnj.vim'
		let g:svnj_allow_leader_mappings=0
		let g:svnj_cache_dir = g:std_cache_path
		let g:svnj_browse_cache_all = 1 
		let g:svnj_custom_statusbar_ops_hide = 0
		nnoremap <silent> <leader>vs :SVNStatus<CR>  
		nnoremap <silent> <leader>vo :SVNLog .<CR>  


	" colorschemes
	Plug 'morhetz/gruvbox' " colorscheme gruvbox
	Plug 'NLKNguyen/papercolor-theme'
	" Sun May 07 2017 16:25 - Gave it a try and didnt like it 
	" Plug 'icymind/NeoSolarized'

	" Radical
	Plug 'glts/vim-magnum' " required by radical
	Plug 'glts/vim-radical' " use with gA

	" W3M - to view cpp-reference help
	if executable('w3m')
		" TODO-[RM]-(Thu Sep 14 2017 21:12): No chance to get this working on windows
		Plug 'yuratomo/w3m.vim'
			let g:w3m#history#save_file = g:std_cache_path . '/vim_w3m_hist'
			" Mon Sep 18 2017 22:37: To open html file do `:W3mLocal %'
	endif

	Plug 'justinmk/vim-sneak'
		" replace 'f' with 1-char Sneak
		nmap f <Plug>Sneak_f
		nmap F <Plug>Sneak_F
		xmap f <Plug>Sneak_f
		xmap F <Plug>Sneak_F
		omap f <Plug>Sneak_f
		omap F <Plug>Sneak_F
		" replace 't' with 1-char Sneak
		nmap t <Plug>Sneak_t
		nmap T <Plug>Sneak_T
		xmap t <Plug>Sneak_t
		xmap T <Plug>Sneak_T
		omap t <Plug>Sneak_t
		omap T <Plug>Sneak_T
		xnoremap s s

	Plug 'waiting-for-dev/vim-www'
		" TODO-[RM]-(Thu Sep 14 2017 21:02): Update this here
		let g:www_default_search_engine = 'google'
		let g:www_map_keys = 0
		let g:www_launch_browser_command = "chrome {{URL}}"
		let g:www_launch_cli_browser_command = "chrome {{URL}}"
		nnoremap <Leader>Gu :Wcsearch google <C-R>=expand("<cword>")<CR><CR>
		" Go to link under cursor  
		vnoremap <Leader>Gu :call utils#SearchHighlighted()<CR>
		nnoremap <Leader>Gs :Wcsearch google 

	Plug 'itchyny/lightline.vim'
		" Inside of the functions here there can be no single quotes (') only double (")
		if !exists('g:lightline')
			let g:lightline = {}
		endif
		let g:lightline.active = {
						\   'left': [ 
						\							[ 'mode', 'paste' ], 
						\							[ 'readonly', 'absolutepath', 'modified' ] 
						\						]
						\		}
		if executable('git')
			let g:lightline.active.left[1] += [ 'fugitive' ]
		endif
		if executable('svn')
			let g:lightline.active.left[1] += [ 'svn' ]
		endif
		let g:lightline.active.left[1] += [ 'tagbar' ]
		let g:lightline.active.left[1] += [ 'pomodoro' ]

		let g:lightline.component = {
							\   'fugitive': '%{fugitive#statusline()}',
							\   'svn': '%{svn#GetSvnBranchInfo()}', 
							\   'tagbar': '%{tagbar#currenttag("%s\ ","")}',
							\   'pomodoro': '%{pomo#status_bar()}' 
							\		}
		" Sat Sep 23 2017 17:29: This is how you get a message to show on red 
		" \   'pomodoro': '%#ErrorMsg#%{pomo#status()}%#StatusLine#' 
		let g:lightline.component_visible_condition = {
							\   'fugitive': '(exists("*fugitive#head") && ""!=fugitive#head())',
							\   'svn': '(!empty(svn#GetSvnBranchInfo()))',
							\   'tagbar': '(!empty(tagbar#currenttag("%s\ ","")))',
							\   'pomodoro': '(!empty(pomo#status()))'
							\		}
		" let g:lightline.colorscheme = 'onedark'
		" let g:lightline.colorscheme = 'gruvbox'
		let g:lightline.colorscheme = 'PaperColor'

	Plug 'PotatoesMaster/i3-vim-syntax'

	if has('win32')
		Plug 'PProvost/vim-ps1'
	endif

	Plug 'vim-pandoc/vim-pandoc', { 'on' : 'Pandoc' }
	Plug 'vim-pandoc/vim-pandoc-syntax', { 'on' : 'Pandoc' }
		" You might be able to get away with xelatex in unix
		let g:pandoc#command#latex_engine = "pdflatex"
		let g:pandoc#folding#fdc=0
		let g:pandoc#keyboard#use_default_mappings=0
		" Pandoc pdf --template eisvogel --listings
		" PandocTemplate save eisvogel
		" Pandoc #eisvogel

	" Plug 'sheerun/vim-polyglot' " A solid language pack for Vim.
	Plug 'matze/vim-ini-fold', { 'for': 'dosini' }

	" Not being used but kept for dependencies
	Plug 'rbgrouleff/bclose.vim'

	Plug 'godlygeek/tabular'
		let g:no_default_tabular_maps = 1
	
	" This plugin depends on 'godlygeek/tabular'
	Plug 'plasticboy/vim-markdown'
		let g:vim_markdown_no_default_key_mappings = 1
		let g:vim_markdown_toc_autofit = 1
		let g:tex_conceal = ""
		let g:vim_markdown_math = 1
		let g:vim_markdown_folding_level = 2
		let g:vim_markdown_frontmatter = 1
		let g:vim_markdown_new_list_item_indent = 0

	"Sun Sep 10 2017 20:44 Depends on plantuml being installed  
	Plug 'scrooloose/vim-slumlord', { 'for' : 'uml' }
	Plug 'aklt/plantuml-syntax', { 'for' : 'uml' }

	Plug 'merlinrebrovic/focus.vim', { 'on' : 'FocusModeToggle' }
			let g:focus_use_default_mapping = 0

	Plug 'dbmrq/vim-ditto'
		let g:ditto_dir = g:std_data_path
		let g:ditto_file = 'ditto-ignore.txt'

	" TODO-[RM]-(Sun Sep 10 2017 20:27): Dont really like it
	Plug 'reedes/vim-wordy'
		let g:wordy#ring = [
					\ 'weak',
					\ ['being', 'passive-voice', ],
					\ 'business-jargon',
					\ 'weasel',
					\ 'puffery',
					\ ['problematic', 'redundant', ],
					\ ['colloquial', 'idiomatic', 'similies', ],
					\ 'art-jargon',
					\ ['contractions', 'opinion', 'vague-time', 'said-synonyms', ],
					\ 'adjectives',
					\ 'adverbs',
				\ ]

	" TODO-[RM]-(Sun Sep 10 2017 20:26): So far only working on linux
	Plug 'beloglazov/vim-online-thesaurus'
		let g:online_thesaurus_map_keys = 0

	" Autocorrect mispellings on the fly
	Plug 'panozzaj/vim-autocorrect'

	" Sun Sep 10 2017 20:44 Depends on languagetool being installed 
	if !empty('g:languagetool_jar')
		Plug 'dpelle/vim-LanguageTool', { 'for' : 'markdown' }
	endif

	Plug 'rmolin88/pomodoro.vim'
		" let g:pomodoro_show_time_remaining = 0 
		" let g:pomodoro_time_slack = 1 
		" let g:pomodoro_time_work = 1 
		if executable('twmnc')
			let g:pomodoro_notification_cmd = 'twmnc -t Vim -c "Pomodoro done"'
		endif
	" %#ErrorMsg#%{PomodoroStatus()}%#StatusLine# 

	Plug 'chrisbra/csv.vim', { 'for' : 'csv' }
		let g:no_csv_maps = 1
		let g:csv_autocmd_arrange      = 1
		let g:csv_autocmd_arrange_size = 1024*1024

	" All of your Plugins must be added before the following line
	call plug#end()            " required

	if exists('*deoplete#custom#set')
		call deoplete#custom#set('javacomplete2', 'mark', '')
		call deoplete#custom#set('_', 'matchers', ['matcher_full_fuzzy'])
		" c c++
		call deoplete#custom#set('clang2', 'mark', '')
	endif

	if exists('denite_loaded')
		" Change mappings.
		call denite#custom#map('insert','<C-j>','<denite:move_to_next_line>','noremap')
		call denite#custom#map('insert','<C-k>','<denite:move_to_previous_line>','noremap')
		call denite#custom#map('insert','<C-v>','<denite:do_action:vsplit>','noremap')
		" Change options
		call denite#custom#option('default', 'winheight', 15)
		call denite#custom#option('_', 'highlight_matched_char', 'Function')
		call denite#custom#option('_', 'highlight_matched_range', 'Function')
		if executable('rg')
			call denite#custom#var('file_rec', 'command',
						\ ['rg', '--glob', '!.git', '--glob', '!.svn', '--files',  ''])
		endif
	endif

	" Create required folders for storing usage data
	call utils#CheckDirwoPrompt(g:std_data_path . '/sessions')
	call utils#CheckDirwoPrompt(g:std_data_path . '/ctags')
	if has('persistent_undo') 
		let g:undofiles_path = g:std_cache_path . '/undofiles'
		call utils#CheckDirwoPrompt(g:undofiles_path)
	endif

	return 1
endfunction

function! plugin#Check() abort
	" Set default path for location of vim_plugins
	if !exists('g:vim_plugins_path')
		let g:vim_plugins_path = g:std_data_path . '/vim_plugins'
	endif

	let plug_path = g:std_data_path . '/vim-plug/plug.vim' 
	if empty(glob(plug_path))
		if executable('curl')
			execute "silent !curl -kfLo " . plug_path . " --create-dirs"
						\" https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
			autocmd VimEnter * execute("source " . plug_path) | PlugInstall
			return 1
		else
			echomsg "Master I cant install plugins for you because you"
						\" do not have curl. Please fix this. Plugins"
						\" will not be loaded."
			return 0
		endif
	else
		execute "source " . plug_path
		return 1
	endif
endfunction

" vim:tw=78:ts=2:sts=2:sw=2:
