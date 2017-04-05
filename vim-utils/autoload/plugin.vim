" File:plugin.vim
" Description:Plugin specific settings
" Author:Reinaldo Molina <rmolin88@gmail.com>
" Version:2.0.1
" Last Modified: Tue Mar 14 2017 20:07

function! plugin#Config() abort
	" Vim-Plug
		nnoremap <Leader>Pi :PlugInstall<CR>
		nnoremap <Leader>Pu :PlugUpdate<CR>
					\:PlugUpgrade<CR>
					" \:UpdateRemotePlugins<CR>
		" installs plugins; append `!` to update or just :PluginUpdate
		nnoremap <Leader>Ps :PlugSearch<CR>
		" searches for foo; append `!` to refresh local cache
		nnoremap <Leader>Pl :PlugClean<CR>

	if exists('g:portable_vim')
		silent! call plug#begin(g:plugged_path)
	else
		call plug#begin(g:plugged_path)
	endif

	" fzf only seems to work with nvim
	if has('unix') && has('nvim')
		Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
		Plug 'junegunn/fzf.vim'
			nnoremap <C-p> :History<CR>
			nnoremap <A-p> :FZF<CR>
			nnoremap <S-k> :Buffers<CR>
			let g:fzf_history_dir = '~/.cache/fzf-history'
			autocmd FileType fzf tnoremap <buffer> <C-j> <Down>
			nnoremap <leader><tab> <plug>(fzf-maps-n)
			nnoremap <leader><tab> <plug>(fzf-maps-n)
			let g:fzf_colors =
						\ { 'fg':      ['fg', 'Normal'],
						\ 'bg':      ['bg', 'Normal'],
						\ 'hl':      ['fg', 'Comment'],
						\ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
						\ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
						\ 'hl+':     ['fg', 'Statement'],
						\ 'info':    ['fg', 'PreProc'],
						\ 'prompt':  ['fg', 'Conditional'],
						\ 'pointer': ['fg', 'Exception'],
						\ 'marker':  ['fg', 'Keyword'],
						\ 'spinner': ['fg', 'Label'],
						\ 'header':  ['fg', 'Comment'] }
	else
		Plug 'ctrlpvim/ctrlp.vim'
		if executable('rg')
			let g:ctrlp_user_command = 'rg %s --no-ignore --hidden --files -g "" '
		elseif executable('ag')
			let g:ctrlp_user_command = 'ag -Q -l --smart-case --nocolor --hidden -g "" %s'
		else
			echomsg string("You should install silversearcher-ag. Now you have a slow ctrlp")
		endif
		nnoremap <S-k> :CtrlPBuffer<CR>
		" let g:ctrlp_cmd = 'CtrlPMixed'
		let g:ctrlp_cmd = 'CtrlPMRU'
		" submit ? in CtrlP for more mapping help.
		let g:ctrlp_lazy_update = 1
		let g:ctrlp_show_hidden = 1
		let g:ctrlp_match_window = 'bottom,order:btt,min:1,max:10,results:10'
		let g:ctrlp_cache_dir = g:cache_path . 'ctrlp'
		let g:ctrlp_working_path_mode = 'wra'
		let g:ctrlp_max_history = &history
		let g:ctrlp_clear_cache_on_exit = 0
		let g:ctrlp_switch_buffer = 0
		if has('win32')
			set wildignore+=*\\.git\\*,*\\.hg\\*,*\\.svn\\*  " Windows ('noshellslash')
			let g:ctrlp_custom_ignore = {
						\ 'dir':  '\v[\/]\.(git|hg|svn)$',
						\ 'file': '\v\.(tlog|log|db|obj|o|exe|so|dll|dfm)$',
						\ 'link': 'SOME_BAD_SYMBOLIC_LINKS',
						\ }
		else
			set wildignore+=*/.git/*,*/.hg/*,*/.svn/*        " Linux/MacOSX
			let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
		endif
	endif

	if executable('mutt')
		Plug 'guanqun/vim-mutt-aliases-plugin'
	endif

	if executable('gpg') && !exists('g:GuiLoaded') && !has('gui_running')
		" This plugin doesnt work with gvim. Use only from cli
		Plug 'jamessan/vim-gnupg'
		let g:GPGUseAgent = 0
	endif

	" Completion is set by g:autcompl_engine in init.vim
	if !empty(glob(g:location_vim_utils . '/autoload/autocompletion.vim'))
		execute 'source ' . g:location_vim_utils . '/autoload/autocompletion.vim'
		call autocompletion#SetCompl()
	endif

	" Neovim exclusive plugins
	if has('nvim')
		Plug 'radenling/vim-dispatch-neovim'
		" nvim-qt on unix doesnt populate has('gui_running
		Plug 'equalsraf/neovim-gui-shim'
		if executable('lldb')
			Plug 'critiqjo/lldb.nvim', { 'on' : 'LLmode debug', 'do' : ':UpdateRemotePlugins' }
			nmap <Leader>db <Plug>LLBreakSwitch
			" vmap <F2> <Plug>LLStdInSelected
			" nnoremap <F4> :LLstdin<CR>
			" nnoremap <F5> :LLmode debug<CR>
			" nnoremap <S-F5> :LLmode code<CR>
			nnoremap <Leader>dc :LL continue<CR>
			nnoremap <Leader>do :LL thread step-over<CR>
			nnoremap <Leader>di :LL thread step-in<CR>
			nnoremap <Leader>dt :LL thread step-out<CR>
			nnoremap <Leader>dD :LLmode code<CR>
			nnoremap <Leader>dd :LLmode debug<CR>
			nnoremap <Leader>dp :LL print <C-R>=expand('<cword>')<CR>
			" nnoremap <S-F8> :LL process interrupt<CR>
			" nnoremap <F9> :LL print <C-R>=expand('<cword>')<CR>
			" vnoremap <F9> :<C-U>LL print <C-R>=lldb#util#get_selection()<CR><CR>
		endif

		if executable('man')
			Plug 'nhooyr/neoman.vim'
				let g:no_neoman_maps = 1
		endif

		if has('python3') && system('pip3 list | grep psutil') =~# 'psutil'
			Plug 'c0r73x/neotags.nvim' " Depends on pip3 install --user psutil
				set regexpengine=1 " This speed up the engine alot but still not enough
				let g:neotags_enabled = 1
				" let g:neotags_file = g:cache_path . 'ctags/neotags'
				" let g:neotags_verbose = 1
				let g:neotags_run_ctags = 0
				" let g:neotags#cpp#order = 'cgstuedfpm'
				let g:neotags#cpp#order = 'ced'
				" let g:neotags#c#order = 'cgstuedfpm'
				let g:neotags#c#order = 'ced'
				" let g:neotags_events_highlight = [
				" \   'BufEnter'
				" \ ]
		endif
	endif

	Plug 'tpope/vim-dispatch' " Possible Replacement `asyncvim`
	" Vim cpp syntax highlight
	Plug 'octol/vim-cpp-enhanced-highlight', { 'for' : [ 'c' , 'cpp' ] }
		let g:cpp_class_scope_highlight = 1
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
		let g:neomake_cpp_enabled_makers = ['clang', 'gcc']
		let g:neomake_c_enabled_makers = ['clang', 'gcc']
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

		" Python. Taken from http://vi.stackexchange.com/questions/7834/how-to-setup-neomake-with-python
		let g:neomake_python_flake8_maker = {
				  \ 'args': '--format=default',
					\ 'auto_enabled' : 1,
					\ 'errorformat':
					\ '%E%f:%l: could not compile,%-Z%p^,' .
					\ '%A%f:%l:%c: %t%n %m,' .
					\ '%A%f:%l: %t%n %m,' .
					\ '%-G%.%#',
					\ }
					" \ 'args': ['--ignore=E221,E241,E272,E251,W702,E203,E201,E202',  '--format=default'],

		" Requires pip3 install --user flake8
		let g:neomake_python_enabled_makers = ['flake8']

		augroup custom_neomake
			autocmd!
			autocmd User NeomakeFinished call utils#NeomakeOpenWindow()
		augroup END

		" let g:neomake_highlight_lines = 1 " Not cool option. Plus very slow
		" let g:neomake_open_list = 2
		" let g:neomake_ft_test_maker_buffer_output = 0

	Plug 'dhruvasagar/vim-table-mode'
		" To start using the plugin in the on-the-fly mode use :TableModeToggle mapped to <Leader>tm by default
		" Enter the first line, delimiting columns by the | symbol. In the second line (without leaving Insert mode), enter | twice
		" For Markdown-compatible tables use
		" let g:table_mode_corner="|"
		let g:table_mode_corner = '+'
		let g:table_mode_align_char = ':'
		let g:table_mode_map_prefix = '<Leader>l'
		" nnoremap <Leader>lm :TableModeToggle<CR>
		" <Leader>tr	Realigns table columns

	Plug 'scrooloose/syntastic', { 'on' : 'SyntasticCheck' }
		nnoremap <Leader>so :SyntasticToggleMode<CR>
		nnoremap <Leader>ss :SyntasticCheck<CR>
		let g:syntastic_always_populate_loc_list = 1
		let g:syntastic_auto_loc_list = 1
		let g:syntastic_check_on_open = 0
		let g:syntastic_check_on_wq = 0
		let g:syntastic_cpp_compiler_options = '-std=c++17 -pedantic -Wall'
		let g:syntastic_c_compiler_options = '-std=c11 -pedantic -Wall'
		let g:syntastic_auto_jump = 3

	Plug g:location_vim_utils
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
		let g:DoxygenToolkit_briefTag_pre = "Brief:			"
		let g:DoxygenToolkit_paramTag_pre=	"	"
		let g:DoxygenToolkit_returnTag=			"Returns:   "
		let g:DoxygenToolkit_blockHeader=""
		let g:DoxygenToolkit_blockFooter=""
		let g:DoxygenToolkit_authorName="Reinaldo Molina <rmolin88@gmail.com>"
		let g:DoxygenToolkit_authorTag =	"Author:				"
		let g:DoxygenToolkit_fileTag =		"File:					"
		let g:DoxygenToolkit_briefTag_pre="		"
		let g:DoxygenToolkit_dateTag =		"Last Modified: "
		let g:DoxygenToolkit_versionTag = "Version:				"
		let g:DoxygenToolkit_commentType = "C++"
		" See :h doxygen.vim this vim related. Not plugin related
		let g:load_doxygen_syntax=1

	" misc
	Plug 'chrisbra/vim-diff-enhanced', { 'on' : 'SetDiff' }
	Plug 'scrooloose/nerdtree'
	Plug 'scrooloose/nerdcommenter'
		nmap - <plug>NERDCommenterToggle
		nmap <Leader>ot <plug>NERDCommenterAltDelims
		vmap - <plug>NERDCommenterToggle
		imap <C-c> <plug>NERDCommenterInsert
		nmap <Leader>oa <plug>NERDCommenterAppend
		vmap <Leader>os <plug>NERDCommenterSexy
	Plug 'chrisbra/Colorizer', { 'for' : [ 'css','html','xml' ] }
		let g:colorizer_auto_filetype='css,html,xml'
	Plug 'tpope/vim-repeat'
	Plug 'tpope/vim-surround'
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
	Plug 'dkarter/bullets.vim', { 'for' : 'markdown' }

	" Autoformat requires pip3 install --user autopep8
	Plug 'Chiel92/vim-autoformat', { 'on' : 'Autoformat' }
		" Simply make sure that executable('clang-format') == true
		" Grab .ros-clang-format rename to .clang-format put it in root
		" To format only partial use: 
		" // clang-format off
		" // clang-format on
		let g:autoformat_autoindent = 0
		let g:autoformat_retab = 0
		let g:autoformat_remove_trailing_spaces = 0

	" cpp
	" Note: Fix for windows nvim: comment out: 
	" set shellxquote=\"
	" And add this to the system call:
			" let ctags_output = system(substitute(a:ctags_cmd,"'", "","g"))
		" All under here:
			" function! s:ExecuteCtags(ctags_cmd) abort
	if !(has('nvim') && has('win32'))
		Plug 'Tagbar'
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
			nnoremap <Leader>tt :TagbarToggle<CR>
	endif

	" cpp/java
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
		let g:neosnippet#snippets_directory= [ g:plugged_path . '/vim-snippets/snippets', g:location_vim_utils . '/snippets/', ]
								" \ g:plugged_path . '/vim-snippets/UltiSnips'] " Not
								" compatible syntax
		let g:neosnippet#data_directory = g:cache_path . 'neosnippets'

	" Only contain snippets
	Plug 'Shougo/neosnippet-snippets'
	Plug 'honza/vim-snippets'

	" Version control
	Plug 'tpope/vim-fugitive'
		" Fugitive <Leader>g?
		" use g? to show help
		nnoremap <Leader>gs :Gstatus<bar>wincmd L<CR>
		nnoremap <Leader>gps :Gpush<CR>
		nnoremap <Leader>gpl :Gpull<CR>
		nnoremap <Leader>ga :!git add 
		nnoremap <Leader>gl :silent Glog<CR>
					\:copen 20<CR>

	" colorschemes
	Plug 'morhetz/gruvbox' " colorscheme gruvbox
	Plug 'joshdick/onedark.vim'
	" Plug 'NLKNguyen/papercolor-theme'

	" Radical
	Plug 'glts/vim-magnum' " required by radical
	Plug 'glts/vim-radical' " use with gA

	" W3M - to view cpp-reference help
	if executable('w3m')
		Plug 'yuratomo/w3m.vim'
			let g:w3m#history#save_file = g:cache_path . '/.vim_w3m_hist'
	endif

	Plug 'justinmk/vim-sneak'
		"replace 'f' with 1-char Sneak
		nmap f <Plug>Sneak_f
		nmap F <Plug>Sneak_F
		xmap f <Plug>Sneak_f
		xmap F <Plug>Sneak_F
		omap f <Plug>Sneak_f
		omap F <Plug>Sneak_F
		"replace 't' with 1-char Sneak
		nmap t <Plug>Sneak_t
		nmap T <Plug>Sneak_T
		xmap t <Plug>Sneak_t
		xmap T <Plug>Sneak_T
		omap t <Plug>Sneak_t
		omap T <Plug>Sneak_T
		xnoremap s s

	Plug 'waiting-for-dev/vim-www'
		let g:www_default_search_engine = 'google'
		let g:www_map_keys = 0
		let g:www_launch_browser_command = "chrome {{URL}}"
		let g:www_launch_cli_browser_command = "chrome {{URL}}"
		nnoremap <Leader>Gu :Wcsearch google <C-R>=expand("<cword>")<CR><CR>
		" Go to link under curson  
		vnoremap <Leader>Gu :y<bar>Wcopen <c-r><c-p><CR>
		nnoremap <Leader>Gs :Wcsearch google 

	Plug 'juneedahamed/svnj.vim'
		let g:svnj_allow_leader_mappings=0
		let g:svnj_cache_dir = g:cache_path
		let g:svnj_browse_cache_all = 1 
		let g:svnj_custom_statusbar_ops_hide = 0
		nnoremap <silent> <leader>vs :SVNStatus<CR>  
		nnoremap <silent> <leader>vo :SVNLog .<CR>  

	Plug 'itchyny/lightline.vim'
		" Inside of the functions here there can be no single quotes (') only
		" double (")
			let g:lightline = {}
			let g:lightline.active = {
								\   'left': [ 
								\							[ 'mode', 'paste' ], 
								\							[ 'readonly', 'absolutepath', 'modified', 'fugitive', 'svn', 'neomake'] 
								\						]
								\		}
		 let g:lightline.component = {
								\   'fugitive': '%{fugitive#statusline()}',
								\   'neomake': '%{neomake#statusline#QflistStatus("qf:\ ")}', 
								\   'svn': '%{svn#GetSvnBranchInfo()}', 
								\		}
								" \   'tagbar': '%{tagbar#currenttag("%s\ ","")}' 
			let g:lightline.component_visible_condition = {
								\   'fugitive': '(exists("*fugitive#head") && ""!=fugitive#head())',
								\   'neomake': '(!empty(neomake#statusline#QflistStatus("qf:\ ")))',
								\   'svn': '(!empty(svn#GetSvnBranchInfo()))',
								\		}
								" \   'tagbar': '(!empty(tagbar#currenttag("%s\ ","")))'
			" let g:lightline.colorscheme = 'onedark'
			let g:lightline.colorscheme = 'gruvbox'

	Plug 'PotatoesMaster/i3-vim-syntax'

	if has('win32')
		Plug 'PProvost/vim-ps1'
	endif

	Plug 'vim-pandoc/vim-pandoc', { 'on' : 'Pandoc' }
	Plug 'vim-pandoc/vim-pandoc-syntax', { 'on' : 'Pandoc' }
		" You might be able to get away with xelatex in unix
		let g:pandoc#command#latex_engine = "pdflatex"

	" Plug 'sheerun/vim-polyglot' " A solid language pack for Vim.
	Plug 'matze/vim-ini-fold', { 'for': 'dosini' }

	" All of your Plugins must be added before the following line
	call plug#end()            " required

	if exists("b:deoplete_loaded") " Cant call this inside of plug#begin()
		call deoplete#custom#set('javacomplete2', 'mark', '')
		call deoplete#custom#set('_', 'matchers', ['matcher_full_fuzzy'])
		" c c++
		call deoplete#custom#set('clang2', 'mark', '')
	endif

	" Create cache folders
	if utils#CheckDirwoPrompt(g:cache_path . "tmp")
		let $TMP= g:cache_path . "tmp"
	else
		echomsg string("Failed to create tmp dir")
	endif

	if !utils#CheckDirwoPrompt(g:cache_path . "sessions")
		echoerr string("Failed to create sessions dir")
	endif

	if !utils#CheckDirwoPrompt(g:cache_path . "ctags")
		echoerr string("Failed to create ctags dir")
	endif

	if !utils#CheckDirwoPrompt(g:cache_path . "java")
		echoerr string("Failed to create java dir")
	endif

	if has('persistent_undo') && !utils#CheckDirwoPrompt(g:cache_path . 'undofiles')
		echoerr string("Failed to create undofiles dir")
	endif

	return 1
endfunction

" Move this function to the os independent stuff.
function! plugin#Check() abort
	" Set paths for plugins
	if has('win32')
		" In windows wiki_path is set in the win32.vim file
		if has('nvim')
			let g:vimfile_path=  $LOCALAPPDATA . '\nvim\'
			" TODO.RM-Tue Apr 04 2017 08:48: For future support of clang on windows  
			" Find clang. Not working in windows yet.
			" if !empty(glob($ProgramFiles . '\LLVM\lib\libclang.lib'))
				" let g:libclang_path = '$ProgramFiles . '\LLVM\lib\libclang.lib''
			" endif
			" if !empty(glob($ProgramFiles . '\LLVM\lib\clang'))
				" let g:clangheader_path = '$ProgramFiles . '\LLVM\lib\clang''
			" endif
		else
			let g:vimfile_path=  $HOME . '\vimfiles\'
		endif
	else
		if has('nvim')
			if exists("$XDG_CONFIG_HOME")
				let g:vimfile_path=  $XDG_CONFIG_HOME . '/nvim/'
			else
				let g:vimfile_path=  $HOME . '/.config/nvim/'
			endif
			" deoplete-clang settings
			if !empty(glob('/usr/lib/libclang.so'))
				let g:libclang_path = '/usr/lib/libclang.so'
			endif
			if !empty(glob('/usr/lib/clang'))
				let g:clangheader_path = '/usr/lib/clang'
			endif
		else
			let g:vimfile_path=  $HOME . '/.vim/'
		endif
	endif

	" Same cache dir for both
	let g:cache_path= $HOME . '/.cache/'
	let g:plugged_path=  g:vimfile_path . 'plugged/'

	let g:usr_path = '/usr'
	if system('uname -o') =~ 'Android' " Termux stuff
		let g:android = 1
		let g:usr_path = $HOME . '/../usr'
	endif

	if exists('g:portable_vim')
		let g:plugged_path=  '../vimfiles/plugged/'
		return 1
	endif

	if empty(glob(g:vimfile_path . 'autoload/plug.vim'))
		if executable('curl')
			execute "silent !curl -fLo " . g:vimfile_path . "autoload/plug.vim --create-dirs"
						\" https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
			autocmd VimEnter * PlugInstall | source $MYVIMRC
			return 1
		else
			echomsg "Master I cant install plugins for you because you"
						\" do not have curl. Please fix this. Plugins"
						\" will not be loaded."
			return 0
		endif
	else
		return 1
	endif
endfunction

" vim:tw=78:ts=2:sts=2:sw=2:
