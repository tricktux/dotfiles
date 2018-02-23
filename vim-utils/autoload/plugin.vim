" File:				plugin.vim
" Description:Plugin specific settings
" Author:			Reinaldo Molina <rmolin88@gmail.com>
" Version:			2.0.1
" Last Modified: Thu Feb 22 2018 10:36
" Created: Fri Jun 02 2017 10:44

" List of pip requirements for your plugins:
" - pip3 install --user neovim psutil vim-vint
"   - on arch: python-vint python-neovin python-psutil
"   - However, pip is the preferred method. Not so sure becuase then you have to updated
"   manually.
" - These are mostly for python stuff
" - jedi mistune setproctitle jedi flake8 autopep8

" This function should not abort on error. Let continue configuring stuff
function! plugin#Config()
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

	call s:configure_async_plugins()

	call s:configure_ctrlp()

	if executable('mutt')
		Plug 'guanqun/vim-mutt-aliases-plugin'
	endif

	if executable('gpg')
		" This plugin doesnt work with gvim. Use only from cli
		Plug 'jamessan/vim-gnupg'
		let g:GPGUseAgent = 0
	endif

	" Possible values:
	" - ycm nvim_compl_manager shuogo autocomplpop completor asyncomplete neo_clangd
	" call autocompletion#SetCompl(has('nvim') ? 'nvim_compl_manager' : 'shuogo')
	call autocompletion#SetCompl('shuogo')

	" Possible values:
	" - chromatica easytags neotags color_coded clighter8
	call cpp_highlight#Set(has('nvim') ? 'neotags' : '')

	" Possible values:
	" - neomake ale
	let linter = 'neomake'
	call linting#Set(linter)

	" Neovim exclusive plugins
	if has('nvim')
		" Note: Thu Aug 24 2017 21:03 This plugin is actually required for the git
		" plugin to work in neovim
		Plug 'radenling/vim-dispatch-neovim'
		" nvim-qt on unix doesnt populate has('gui_running')
		Plug 'equalsraf/neovim-gui-shim'
		if executable('lldb') && has('unix')
			Plug 'critiqjo/lldb.nvim'
			" All mappings moved to c.vim
			" Note: Remember to always :UpdateRemotePlugins
			"TODO.RM-Sun May 21 2017 01:14: Create a ftplugin/lldb.vim to disable
			"folding
		endif
	endif

	" Possible Replacement `asyncvim`
	Plug 'tpope/vim-dispatch'
	" Vim cpp syntax highlight
	Plug 'octol/vim-cpp-enhanced-highlight', { 'for' : [ 'c' , 'cpp' ] }
		let g:cpp_class_scope_highlight = 1
		let g:cpp_member_variable_highlight = 1
		let g:cpp_class_decl_highlight = 1
		let g:cpp_concepts_highlight = 1
	Plug 'justinmk/vim-syntax-extra'

	call s:configure_vim_table_mode()

	call s:configure_vim_utils()

	" misc
	if executable('git')
		Plug 'chrisbra/vim-diff-enhanced'
			let &diffexpr='EnhancedDiff#Diff("git diff", "--diff-algorithm=patience")'
	endif

	" Options: netranger, nerdtree
	call s:configure_file_browser((executable('ranger') ? 'ranger' : 'nerdtree'))

	call s:configure_nerdcommenter()

	Plug 'chrisbra/Colorizer', { 'for' : [ 'css','html','xml' ] }
		let g:colorizer_auto_filetype='css,html,xml'
	Plug 'tpope/vim-repeat'
	Plug 'tpope/vim-surround'

	" Fold stuff
	" Fri May 19 2017 12:50 I have tried many times to get 'fdm=syntax' to work
	" on large files but its just not possible. Too slow.
	Plug 'Konfekt/FastFold', { 'on' : 'FastFold' }
		" Stop updating folds everytime I save a file
		let g:fastfold_savehook = 0
		" To update folds now you have to do it manually pressing 'zuz'
		let g:fastfold_fold_command_suffixes =
					\['x','X','a','A','o','O','c','C','r','R','m','M','i','n','N']

	Plug 'airblade/vim-rooter', { 'on' : 'Rooter' }
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
		call s:configure_tagbar()
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
	call s:configure_snippets()

	" Version control
	Plug 'tpope/vim-fugitive'
		" Fugitive <Leader>g?
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
		" Gets enabled when you call SignifyToggle
		let g:signify_disable_by_default = 1
		let g:signify_vcs_list = [ 'git', 'svn' ]

	Plug 'juneedahamed/svnj.vim', { 'on' : 'SVNStatus' }
		let g:svnj_allow_leader_mappings=0
		let g:svnj_cache_dir = g:std_cache_path
		let g:svnj_browse_cache_all = 1
		let g:svnj_custom_statusbar_ops_hide = 0
		nnoremap <silent> <leader>vs :SVNStatus q<CR>
		nnoremap <silent> <leader>vo :SVNLog .<CR>

	" colorschemes
	Plug 'morhetz/gruvbox' " colorscheme gruvbox
	Plug 'NLKNguyen/papercolor-theme'
	" Mon Jan 08 2018 15:08: Do not load these schemes unless they are going to be used
	" Sun May 07 2017 16:25 - Gave it a try and didnt like it
	" Plug 'icymind/NeoSolarized'
	" Sat Oct 14 2017 15:50: Dont like this one either.
	" Plug 'google/vim-colorscheme-primary'
	" Sat Oct 14 2017 15:59: Horrible looking
	" Plug 'joshdick/onedark.vim'
	" Plug 'altercation/vim-colors-solarized'
	" Plug 'jnurmine/Zenburn'

	" Magnum is required by vim-radical. use with gA
	Plug 'glts/vim-magnum', { 'on' : '<Plug>RadicalView' }
	Plug 'glts/vim-radical', { 'on' : '<Plug>RadicalView' }
		nnoremap gA <Plug>RadicalView

	" W3M - to view cpp-reference help
	if executable('w3m')
		" TODO-[RM]-(Thu Sep 14 2017 21:12): No chance to get this working on windows
		Plug 'yuratomo/w3m.vim'
			let g:w3m#history#save_file = g:std_cache_path . '/vim_w3m_hist'
			" Mon Sep 18 2017 22:37: To open html file do `:W3mLocal %'
	endif

	call s:configure_vim_sneak()

	Plug 'waiting-for-dev/vim-www'
		" TODO-[RM]-(Thu Sep 14 2017 21:02): Update this here
		let g:www_map_keys = 0
		let g:www_launch_cli_browser_command = g:browser_cmd . ' {{URL}}'
		nnoremap gG :Wcsearch duckduckgo <C-R>=expand("<cword>")<CR><CR>
		vnoremap gG "*y:call www#www#user_input_search(1, @*)<CR>

	call s:configure_lightline(linter)

	Plug 'PotatoesMaster/i3-vim-syntax'

	if has('win32')
		Plug 'PProvost/vim-ps1', { 'for' : 'ps1' }
	endif

	Plug 'vim-pandoc/vim-pandoc', { 'on' : 'Pandoc' }
	Plug 'vim-pandoc/vim-pandoc-syntax', { 'on' : 'Pandoc' }
		" You might be able to get away with xelatex in unix
		let g:pandoc#command#latex_engine = 'pdflatex'
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
	Plug 'plasticboy/vim-markdown', { 'for' : 'markdown' }
		let g:vim_markdown_no_default_key_mappings = 1
		let g:vim_markdown_toc_autofit = 1
		let g:tex_conceal = ''
		let g:vim_markdown_math = 1
		let g:vim_markdown_folding_level = 2
		let g:vim_markdown_frontmatter = 1
		let g:vim_markdown_new_list_item_indent = 0

	" Sun Sep 10 2017 20:44 Depends on plantuml being installed
	" If you want dont want to image preview after loading the plugin put the
	" comment:
	"		'no-preview
	"	in your file
	Plug 'scrooloose/vim-slumlord', { 'on' : 'UtilsUmlInFilePreview' }
	Plug 'aklt/plantuml-syntax', { 'for' : 'plantuml' }

	Plug 'merlinrebrovic/focus.vim', { 'on' : '<Plug>FocusModeToggle' }
			let g:focus_use_default_mapping = 0
			nmap <Leader>tf <Plug>FocusModeToggle

	Plug 'dbmrq/vim-ditto', { 'for' : 'markdown' }
		let g:ditto_dir = g:std_data_path
		let g:ditto_file = 'ditto-ignore.txt'

	" TODO-[RM]-(Sun Sep 10 2017 20:27): Dont really like it
	call s:configure_vim_wordy()

	" TODO-[RM]-(Sun Sep 10 2017 20:26): So far only working on linux
	Plug 'beloglazov/vim-online-thesaurus', { 'on' : 'OnlineThesaurusCurrentWord' }
		let g:online_thesaurus_map_keys = 0

	" Autocorrect mispellings on the fly
	Plug 'panozzaj/vim-autocorrect', { 'for' : 'markdown' }
	" Disble this file by removing its function call from autload/markdown.vim

	" Sun Sep 10 2017 20:44 Depends on languagetool being installed
	if !empty('g:languagetool_jar')
		Plug 'dpelle/vim-LanguageTool', { 'for' : 'markdown' }
	endif

	call s:configure_pomodoro()

	Plug 'chrisbra/csv.vim', { 'for' : 'csv' }
		let g:no_csv_maps = 1
    let g:csv_strict_columns = 1
		augroup Csv_Arrange
			autocmd!
			autocmd BufWritePost *.csv call CsvArrangeColumns()
		augroup END
		" let g:csv_autocmd_arrange      = 1
		" let g:csv_autocmd_arrange_size = 1024*1024

	" Thu Jan 25 2018 17:36: Not that useful. More useful is mapping N to center the screen as well
	" Plug 'google/vim-searchindex'

	" Documentation plugins
	Plug 'rhysd/devdocs.vim', { 'on' : '<Plug>(devdocs-under-cursor)' }
		" Sample mapping in a ftplugin/*.vim
		nmap ghd <Plug>(devdocs-under-cursor)


	Plug 'KabbAmine/zeavim.vim', {'on': [
				\	'Zeavim', 'Docset',
				\	'<Plug>Zeavim',
				\	'<Plug>ZVVisSelection',
				\	'<Plug>ZVKeyDocset',
				\	'<Plug>ZVMotion'
				\ ]}
		let g:zv_disable_mapping = 1
		nmap ghz <Plug>Zeavim

	" Only for arch
	if executable('dasht')
		Plug 'sunaku/vim-dasht', { 'on' : 'Dasht' }
			" When in C++, also search C, Boost, and OpenGL:
			let g:dasht_filetype_docsets['cpp'] = ['^c$', 'boost', 'OpenGL']
	endif

	Plug 'itchyny/calendar.vim', { 'on' : 'Calendar' }
		let g:calendar_google_calendar = 1
		let g:calendar_cache_directory = g:std_cache_path . '/calendar.vim/'

	" Tue Oct 31 2017 11:30: Needs to be loaded last
	Plug 'ryanoasis/vim-devicons'
		let g:WebDevIconsUnicodeDecorateFolderNodes = 1
		let g:DevIconsEnableFoldersOpenClose = 1

	Plug 'chaoren/vim-wordmotion'
		let g:wordmotion_spaces = '_-.'
		let g:wordmotion_mappings = {
					\ 'w' : '',
					\ 'b' : '<c-b>',
					\ 'e' : '<c-e>',
					\ 'ge' : '',
					\ 'aw' : '',
					\ 'iw' : '',
					\ '<C-R><C-W>' : ''
					\ }

	" Software caps lock. imap <c-l> ToggleSoftwareCaps
	Plug 'tpope/vim-capslock'

	Plug 'hari-rangarajan/CCTree'

	Plug 'bronson/vim-trailing-whitespace'
		let g:extra_whitespace_ignored_filetypes = []

	Plug 'jsfaint/gen_tags.vim' " Not being suppoprted anymore
		let g:gen_tags#ctags_auto_gen = 1
		let g:gen_tags#gtags_auto_gen = 1
		let g:gen_tags#use_cache_dir = 1
		let g:gen_tags#ctags_prune = 1
		let g:gen_tags#ctags_opts = '--sort=no --append'

	" All of your Plugins must be added before the following line
	call plug#end()            " required

	return 1
endfunction

function! plugin#Check() abort
	if empty(glob(g:plug_path))
		if executable('curl')
			execute '!curl -kfLo ' . g:plug_path . ' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
			augroup install_plugin
				autocmd!
				autocmd VimEnter * :PlugInstall
			augroup END
		else
			echomsg 'Master I cant install plugins for you because you'
						\' do not have curl. Please fix this. Plugins'
						\' will not be loaded.'
			return 0
		endif
	endif

	execute 'source ' . g:plug_path
	return 1
endfunction

" Called on augroup VimEnter search augroup.vim
function! plugin#AfterConfig() abort
	if exists('g:loaded_deoplete')
		call deoplete#custom#source('javacomplete2', 'mark', '')
		call deoplete#custom#source('_', 'matchers', ['matcher_full_fuzzy'])
		" c c++
		call deoplete#custom#source('clang2', 'mark', '')
	endif

	" Plugin function names are never detected. Only plugin commands
	if exists('g:loaded_denite')
		" Change mappings.
		call denite#custom#map('insert','<C-j>','<denite:move_to_next_line>','noremap')
		call denite#custom#map('insert','<C-k>','<denite:move_to_previous_line>','noremap')
		call denite#custom#map('insert','<C-v>','<denite:do_action:vsplit>','noremap')
		call denite#custom#map('insert','<C-d>','<denite:scroll_window_downwards>','noremap')
		call denite#custom#map('insert','<C-u>','<denite:scroll_window_upwards>','noremap')
		" Change options
		call denite#custom#option('default', 'winheight', 15)
		call denite#custom#option('_', 'highlight_matched_char', 'Function')
		call denite#custom#option('_', 'highlight_matched_range', 'Function')
		if executable('rg')
			call denite#custom#var('file_rec', 'command',
						\ ['rg', '--glob', '!.{git,svn}', '--files', '--no-ignore',
						\ '--smart-case', '--follow', '--hidden'])
			" Ripgrep command on grep source
			call denite#custom#var('grep', 'command', ['rg'])
			call denite#custom#var('grep', 'default_opts',
						\ ['--vimgrep', '--no-heading', '--smart-case', '--follow', '--hidden',
						\ '--glob', '!.{git,svn}'])
			call denite#custom#var('grep', 'recursive_opts', [])
			call denite#custom#var('grep', 'pattern_opt', ['--regexp'])
			call denite#custom#var('grep', 'separator', ['--'])
			call denite#custom#var('grep', 'final_opts', [])
		elseif executable('ag')
			call denite#custom#var('file_rec', 'command',
						\ ['ag', '--follow', '--nocolor', '--nogroup', '-g', '--hidden', ''])
			call denite#custom#var('grep', 'command', ['ag'])
			call denite#custom#var('grep', 'default_opts',
						\ ['--vimgrep', '--no-heading', '--smart-case', '--follow', '--hidden',
						\ '--glob', '!.{git,svn}'])
			call denite#custom#var('grep', 'recursive_opts', [])
			call denite#custom#var('grep', 'pattern_opt', [])
			call denite#custom#var('grep', 'separator', ['--'])
			call denite#custom#var('grep', 'final_opts', [])
		endif
		" Change ignore_globs
		call denite#custom#filter('matcher_ignore_globs', 'ignore_globs',
					\ [ '.git/', '.svn/', '.ropeproject/', '__pycache__/',
					\   'venv/', 'images/', '*.min.*', 'img/', 'fonts/', 'Obj/', '*.obj'])
	endif

	" On linux run neomake everytime you save a file
	if exists('g:loaded_neomake')
		call neomake#configure#automake('w')
		let g:neomake_msbuild_maker = {
					\ 'exe': 'msbuild',
					\ 'args': ['/nologo', '/v:q', '/p:GenerateFullPaths=true',
					\ '/t:Rebuild', '/p:SelectedFiles=%', '/p:Configuration=Release' ],
					\ 'errorformat': '%E%f(%l\,%c): error CS%n: %m [%.%#],'.
					\                '%W%f(%l\,%c): warning CS%n: %m [%.%#]',
					\ 'append_file' : 0,
					\ }
	endif
	return 1
endfunction

function! s:configure_ctrlp() abort
	Plug 'ctrlpvim/ctrlp.vim'
		nnoremap <S-k> :CtrlPBuffer<CR>
		let g:ctrlp_map = ''
		let g:ctrlp_cmd = 'CtrlPMRU'
		" submit ? in CtrlP for more mapping help.
		let g:ctrlp_lazy_update = 1
		let g:ctrlp_show_hidden = 1
		let g:ctrlp_match_window = 'bottom,order:btt,min:1,max:10,results:10'
		" It says cache dir but dont want to keep loosing history everytime cache gets cleaned up
		" Fri Jan 05 2018 14:38: Now that denite's file_rec is working much better no need
		" to keep this innacurrate list of files around. Rely on it less.
		let g:ctrlp_cache_dir = g:std_cache_path . '/ctrlp'
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
		" Lightline settings
		let g:ctrlp_status_func = {
					\ 'main': 'utils#CtrlPStatusFunc_1',
					\ 'prog': 'utils#CtrlPStatusFunc_2',
					\ }
endfunction

function! s:configure_async_plugins() abort
	if !has('nvim') && v:version < 800
		echoerr 'These plugins require async support'
		return -1
	endif

		Plug 'kassio/neoterm'
		let g:neoterm_use_relative_path = 1
		let g:neoterm_position = 'vertical'
		let g:neoterm_autoinsert=1
		nnoremap <Plug>ToggleTerminal :Ttoggle<CR>
		Plug 'Shougo/denite.nvim', { 'do' : has('nvim') ? ':UpdateRemotePlugins' : '' }
		" TODO-[RM]-(Wed Jan 10 2018 15:46): Come up with new mappings for these commented
		" out below
		" nnoremap <C-S-;> :Denite command_history<CR>
		" nnoremap <C-S-h> :Denite help<CR>
		nnoremap <C-p> :Denite file_mru<CR>
		" Wed Jan 10 2018 15:46: Have tried several times to use denite buffer but its
		" just too awkard. Kinda slow and doesnt show full path.
		" nnoremap <S-k> :Denite buffer<CR>

		" It includes file_mru source for denite.nvim.
		Plug 'Shougo/neomru.vim'
endfunction

function! s:configure_vim_table_mode() abort
	Plug 'dhruvasagar/vim-table-mode', { 'on' : 'TableModeToggle' }
	" To start using the plugin in the on-the-fly mode use :TableModeToggle
	" mapped to <Leader>tm by default Enter the first line, delimiting columns
	" by the | symbol. In the second line (without leaving Insert mode), enter
	" | twice For Markdown-compatible tables use
	let g:table_mode_corner='|'
	" let g:table_mode_corner = '+'
	let g:table_mode_align_char = ':'
	" TODO.RM-Wed Jul 19 2017 21:10: Fix here these mappings are for terminal
	let g:table_mode_map_prefix = '<LocalLeader>t'
	let g:table_mode_disable_mappings = 1
	nnoremap <Leader>ta :TableModeToggle<CR>
	" <Leader>tr	Realigns table columns
endfunction

function! s:configure_vim_utils() abort
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
	let g:DoxygenToolkit_paramTag_pre=	'	'
	let g:DoxygenToolkit_returnTag=			'Returns:   '
	let g:DoxygenToolkit_blockHeader=''
	let g:DoxygenToolkit_blockFooter=''
	let g:DoxygenToolkit_authorName='Reinaldo Molina <rmolin88 at gmail dot com>'
	let g:DoxygenToolkit_authorTag =	'Author:				'
	let g:DoxygenToolkit_fileTag =		'File:					'
	let g:DoxygenToolkit_briefTag_pre='Description:		'
	let g:DoxygenToolkit_dateTag =		'Last Modified: '
	let g:DoxygenToolkit_versionTag = 'Version:				'
	let g:DoxygenToolkit_commentType = 'C++'
	let g:DoxygenToolkit_versionString = '0.0.0'
	" See :h doxygen.vim this vim related. Not plugin related
	let g:load_doxygen_syntax=1
endfunction

function! s:configure_nerdcommenter() abort
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
				\ 'plantuml': { 'left': "'", 'right': '', 'leftAlt': "/'", 'rightAlt': "'/"},
				\ 'wings_syntax': { 'left': '//', 'right': '', 'leftAlt': '//', 'rightAlt': '' },
				\ 'sql': { 'left': '--', 'right': '', 'leftAlt': 'REM', 'rightAlt': '' }
				\ }

	let g:NERDTrimTrailingWhitespace = 1
endfunction

function! s:configure_tagbar() abort
	Plug 'majutsushi/tagbar'
	let g:tagbar_ctags_bin = 'ctags'
	let g:tagbar_autofocus = 1
	let g:tagbar_show_linenumbers = 2
	let g:tagbar_map_togglesort = 'r'
	let g:tagbar_map_nexttag = '<c-j>'
	let g:tagbar_map_prevtag = '<c-k>'
	let g:tagbar_map_openallfolds = '<c-n>'
	let g:tagbar_map_closeallfolds = '<c-c>'
	let g:tagbar_map_togglefold = '<c-x>'
	let g:tagbar_autoclose = 1
endfunction

function! s:configure_snippets() abort
	Plug 'Shougo/neosnippet'
	imap <C-k>     <Plug>(neosnippet_expand_or_jump)
	smap <C-k>     <Plug>(neosnippet_expand_or_jump)
	xmap <C-k>     <Plug>(neosnippet_expand_target)
	smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
				\ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
	" Tell Neosnippet about the other snippets
	let g:neosnippet#snippets_directory= [ g:vim_plugins_path . '/vim-snippets/snippets', g:location_vim_utils . '/snippets/', ]
	" Fri Oct 20 2017 21:47: Not really data but cache
	let g:neosnippet#data_directory = g:std_cache_path . '/neosnippets'
	" Used by nvim-completion-mgr
	let g:neosnippet#enable_completed_snippet=1

	" Only contain snippets
	Plug 'Shougo/neosnippet-snippets'
	Plug 'honza/vim-snippets'
	let g:snips_author = 'Reinaldo Molina'
	let g:snips_email = 'rmolin88 at gmail dot com'
	let g:snips_github = 'rmolin88'
endfunction

function! s:configure_vim_sneak() abort
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
endfunction

" linter - String specifing if it should set neomake or ale in the status line
function! s:configure_lightline(linter) abort
	Plug 'itchyny/lightline.vim'
	" Note: Inside of the functions here there can be no single quotes (') only double (")
	if !exists('g:lightline')
		let g:lightline = {}
	endif
	" Basic options
	" otf-inconsolata-powerline-git
	let g:lightline = {
				\ 'active' : {
				\   'left': [
				\							[ 'mode', 'paste' ],
				\							[ 'readonly', 'filename' ],
				\							[  ]
				\						],
				\ 'right': [ [ 'lineinfo' ],
				\            [ 'percent' ],
				\            [ 'fileformat', 'fileencoding', 'filetype' ] ] }
				\ }
	" \ 'component': {
	" \   'lineinfo': ' %3l:%-2v',
	" \ },
	" \ 'separator': { 'left': '', 'right': '' },
	" \ 'subseparator': { 'left': '', 'right': '' }
	" \ }

	" let g:lightline.tab = {
	" \ 'active': [ 'tabnum', 'absolutepath', 'modified' ],
	" \ }
	let g:lightline.tabline = {
				\ 'left': [ ['tabs'] ],
				\ 'right': [ [ 'bufnum' , 'close'] ] }
	let g:lightline.tab_component_function = {
				\ 'filename': 'utils#LightlineAbsPath'
				\ }
	" Addons
	let g:lightline.component = {}
	let g:lightline.component['lineinfo'] = ' %3l:%-2v'

	let g:lightline.separator = {}
	let g:lightline.subseparator = {}

	" Ovals. As opposed to the triangles. They do not look quite good
	" let g:lightline.separator['left'] = "\ue0b4"
	" let g:lightline.separator['right'] = "\ue0b6"
	" let g:lightline.subseparator['left'] = "\ue0b5"
	" let g:lightline.subseparator['right'] = "\ue0b7"

	let g:lightline.separator['left'] = ''
	let g:lightline.separator['right'] = ''
	let g:lightline.subseparator['left'] = ''
	let g:lightline.subseparator['right'] = ''

	let g:lightline.component_function = {}
	let g:lightline.component_function['filetype'] = 'utils#LightlineDeviconsFileType'
	let g:lightline.component_function['fileformat'] = 'utils#LightlineDeviconsFileFormat'
	let g:lightline.component_function['readonly'] = 'utils#LightlineReadonly'

	let g:lightline.active.left[2] += [ 'ver_control' ]
	let g:lightline.component_function['ver_control'] = 'utils#LightlineVerControl'

	let g:lightline.active.left[2] += [ 'ctrlpmark' ]
	let g:lightline.component_function['ctrlpmark'] = 'utils#LightlineCtrlPMark'

	" These settings do not use patched fonts
	" Fri Feb 02 2018 15:38: Its number one thing slowing down vim right now.
	" let g:lightline.active.left[2] += [ 'tagbar' ]
	" let g:lightline.component_function['tagbar'] = 'utils#LightlineTagbar'

	let g:lightline.active.left[2] += [ 'pomodoro' ]
	let g:lightline.component_function['pomodoro'] = 'utils#LightlinePomo'

	if a:linter ==# 'neomake'
		let g:lightline.active.left[2] += [ 'neomake' ]
		let g:lightline.component_function['neomake'] = 'utils#NeomakeNativeStatusLine'
	elseif a:linter ==# 'ale'
		let g:lightline.component_expand = {
					\  'linter_warnings': 'lightline#ale#warnings',
					\  'linter_errors': 'lightline#ale#errors',
					\  'linter_ok': 'lightline#ale#ok',
					\ }
		let g:lightline.component_type = {
					\     'linter_warnings': 'warning',
					\     'linter_errors': 'error',
					\     'linter_ok': 'left',
					\ }
		call insert(g:lightline.active.right[0], 'linter_errors')
		call insert(g:lightline.active.right[0], 'linter_warnings')
		call insert(g:lightline.active.right[0], 'linter_ok' )
	endif
endfunction

function! s:configure_vim_wordy() abort
	Plug 'reedes/vim-wordy', { 'for' : 'markdown' }
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
endfunction

function! s:configure_pomodoro() abort
	Plug 'rmolin88/pomodoro.vim'
	" let g:pomodoro_show_time_remaining = 0
	" let g:pomodoro_time_slack = 1
	" let g:pomodoro_time_work = 1
	let g:pomodoro_use_devicons = 1
	if executable('twmnc')
		let g:pomodoro_notification_cmd = 'twmnc -t Vim -i nvim -c "Pomodoro done"
					\ && mpg123 ~/.config/dotfiles/notification_sounds/cool_notification1.mp3 2>/dev/null&'
	elseif executable('dunst')
		let g:pomodoro_notification_cmd = "notify-send 'Pomodoro' 'Session ended'
					\ && mpg123 ~/.config/dotfiles/notification_sounds/cool_notification1.mp3 2>/dev/null&"
	endif
	let g:pomodoro_log_file = g:std_data_path . '/pomodoro_log'
	" %#ErrorMsg#%{PomodoroStatus()}%#StatusLine#
endfunction

" choice - One of netranger, nerdtree, or ranger
function! s:configure_file_browser(choice) abort
	" FileBrowser
	" Wed May 03 2017 11:31: Tried `vifm` doesnt work in windows. Doesnt
	" follow `*.lnk` shortcuts. Not close to being Replacement for `ranger`.
	" Main reason it looks appealing is that it has support for Windows. But its
	" not very good
	" Fri Feb 23 2018 05:16: Also tried netranger. Not that great either. Plus only
	" supports *nix.


	if a:choice ==# 'nerdtree'
		nnoremap <Plug>FileBrowser :NERDTree<CR>

		Plug 'scrooloose/nerdtree', { 'on' : 'NERDTree' }
		Plug 'Xuyuanp/nerdtree-git-plugin', { 'on' : 'NERDTree' }
		" Nerdtree (Dont move. They need to be here)
		let g:NERDTreeShowBookmarks=1  " B key to toggle
		let g:NERDTreeShowLineNumbers=1
		let g:NERDTreeShowHidden=1 " i key to toggle
		let g:NERDTreeQuitOnOpen=1 " AutoClose after openning file
		let g:NERDTreeBookmarksFile= g:std_data_path . '/.NERDTreeBookmarks'
	elseif a:choice ==# 'netranger'
		Plug 'ipod825/vim-netranger'
		nnoremap <Plug>FileBrowser :NERDTree<CR>
		let g:NETRRootDir = g:std_data_path . '/netranger/'
		let g:NETRIgnore = [ '.git', '.svn' ]
	elseif a:choice ==# 'ranger'
		Plug 'francoiscabrol/ranger.vim', { 'on' : 'RangerCurrentDirectory' }
			let g:ranger_map_keys = 0
	endif
endfunction
