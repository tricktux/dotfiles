" File:					_vimrc
" Description:  Vim/Neovim configuration file
" Author:				Reinaldo Molina
" Version:			3.4.2
" Date:					Tue Nov 08 2016 16:24 
" Improvements:
"		" - Figure out how to handle Doxygen
		" - [ ] Markdown tables
		" - [ ] make mail ft grab autocomplete from alias.sh
		" - [ ] Substitute all of the capital <leader>X mapps with newer non capital
		" - [ ] Customize and install vim-formatter
		" - [ ] Fix the markdown enter property
		" - [ ] Get familiar with vim format
		" - [ ] Delete duplicate music.
		" - [ ] Construct unified music library

" REQ AND LEADER
	set nocompatible
	syntax on
	filetype plugin indent on
	" moved here otherwise conditional mappings get / instead ; as leader
	let mapleader="\<Space>"
	let maplocalleader="\<Space>"

" WINDOWS_SETTINGS
	if has('win32')
		" Path variables
		let s:cache_path= $HOME . '\.cache\'
		let s:plugged_path=  $HOME . '\vimfiles\plugged\'
		let s:vimfile_path=  $HOME . '\vimfiles\'
		let s:wiki_path =  $HOME . '\Documents\1.WINGS\NeoWingsSupportFiles\wiki'
		let s:custom_font =  'consolas:h8'

		if !has('gui_running')
			set term=xterm
			let &t_AB="\e[48;5;%dm"
			let &t_AF="\e[38;5;%dm"
		endif

		nnoremap <Leader>mr :!%<CR>
		" Copy and paste into system wide clipboard
		nnoremap <Leader>jp "*p=`]<C-o>
		vnoremap <Leader>jp "*p=`]<C-o>

		nnoremap <Leader>jy "*yy
		vnoremap <Leader>jy "*y

		nnoremap  o<Esc>

		" Mappings to execute programs
		" Do not make a ew1 mapping. reserved for when issues get to #11, 12, etc
		nnoremap <Leader>ewd :Start! WINGS.exe 3 . default.ini<CR>
		nnoremap <Leader>ewc :Start! WINGS.exe 3 . %<CR>
		nnoremap <Leader>ews :execute("Start! WINGS.exe 3 . " . input("Config file:", "", "file"))<CR>

		" e1 reserved for vimrc
		" Switch Wings mappings for SWTestbed
		nnoremap <Leader>es :call utils#SetWingsPath('D:/Reinaldo/')<CR>

		" Default Wings mappings are for laptop
		function! s:SetWingsPath(sPath) abort
			execute "nnoremap <Leader>e21 :silent e " . a:sPath . "NeoOneWINGS/"
			execute "nnoremap <Leader>e22 :silent e " . a:sPath
			execute "nnoremap <Leader>ed :silent e ". a:sPath . "NeoOneWINGS/default.ini<CR>"
			execute "nnoremap <Leader>ewl :call utils#WingsSymLink('~/Documents/1.WINGS/')<CR>"
			execute "nnoremap <Leader>ewl :call utils#WingsSymLink(" . expand(a:sPath) . ")<CR>"
		endfunction

		call <SID>SetWingsPath('~/Documents/1.WINGS/')

		" Time runtime of a specific program
		nnoremap <Leader>mt :Dispatch powershell -command "& {&'Measure-Command' {.\sep_calc.exe seprc}}"<CR>

		nnoremap <Leader>mu :call utils#UpdateBorlandMakefile()<CR>

		" call utils#AutoCreateWinCtags()

		" Windows specific plugins options
			" Plugin 'ctrlpvim/ctrlp.vim' " quick file searchh"
				set wildignore+=*\\.git\\*,*\\.hg\\*,*\\.svn\\*  " Windows ('noshellslash')
				let g:ctrlp_custom_ignore = {
					\ 'dir':  '\v[\/]\.(git|hg|svn)$',
					\ 'file': '\v\.(tlog|log|db|obj|o|exe|so|dll|dfm)$',
					\ 'link': 'SOME_BAD_SYMBOLIC_LINKS',
					\ }

			" Vim-Clang " not being used currently but this below fixes
			" clang using mscv for target instead of mingw64
				let g:clang_cpp_options = '-target x86_64-pc-windows-gnu -std=c++17 -pedantic -Wall'
				let g:clang_c_options = '-target x86_64-pc-windows-gnu -std=gnu11 -pedantic -Wall'

			" MaxT Path
				if isdirectory('C:\maxapi')
					set path+=C:\maxapi
				endif

			" //////////////7/28/2016 4:09:23 PM////////////////
			" Tried using shell=bash on windows didnt work got all kinds of issues
			" with syntastic and other things.

" UNIX_SETTINGS
	elseif has('unix')
		" Path variables
		if has('nvim')
			let s:cache_path= $HOME . '/.cache/'
			let s:plugged_path=  $HOME . '/.config/nvim/plugged/'
			let s:vimfile_path=  $HOME . '/.config/nvim/'
		else
			let s:cache_path= $HOME . '/.cache/'
			let s:plugged_path=  $HOME . '/.vim/plugged/'
			let s:vimfile_path=  $HOME . '/.vim/'
		endif
		let s:wiki_path=  $HOME . '/Documents/seafile-client/Seafile/KnowledgeIsPower/wiki'

		let s:custom_font = 'Andale Mono 8'

		nnoremap <Leader>mr :silent !./%<CR>

		" System paste
		nnoremap <Leader>jp "+p=`]<C-o>
		vnoremap <Leader>jp "+p=`]<C-o>

		nnoremap <Leader>jy "+yy
		vnoremap <Leader>jy "+y

		" edit android
		nnoremap <Leader>ea :silent e
					\ ~/Documents/seafile-client/Seafile/KnowledgeIsPower/udacity/android-projects/
		" edit odroid
		nnoremap <Leader>eo :silent e ~/.mnt/truck-server/Documents/NewBot_v3/
		" edit bot
		nnoremap <Leader>eb :silent e ~/Documents/NewBot_v3/
		" Edit HQ
		nnoremap <Leader>eh :silent e ~/.mnt/HQ-server/
		" Edit Copter
		nnoremap <Leader>ec :silent e ~/.mnt/copter-server/
		" Edit Truck
		nnoremap <Leader>et :silent e ~/.mnt/truck-server/

		nnoremap <CR> o<ESC>

		augroup UnixMD
			autocmd!
			autocmd FileType markdown nnoremap <buffer> <Leader>mr :!google-chrome-stable %<CR>
			autocmd FileType fzf tnoremap <buffer> <C-j> <Down>
		augroup END

		" TODO|
		"    \/
		" call utils#AutoCreateUnixCtags()

		" !ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ -f ~/.cache/ctags/tags_sys /usr/include
		" !ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ -f ~/.cache/ctags/tags_sys2 /usr/local/include

		"Plugin 'ctrlpvim/ctrlp.vim' " quick file searchh"
			set wildignore+=*/.git/*,*/.hg/*,*/.svn/*        " Linux/MacOSX
			let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'

		" VIM_PATH includes
			" With this you can use gf to go to the #include <avr/io.h>
			" also this path below are what go into the .syntastic_avrgcc_config
			set path+=/usr/local/include
			set path+=/usr/include

			set tags+=~/.cache/ctags/tags_sys
			set tags+=~/.cache/ctags/tags_sys2
			set tags+=~/.cache/ctags/tags_android

		" Vim-clang
			let g:clang_library_path='/usr/lib/libclang.so'

		" Chromatica
			let g:chromatica#enable_at_startup = 1


		" Vim-Man
			runtime! ftplugin/man.vim
			" Sample use: Man 3 printf
			" Potential plug if you need more `vim-utils/vim-man` but this should be
			" enough

		" fzf
			nnoremap <C-p> :History<CR>
			nnoremap <A-p> :FZF<CR>
			nnoremap <S-k> :Buffers<CR>
			let g:fzf_history_dir = '~/.fzf-history'
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
	endif

" NVIM SPECIFIC
	if has('nvim')
		" terminal-emulator mappings
		tnoremap <C-j> <C-\><C-n>
		tnoremap <A-h> <C-\><C-n><C-w>h
    tnoremap <A-j> <C-\><C-n><C-w>j
    tnoremap <A-k> <C-\><C-n><C-w>k
    tnoremap <A-l> <C-\><C-n><C-w>l
		tnoremap <C-o> <Up>
		tnoremap <C-l> <Right>
		let $NVIM_TUI_ENABLE_TRUE_COLOR=1
		set clipboard+=unnamedplus
	endif

" PLUGINS_FOR_BOTH_SYSTEMS
	function! s:CheckVimPlug() abort
		let b:bLoadPlugins = 0
		if empty(glob(s:vimfile_path . 'autoload/plug.vim'))
			if executable('curl')
				" Create folder
				call utils#CheckDirwoPrompt(s:vimfile_path . "autoload")
				echomsg "Master I am going to install all plugings for you"
				execute "silent !curl -fLo " . s:vimfile_path . "autoload/plug.vim --create-dirs"
							\" https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
				autocmd VimEnter * PlugInstall | source $MYVIMRC
				let b:bLoadPlugins = 1
				return 1
			else
				echomsg "Master I cant install plugins for you because you"
							\" do not have curl. Please fix this. Plugins"
							\" will not be loaded."
				let b:bLoadPlugins = 0
				return 0
			endif
		else
			let b:bLoadPlugins = 1
			return 1
		endif
	endfunction
	" Attempt to install vim-plug and all plugins in case of first use
	if <SID>CheckVimPlug()
		" Call Vim-Plug Plugins should be from here below
		call plug#begin(s:plugged_path)
		if has('nvim')
			" Neovim exclusive plugins
			Plug 'equalsraf/neovim-gui-shim'
			Plug 'neomake/neomake'
			Plug 'Shougo/deoplete.nvim'
			Plug 'critiqjo/lldb.nvim'
		else
			" Vim exclusive plugins
			Plug 'Shougo/neocomplete'
			Plug 'tpope/vim-dispatch'
			Plug 'scrooloose/syntastic', { 'on' : 'SyntasticCheck' }
			Plug 'ctrlpvim/ctrlp.vim'
		endif
		" Plugins for All (nvim, linux, win32)
		Plug '~/.dotfiles/vim-utils'
		" misc
		Plug 'chrisbra/vim-diff-enhanced', { 'on' : 'SetDiff' }
		Plug 'scrooloose/nerdtree'
		Plug 'scrooloose/nerdcommenter'
		Plug 'chrisbra/Colorizer'
		Plug 'tpope/vim-repeat'
		Plug 'tpope/vim-surround'
		Plug 'Konfekt/FastFold'
		Plug 'airblade/vim-rooter'
		Plug 'Raimondi/delimitMate'
		Plug 'dkarter/bullets.vim'
		Plug 'Chiel92/vim-autoformat'
		if has('unix') " Potential alternative to ctrlp
			Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
			Plug 'junegunn/fzf.vim'
			Plug 'guanqun/vim-mutt-aliases-plugin'
			if !has('gui_running')
				Plug 'jamessan/vim-gnupg'
			endif
		endif
		" cpp
		Plug 'Tagbar', { 'on' : 'TagbarToggle' }
		Plug 'Rip-Rip/clang_complete', { 'for' : ['c' , 'cpp'] }
		Plug 'octol/vim-cpp-enhanced-highlight', { 'for' : [ 'c' , 'cpp' ] }
		Plug 'justinmk/vim-syntax-extra'
		Plug 'junegunn/rainbow_parentheses.vim', { 'on' : 'RainbowParentheses' }
		" cpp/java
		Plug 'mattn/vim-javafmt', { 'for' : 'java' }
		Plug 'tfnico/vim-gradle', { 'for' : 'java' }
		Plug 'artur-shaik/vim-javacomplete2', { 'branch' : 'master' }
		Plug 'nelstrom/vim-markdown-folding'
		" Autocomplete
		Plug 'Shougo/neosnippet'
		Plug 'Shougo/neosnippet-snippets'
		Plug 'honza/vim-snippets'
		" version control
		Plug 'tpope/vim-fugitive'
		" aesthetic
		Plug 'morhetz/gruvbox' " colorscheme gruvbox
		Plug 'NLKNguyen/papercolor-theme'
		" radical
		Plug 'glts/vim-magnum' " required by radical
		Plug 'glts/vim-radical' " use with gA

		" All of your Plugins must be added before the following line
		call plug#end()            " required
	endif

" GUI_SETTINGS
	if has('gui_running')
		let &guifont = s:custom_font " OS dependent font
		set guioptions-=T  " no toolbar
		set guioptions-=m  " no menu bar
		set guioptions-=r  " no right scroll bar
		set guioptions-=l  " no left scroll bar
		set guioptions-=L  " no side scroll bar
		nnoremap <S-CR> O<Esc>
		" if has('nvim')
			" command -nargs=? Guifont call rpcnotify(0, 'Gui', 'SetFont', "\<args\>") | let g:Guifont="<args>"
			" Guifont Courier New:h6
		" endif
	else " common cli options to both systems
		if $TERM ==? 'linux'
			set t_Co=8
		else
			set t_Co=256
		endif
		" fixes colorscheme not filling entire backgroud
		set t_ut=
		" Set blinking cursor shape everywhere
		if has('nvim')
			let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1
			" Fixes broken nmap <c-h> inside of tmux
			nnoremap <BS> :noh<CR>
		elseif exists('$TMUX')
			let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
			let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
		else
			let &t_SI = "\<Esc>[5 q"
			let &t_EI = "\<Esc>[1 q"
		endif
		Guifont DejaVu Sans Mono:h13
	endif

" PERFORMANCE_SETTINGS
	" see :h slow-terminal
	hi NonText cterm=NONE ctermfg=NONE
	set showcmd " use noshowcmd if things are really slow
	set scrolljump=5
	set sidescroll=15 " see help for sidescroll
	if !has('nvim') " this option was deleted in nvim
		set ttyscroll=3
	endif
	set lazyredraw " Had to addit to speed up scrolling
	set ttyfast " Had to addit to speed up scrolling
	set cursorline
	" let g:tex_fast= "" " on super slow activate this, price: no syntax
	" highlight
	" set fsync " already had problems with it. lost an entire file. dont use it
	if has('nvim')
		Guifont DejaVu Sans Mono:h13
	endif

" Create personal folders
	" TMP folder
	if utils#CheckDirwoPrompt(s:cache_path . "tmp")
		let $TMP= s:cache_path . "tmp"
	else
		echomsg string("Failed to create tmp dir")
	endif

	if !utils#CheckDirwoPrompt(s:cache_path . "sessions")
		echoerr string("Failed to create sessions dir")
	endif

	" We assume wiki folder is there. No creation of this wiki folder

	if !utils#CheckDirwoPrompt(s:cache_path . "java")
		echoerr string("Failed to create java dir")
	endif

	if has('persistent_undo')
		if utils#CheckDirwoPrompt(s:cache_path . 'undofiles')
			let &undodir= s:cache_path . 'undofiles'
			set undofile
			set undolevels=1000      " use many muchos levels of undo
		endif
	endif

" SET_OPTIONS
	"set spell spelllang=en_us
	"omnicomplete menu
	" save marks
	set shiftwidth=2 tabstop=2
	set viminfo='1000,f1,<800,%1024
	set showtabline=1 " always show tabs in gvim, but not vim"
	set backspace=indent,eol,start
						" allow backspacing over everything in insert mode
	" indents defaults. Custom values are changes in after/indent
		" When 'sts' is negative, the value of 'shiftwidth' is used.
	set softtabstop=-8
	set smarttab      " insert tabs on the start of a line according to
	" shiftwidth, not tabstop

	set showmatch     " set show matching parenthesis
	set smartcase     " ignore case if search pattern is all lowercase,
										"    case-sensitive otherwise
	set ignorecase
	set hlsearch      " highlight search terms
	set number
	set relativenumber
	set incsearch     " show search matches as you type
	set history=1000         " remember more commands and search history
	" ignore these files to for completion
	set wildignore+=*.o,*.obj,*.bak,*.exe,*.py[co],*.swp,*~,*.pyc,.svn,.git
	set completeopt=menuone,menu,longest,preview
	" set complete+=kspell " currently not working
	set wildmenu
	set wildmode=list:longest
	set title                " change the terminal's title
	set visualbell           " don't beep
	set noerrorbells         " don't beep
	set nobackup " no backup files
	set noswapfile
	"set autochdir " working directory is always the same as the file you are editing
	" Took out options from here. Makes the session script too long and annoying
	set sessionoptions=buffers,curdir,folds,localoptions,options,tabpages,resize,winsize,winpos,help
	set hidden
	" see :h timeout this was done to make use of ' faster and keep the other
	" timeout the same
	set notimeout
	set nottimeout
	" cant remember why I had a timeout len I think it was
	" in order to use <c-j> in cli vim for esc
	" removing it see what happens
	" set timeoutlen=1000
	" set ttimeoutlen=0
	set nowrap        " wrap lines
	set nowrapscan        " do not wrap search at EOF
	" will look in current directory for tags
	" THE BEST FEATURE I'VE ENCOUNTERED SO FAR OF VIM
	" CAN BELIEVE I DIDNT DO THIS BEFORE
	" set tags+=.\tags;\
	set tags=./tags;,tags;

	if has('cscope')
		set cscopetag cscopeverbose
		if has('quickfix')
			set cscopequickfix=s+,c+,d+,i+,t+,e+
		endif
	endif
	" set matchpairs+=<:>
	set autoread " autoload files written outside of vim
	" Display tabs and trailing spaces visually
	"set list listchars=tab:\ \ ,trail:?
	set linebreak    "Wrap lines at convenient points
	" Open and close folds Automatically
	" global fold indent
	set foldmethod=indent
	set foldnestmax=18      "deepest fold is 18 levels
	set foldlevel=0
	set foldlevelstart=0
	" use this below option to set other markers
	"'foldmarker' 'fmr'	string (default: "{{{,}}}")
	set viewoptions=folds,options,cursor,unix,slash " better unix /
	" For conceal markers.
	if has('conceal')
		set conceallevel=2 concealcursor=nv
	endif

	set noesckeys " No mappings that start with <esc>
	set noshowmode
	" no mouse enabled
	set mouse=""
	set laststatus=2
	set textwidth=78
	" makes vim autocomplete - bullets
	set comments+=b:-,b:*
	set nolist " Do not display extra characters
	set scroll=8
	set modeline
	set modelines=1
	" Set omni for all filetypes
	set omnifunc=syntaxcomplete#Complete
	call utils#SetGrep()

" ALL_AUTOGROUP_STUFF
	" All of these options contain performance drawbacks but the most important
	" is foldmethod=syntax
	augroup Filetypes
		autocmd!
		" C/Cpp
		autocmd FileType c,cpp setlocal omnifunc=ClangComplete
		autocmd FileType c,cpp setlocal ts=4 sw=4 sts=4
		" autocmd FileType c,cpp ChromaticaStart
		" autocmd FileType cpp set keywordprg=cppman
	 	" Rainbow cannot be enabled for help file. It breaks syntax highlight
		autocmd FileType c,cpp,java RainbowParentheses
		autocmd FileType c,cpp,java,vim setlocal foldenable
		" Java
		autocmd FileType java setlocal omnifunc=javacomplete#Complete
		autocmd FileType java compiler gradlew
		" Nerdtree Fix
		autocmd FileType nerdtree setlocal relativenumber
		" Set omnifunc for all others 									" not showing
		autocmd FileType cs compiler msbuild
		" Latex
		autocmd FileType tex setlocal spell spelllang=en_us
		autocmd FileType tex setlocal fdm=indent
		autocmd FileType tex compiler tex
		" Display help vertical window not split
		autocmd FileType help wincmd L
		" wrap syntastic messages
		autocmd FileType qf setlocal wrap
		autocmd FileType mail setlocal wrap
		autocmd FileType mail setlocal spell spelllang=es,en
		autocmd FileType mail setlocal omnifunc=muttaliases#CompleteMuttAliases
		" Markdown
		autocmd FileType markdown setlocal spell spelllang=en_us
		autocmd FileType markdown inoremap <buffer> * **<Left>
	augroup END

	augroup BuffTypes
	autocmd!
		" Arduino
		autocmd BufNewFile,BufReadPost *.ino,*.pde setf arduino
		" automatic syntax for *.scp
		autocmd BufNewFile,BufReadPost *.scp setf wings_syntax
		autocmd BufNewFile,BufReadPost *.set,*.sum setf dosini
		autocmd BufWritePost *.java Neomake
		"Automatically go back to where you were last editing this file
		autocmd BufReadPost *
			\ if line("'\"") > 0 && line("'\"") <= line("$") |
			\ exe "normal g`\"" |
			\ endif
		au BufEnter *.md setlocal foldexpr=MarkdownLevel()
		au BufEnter *.md setlocal foldmethod=expr
	augroup END

	augroup VimType
		autocmd!
		" Sessions
		" autocmd VimEnter * call utils#LoadSession('default.vim')
		autocmd VimLeave * call utils#SaveSession('default.vim')
		" Keep splits normalize
		autocmd VimResized * call utils#NormalizeWindowSize()
	augroup END

	" vim -b : edit binary using xxd-format!
	" using let &l:option_name is the same as setlocal
	augroup Binary
		au!
		au BufReadPre  *.bin,*.hsr,*.pdf let &l:bin=1
		au BufReadPost *.bin,*.hsr,*.pdf if &bin | %!xxd
		au BufReadPost *.bin,*.hsr,*.pdf setlocal ft=xxd | endif
		au BufWritePre *.bin,*.hsr,*.pdf if &bin | %!xxd -r
		au BufWritePre *.bin,*.hsr,*.pdf endif
		au BufWritePost *.bin,*.hsr,*.pdf if &bin | %!xxd
		au BufWritePost *.bin,*.hsr,*.pdf setlocal nomod | endif
	augroup END

" CUSTOM MAPPINGS
	" List of super useful mappings
	" ga " prints ascii of char under cursor
	" gA " prints radix of number under cursor
	" = fixes indentantion
	" gq formats code
	" Free keys: <Leader>fnzxlkiy;
	" Taken keys: <Leader>qwertasdjcvghp<space>mb

	" Quickfix and Location stuff
		" Description:
		" C-Arrow forces movement on quickfix window
		" Arrow moves on whichever window open (qf || ll)
		" if both opened favors location window

		" Quickfix only mappings
		nnoremap <C-Down> :cn<CR>
		nnoremap <C-Up> :cp<CR>
		nnoremap <C-Right> :cnf<CR>
		nnoremap <C-Left> :cpf<CR>
		" nnoremap <Leader>qO :Copen!<CR>
		nnoremap <Leader>qO :lopen 20<CR>
		nnoremap <Leader>qo :copen 20<CR>
		nnoremap <Leader>qc :.cc<CR>
		nnoremap <Leader>qC :cc<CR>

		nnoremap <Leader>qn :call utils#ListsNavigation("next")<CR>
		nnoremap <Leader>qp :call utils#ListsNavigation("previous")<CR>

		nnoremap <Down> :call utils#ListsNavigation("next")<CR>
		nnoremap <Up> :call utils#ListsNavigation("previous")<CR>
		nnoremap <Right> :call utils#ListsNavigation("nfile")<CR>
		nnoremap <Left> :call utils#ListsNavigation("pfile")<CR>

		nnoremap <Leader>ql :ccl<CR>
					\:lcl<CR>

	" Miscelaneous Mappings <Leader>j?
		" nnoremap <Leader>Ma :Man
		" Most used misc get jk, jj, jl, j;
		nnoremap <Leader>jk :call utils#Make()<CR>
		nnoremap <Leader>jl :e $MYVIMRC<CR>
		nnoremap <Leader>j; :NERDTree<CR>
		" Alternate between header and source file
		nnoremap <Leader>jq :e %:p:s,.h$,.X123X,:s,.cpp$,.h,:s,.X123X$,.cpp,<CR>
		" Refactor word under the cursor
		nnoremap <Leader>jr :%s/\<<c-r>=expand("<cword>")<cr>\>//gc<Left><Left><Left>
		vnoremap <Leader>jr "hy:%s/<C-r>h//gc<left><left><left>
		" Indent whole file
		nnoremap <Leader>ji mzgg=G`z
		" Help <Leader>h
		nnoremap <Leader>jh :h <c-r>=expand("<cword>")<CR><CR>
		nnoremap <Leader>jH :Helptags<CR>
		" duplicate current char
		nnoremap <Leader>jd ylp
		vnoremap <Leader>jd ylp
		" Save file with sudo permissions
		nnoremap <Leader>ju :w !sudo tee %<CR>
		" Markdown fix _ showing red
		nnoremap <Leader>jm :%s/_/\\_/gc<CR>
		" Reload syntax
		nnoremap <Leader>js <Esc>:syntax sync fromstart<CR>
		" Give execute permissions to current file
		nnoremap <Leader>jo :!chmod a+x %<CR>
		" Sessions
		nnoremap <Leader>je :call utils#SaveSession()<CR>
		nnoremap <Leader>jE :call utils#LoadSession()<CR>
		" Count occurrances of last search
		nnoremap <Leader>jc :%s///gn<CR>
		" Remove Trailing Spaces
		nnoremap <Leader>j<Space> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>
		" Indenting
		nnoremap <Leader>j2 :setlocal ts=2 sw=2 sts=2<CR>
		nnoremap <Leader>j4 :setlocal ts=4 sw=4 sts=4<CR>
		nnoremap <Leader>j8 :setlocal ts=8 sw=8 sts=8<CR>
		" not paste the deleted word
		nnoremap <Leader>ja "0p
		vnoremap <Leader>ja "0p
		" Force wings_syntax on a file
		nnoremap <Leader>jw :set filetype=wings_syntax<CR>
		nnoremap <Leader>jn :silent !./%<CR>
		" Create file with name under the cursor
		nnoremap <Leader>jf :call utils#FormatFile()<CR>
		" Diff Sutff
		command! SetDiff call utils#SetDiff()
		nnoremap <Leader>jz :SetDiff<CR>
		nnoremap <Leader>jZ :call utils#UnsetDiff()<CR>
		nnoremap <Leader>jt :call utils#ToggleTerm()<CR>
		nnoremap <Leader>j. :call utils#LastCommand()<CR>
		" Encapsulate in markdown file from current line until end of file in ```
		nnoremap <Leader>j` :normal i````cpp<Esc>Go```<Esc><CR>
		nnoremap <Leader>j- :call utils#GuiFont("-")<CR>
		nnoremap <Leader>j= :call utils#GuiFont("+")<CR>


		" TODO
		" j mappings taken <swypl;bqruihHdma248eEonf>
		" nnoremap <Leader>Mc :call utils#ManFind()<CR>
		nnoremap <C-s> :wa<CR>
		nnoremap <C-h> :noh<CR>
		nnoremap <C-Space> i<Space><Esc>
		" move current line up
		nnoremap <Leader>K ddkk""p
		" move current line down
		nnoremap <Leader>J dd""p
		" These are only for command line
		" insert in the middle of whole word search
		cnoremap <C-w> \<\><Left><Left>
		" insert visual selection search
		cnoremap <C-u> <c-r>=expand("<cword>")<cr>
		cnoremap <C-s> %s/
		" refactor
		"vnoremap <Leader>r :%s///gc<Left><Left><Left>
		cnoremap <C-p> <c-r>0
		cnoremap <C-j> <Down>
		cnoremap <C-o> <Up>
		cnoremap <C-k> <Down>
		cnoremap <C-j> <Left>
		cnoremap <C-l> <Right>
		" Switch back and forth between header file
		nnoremap <S-q> yyp
		" move to the beggning of line
		" Don't make this nnoremap. Breaks stuff
		noremap <S-w> $
		vnoremap <S-w> $
		" move to the end of line
		nnoremap <S-b> ^
		" jump to corresponding item<Leader> ending {,(, etc..
		nnoremap <S-t> %
		vnoremap <S-t> %
		" Automatically insert date
		nnoremap <F5> i<Space><ESC>"=strftime("%a %b %d %Y %H:%M")<CR>P
		" Designed this way to be used with snippet md header
		vnoremap <F5> s<Space><ESC>"=strftime("%a %b %d %Y %H:%M")<CR>Pa
		inoremap <F5> <Space><ESC>"=strftime("%a %b %d %Y %H:%M")<CR>Pa
		" Auto indent pasted text
		nnoremap p p=`]<C-o>
		nnoremap P P=`]<C-o>
		" Visual shifting (does not exit Visual mode)
		vnoremap < <gv
		vnoremap > >gv
		" Edit plugin
		nnoremap <Leader>ep :call utils#EditPlugins()<CR>
		nnoremap <Leader>ei :e 

		" see :h <c-r>
		" decrease number
		nnoremap <Leader>A <c-x>
		" delete key
		" math on insert mode

	" Insert Mode (Individual) mappings
		inoremap <C-A> <C-O>yiW<End>=<C-R>=<C-R>0<CR>
		inoremap <c-f> <del>
		inoremap <c-l> <Right>

	" Edit local <Leader>e?
		nnoremap <Leader>el :silent e ~/
		" cd into current dir path and into dir above current path
		nnoremap <Leader>e1 :e ~/.dotfiles/
		" Edit Vimruntime
		nnoremap <Leader>ev :e $VIMRUNTIME/

	" CD <Leader>c?
		nnoremap <Leader>cd :cd %:p:h<CR>
					\:pwd<CR>
		nnoremap <Leader>cu :cd ..<CR>
					\:pwd<CR>
		" cd into dir. press <Tab> after ci to see folders
		nnoremap <Leader>ci :cd
		nnoremap <Leader>cc :pwd<CR>
		nnoremap <Leader>ch :cd ~/<CR>
					\pwd<CR>

	" Folding
		" Folding select text then S-f to fold or just S-f to toggle folding
		nnoremap <C-j> zj
		nnoremap <C-k> zk
		nnoremap <C-z> zz
		nnoremap <C-c> zM
		nnoremap <C-n> zR
		nnoremap <C-x> za
		" dont use <C-a> it conflicts with tmux prefix

	" Window movement
		" move between windows
		nnoremap <a-h> <C-w>h
		nnoremap <a-j> <C-w>j
		nnoremap <a-k> <C-w>k
		nnoremap <a-l> <C-w>l

	" Spell Check <Leader>s?
		" search forward
		nnoremap <Leader>sn ]s
		" search backwards
		nnoremap <Leader>sp [s
		" suggestion
		nnoremap <Leader>sc z=
		" toggle spelling
		nnoremap <Leader>st :setlocal spell! spelllang=en_us<CR>
		nnoremap <Leader>sf :call utils#FixPreviousWord()<CR>
		" add to dictionary
		nnoremap <Leader>sa zg
		" mark wrong
		nnoremap <Leader>sw zw
		" repeat last spell correction
		nnoremap <Leader>sr :spellr<CR>

	" Search <Leader>S
		" Tried ack.vim. Discovered that nothing is better than grep with ag.
		" search all type of files
		nnoremap <Leader>S :grep --cpp
		nnoremap <S-s> #<C-o>
		vnoremap // y/<C-R>"<CR>

	" Substitute for ESC
		inoremap <C-j> <Esc>
		vnoremap <C-j> <Esc>

	" Buffers Stuff <Leader>b?
		nnoremap <S-j> :b#<CR>
		nnoremap <Leader>bd :bp\|bw #\|bd #<CR>
		" deletes all buffers
		nnoremap <Leader>bD :%bd<CR>
		nnoremap <Leader>bs :buffers<CR>:buffer<Space>
		nnoremap <Leader>bS :bufdo
		" move tab to the left
		nnoremap <silent> <A-Left> :execute 'silent! tabmove ' . (tabpagenr()-2)<CR>
		" move tab to the right
		nnoremap <silent> <A-Right> :execute 'silent! tabmove ' . (tabpagenr()+1)<CR>
		nnoremap <Leader>be :enew<CR>

	" Tabs <Leader>a?
		" open new to tab to explorer
		nnoremap <S-Tab> gT
		nnoremap <S-e> :tab split<CR>
		nnoremap <S-x> :tabclose<CR>

	" Version Control <Leader>v?
		" For all this commands you should be in the svn root folder
		" Add all files
		nnoremap <Leader>vA :!svn add * --force<CR>
		" Add specific files
		nnoremap <Leader>va :!svn add --force
		" Commit using typed message
		nnoremap <Leader>vc :call utils#SvnCommit()<CR>
		" Commit using File for commit content
		nnoremap <Leader>vC :!svn commit --force-log -F %<CR>
		nnoremap <Leader>vdl :!svn rm --force Log\*<CR>
		nnoremap <Leader>vda :!svn rm --force
		" revert previous commit
		" dangerous key TODO: warn before
		"nnoremap <Leader>vr :!svn revert -R .<CR>
		nnoremap <Leader>vl :!svn cleanup .<CR>
		" use this command line to delete unrevisioned or "?" svn files
		"nnoremap <Leader>vL :!for /f "tokens=2*" %i in ('svn status ^| find "?"') do del %i<CR>
		nnoremap <Leader>vs :!svn status .<CR>
		nnoremap <Leader>vu :!svn update .<CR>
		nnoremap <Leader>vo :!svn log .<CR>
		nnoremap <Leader>vi :!svn info<CR>

	" Fugitive <Leader>g?
			nnoremap <Leader>gs :Gstatus<CR>
			nnoremap <Leader>gp :Gpush<CR>
			nnoremap <Leader>gu :Gpull<CR>
			nnoremap <Leader>ga :!git add
			nnoremap <Leader>gl :silent Glog<CR>
							\:copen 20<CR>

	" Todo mappings <Leader>t?
		nnoremap <Leader>td :call utils#TodoCreate()<CR>
		nnoremap <Leader>tm :call utils#TodoMark()<CR>
		nnoremap <Leader>tM :call utils#TodoClearMark()<CR>
		nnoremap <Leader>ta :call utils#TodoAdd()<CR>
	" Wiki mappings <Leader>w?
		nnoremap <Leader>wt :call utils#WikiOpen('TODO.md')<CR>
		nnoremap <Leader>wo :call utils#WikiOpen()<CR>
		nnoremap <Leader>ws :call utils#WikiSearch()<CR>

	" Comments <Leader>c
		nnoremap <Leader>cD :call utils#CommentDelete()<CR>
		" Comment Indent Increase/Reduce
		nnoremap <Leader>cIi :call utils#CommentIndent()<CR>
		nnoremap <Leader>cIr :call utils#CommentReduceIndent()<CR>
		nnoremap cl :call utils#CommentLine()<CR>
		nnoremap <Leader>ce :call utils#EndOfIfComment()<CR>

	" Compiler
		nnoremap <Leader>Cb :compiler borland<CR>
		" msbuild errorformat looks horrible resetting here
		nnoremap <Leader>Cv :compiler msbuild<CR>
									\:set errorformat&<CR>
		nnoremap <Leader>Cg :compiler gcc<CR>
					\:setlocal makeprg=mingw32-make<CR>
		" Note: The placeholder "$*" can be given (even multiple times) to specify
		" where the arguments will be included,

" STATUS_LINE
	set statusline =
	set statusline+=\[%n]                                  "buffernr
	set statusline+=\ %<%F\ %m%r%w                         "File+path
	set statusline+=\ %y\                                  "FileType
	set statusline+=\ %{''.(&fenc!=''?&fenc:&enc).''}      "Encoding
	set statusline+=\ %{(&bomb?\",BOM\":\"\")}\            "Encoding2
	set statusline+=\ %{&ff}\                              "FileFormat (dos/unix..)
	set statusline+=\ %=\ row:%l/%L\ (%03p%%)\             "Rownumber/total (%)
	set statusline+=\ col:%03c\                            "Colnr
	set statusline+=\ \ %m%r%w\ %P\ \                      "Modified? Readonly? Top/bot.
	" if you want to put color to status line needs to be after command
	" colorscheme. Otherwise this commands clears it the color

" PLUGIN_OPTIONS/MAPPINGS
  " Only load plugin options in case they were loaded
  if b:bLoadPlugins == 1
    "Vim-Plug
      nnoremap <Leader>Pi :PlugInstall<CR>
      nnoremap <Leader>Pu :PlugUpdate<CR>
                \:PlugUpgrade<CR>
								\:UpdateRemotePlugins<CR>
      " installs plugins; append `!` to update or just :PluginUpdate
      nnoremap <Leader>Ps :PlugSearch<CR>
      " searches for foo; append `!` to refresh local cache
      nnoremap <Leader>Pl :PlugClean<CR>
      " confirms removal of unused plugins; append `!` to auto-approve removal

    "Plugin 'scrooloose/nerdcommenter'"
      let NERDUsePlaceHolders=0 " avoid commenter doing weird stuff
      let NERDCommentWholeLinesInVMode=2
      let NERDCreateDefaultMappings=0 " Eliminate default mappings
      let NERDRemoveAltComs=1 " Remove /* comments
      let NERD_c_alt_style=0 " Do not use /* on C nor C++
      let NERD_cpp_alt_style=0
      let NERDMenuMode=0 " no menu
      let g:NERDCustomDelimiters = {
        \ 'vim': { 'left': '"', 'right': '' },
				\ 'wings_syntax': { 'left': '//', 'right': '' }}
        "\ 'vim': { 'left': '"', 'right': '' }
        "\ 'grondle': { 'left': '{{', 'right': '}}' }
      "\ }
      let NERDSpaceDelims=1  " space around comments

      nmap - <plug>NERDCommenterToggle
      nmap <Leader>ct <plug>NERDCommenterAltDelims
      vmap - <plug>NERDCommenterToggle
      imap <C-c> <plug>NERDCommenterInsert
      nmap <Leader>ca <plug>NERDCommenterAppend
      vmap <Leader>cs <plug>NERDCommenterSexy

    "Plugin 'scrooloose/NERDTree'
			let NERDTreeShowBookmarks=1  " B key to toggle
			let NERDTreeShowLineNumbers=1
			let NERDTreeShowHidden=1 " i key to toggle
			let NERDTreeQuitOnOpen=1 " AutoClose after openning file
			let NERDTreeBookmarksFile=s:cache_path . '.NERDTreeBookmarks'
			" Do not load netrw
			let g:loaded_netrw       = 1
			let g:loaded_netrwPlugin = 1

    " Plugin 'Tagbar' {{{
      let g:tagbar_autofocus = 1
      let g:tagbar_show_linenumbers = 2
      let g:tagbar_map_togglesort = "r"
      let g:tagbar_map_nexttag = "<c-j>"
      let g:tagbar_map_prevtag = "<c-k>"
      let g:tagbar_map_openallfolds = "<c-n>"
      let g:tagbar_map_closeallfolds = "<c-c>"
      let g:tagbar_map_togglefold = "<c-x>"
      nnoremap <Leader>tt :TagbarToggle<CR>
      nnoremap <Leader>tk :cs kill -1<CR>
      nnoremap <silent> <Leader>tj <C-]>
      nnoremap <Leader>tr <C-t>
      nnoremap <Leader>tv :vs<CR>:exec("tag ".expand("<cword>"))<CR>
      " ReLoad cscope database
      nnoremap <Leader>tl :cs add cscope.out<CR>
      " Find functions calling this function
      nnoremap <Leader>tc :cs find c <C-R>=expand("<cword>")<CR><CR>
      " Find functions definition
      nnoremap <Leader>tg :cs find g <C-R>=expand("<cword>")<CR><CR>
      " Find functions called by this function not being used
      " nnoremap <Leader>td :cs find d <C-R>=expand("<cword>")<CR><CR>
      nnoremap <Leader>ts :cs show<CR>
			nnoremap <Leader>tu :call utils#UpdateCscope()<CR>

    " Plugin 'ctrlpvim/ctrlp.vim' " quick file searchh
			if executable('ag') && !executable('ucg') || !exists('FZF')
        let g:ctrlp_user_command = 'ag -Q -l --smart-case --nocolor --hidden -g "" %s'
      else
        echomsg string("You should install silversearcher-ag. Now you have a slow ctrlp")
      endif
			if has('win32')
				nnoremap <S-k> :CtrlPBuffer<CR>
				let g:ctrlp_cmd = 'CtrlPMixed'
				" submit ? in CtrlP for more mapping help.
				let g:ctrlp_lazy_update = 1
				let g:ctrlp_show_hidden = 1
				let g:ctrlp_match_window = 'bottom,order:btt,min:1,max:10,results:10'
				let g:ctrlp_cache_dir = s:cache_path . 'ctrlp'
				let g:ctrlp_working_path_mode = 'wra'
				let g:ctrlp_max_history = &history
				let g:ctrlp_clear_cache_on_exit = 0
			endif

    " Doxygen.vim
      nnoremap <Leader>cf :Dox<CR>
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
			let g:DoxygenToolkit_briefTag_pre="Description:		"
			let g:DoxygenToolkit_dateTag =		"Date:					"
			let g:DoxygenToolkit_versionTag = "Version:				"
			let g:DoxygenToolkit_commentType = "C++"
			" See :h doxygen.vim this vim related. Not plugin related
			let g:load_doxygen_syntax=1

    " Plugin 'scrooloose/syntastic'
			if exists(':SyntasticCheck')
				nnoremap <Leader>so :SyntasticToggleMode<CR>
				nnoremap <Leader>ss :SyntasticCheck<CR>
				let g:syntastic_always_populate_loc_list = 1
				let g:syntastic_auto_loc_list = 1
				let g:syntastic_check_on_open = 0
				let g:syntastic_check_on_wq = 0
				let g:syntastic_cpp_compiler_options = '-std=c++17 -pedantic -Wall'
				let g:syntastic_c_compiler_options = '-std=c11 -pedantic -Wall'
				let g:syntastic_auto_jump = 3
			endif

    "/Plug 'octol/vim-cpp-enhanced-highlight'
      let g:cpp_class_scope_highlight = 1

    " Plugin 'morhetz/gruvbox' " colorscheme gruvbox
			colorscheme gruvbox
			set background=dark    " Setting dark mode
			" set background=light
			" colorscheme PaperColor

    " Plug Neocomplete/Deoplete
      if !has('nvim')
        if has('lua')
          " All new stuff
					let g:neocomplete#enable_at_startup = 1
          let g:neocomplete#enable_cursor_hold_i=1
          let g:neocomplete#skip_auto_completion_time="1"
          let g:neocomplete#sources#buffer#cache_limit_size=5000000000
          let g:neocomplete#max_list=8
          let g:neocomplete#auto_completion_start_length=2
          " TODO: need to fix this i dont like the way he does it need my own for now is good I guess
          let g:neocomplete#enable_auto_close_preview=1

          let g:neocomplete#enable_smart_case = 1
          let g:neocomplete#data_directory = s:cache_path . 'neocomplete'
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
        else
          echoerr "No lua installed = No Neocomplete."
          " let g:neocomplete#enable_at_startup = 0 " default option
        endif
      elseif has('python3')
        " if it is nvim deoplete requires python3 to work
        let g:deoplete#enable_at_startup = 1
				" New settings
				let g:deoplete#enable_ignore_case = 1
				let g:deoplete#enable_smart_case = 1
				let g:deoplete#enable_camel_case = 1
				let g:deoplete#enable_refresh_always = 1
				let g:deoplete#max_abbr_width = 0
				let g:deoplete#max_menu_width = 0
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
				call deoplete#custom#set('javacomplete2', 'mark', '')
				call deoplete#custom#set('_', 'matchers', ['matcher_full_fuzzy'])
				"call deoplete#custom#set('omni', 'min_pattern_length', 0)
				inoremap <expr><C-h> deoplete#mappings#smart_close_popup()."\<C-h>"
				inoremap <expr><BS> deoplete#mappings#smart_close_popup()."\<C-h>"

				" " Regular settings
				inoremap <silent><expr> <TAB>
							\ pumvisible() ? "\<C-n>" :
							\ <SID>check_back_space() ? "\<TAB>" :
							\ deoplete#mappings#manual_complete()
				function! s:check_back_space() abort
					let col = col('.') - 1
					return !col || getline('.')[col - 1]  =~ '\s'
				endfunction
				inoremap <expr><C-h>
							\ deoplete#smart_close_popup()."\<C-h>"
				inoremap <expr><BS>
							\ deoplete#smart_close_popup()."\<C-h>"
      else
        echoerr "No python3 = No Deocomplete"
        " so if it doesnt have it activate clang instaed
        let g:deoplete#enable_at_startup = 0
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
      let g:neosnippet#data_directory = s:cache_path . 'neosnippets'

    " Vim-Clang
      " Why I switched to Rip-Rip because it works
      " Steps to get plugin to work:
      " 1. Make sure that you can compile a program with clang++ command
        " a. Example: clang++ -std=c++14 -stdlib=libc++ -pedantic -Wall hello.cpp -v
      " 2. To get this to work I had to install libc++-dev package in unix
      " 3. install libclang-dev package. See g:clang_library_path to where it gets
      " installed. Also I had to make sym link: ln -s libclang.so.1 libclang.so
      if !executable('clang')
        echomsg string("No clang present. Disabling vim-clang")
				let g:clang_complete_loaded = 1
      else
        let g:clang_user_options = '-std=c++14 -stdlib=libc++ -Wall -pedantic'
				let g:clang_close_preview = 1
        " let g:clang_complete_copen = 1
				" let g:clang_periodic_quickfix = 1
      endif

    " Vim-Markdown
      " messes up with neocomplete
      let g:vim_markdown_folding_disabled = 0
      let g:vim_markdown_folding_level = 6
      let g:vim_markdown_conceal = 0

    " Colorizer
      let g:colorizer_auto_filetype='css,html,xml'

    " JavaComplete2
			let g:JavaComplete_ClosingBrace = 1
			let g:JavaComplete_EnableDefaultMappings = 0
			let g:JavaComplete_ImportSortType = 'packageName'
			let g:JavaComplete_ImportOrder = ['android.', 'com.', 'junit.', 'net.', 'org.', 'java.', 'javax.']

    " GnuPG
      " This plugin doesnt work with gvim. Use only from cli
      let g:GPGUseAgent = 0

		" ft-java-syntax
			let java_highlight_java_lang_ids=1
			let java_highlight_functions="indent"
			let java_highlight_debug=1
			let java_space_errors=1
			let java_comment_strings=1
			hi javaParen ctermfg=blue guifg=#0000ff

		" Vim-Rooter
			let g:rooter_manual_only = 1
			nnoremap <Leader>cr :Rooter<CR>

		" ft-c-syntax
			let c_gnu = 1
			" Makes it akward when typing
			" If you really need to get rid of these just use <Leader>c<Space>
			" let c_space_errors = 1
			let c_ansi_constants = 1
			let c_ansi_typedefs = 1
			" Breaks too often
			let c_curly_error = 1

		" FastFold
			" Stop updating folds everytime I save a file
			let g:fastfold_savehook = 0
			" To update folds now you have to do it manually pressing 'zuz'
			let g:fastfold_fold_command_suffixes =
						\['x','X','a','A','o','O','c','C','r','R','m','M','i','n','N']

		" Neomake
			if exists(':Neomake')
				let g:neomake_warning_sign = {
				\ 'text': '?',
				\ 'texthl': 'WarningMsg',
				\ }

				let g:neomake_error_sign = {
					\ 'text': 'X',
					\ 'texthl': 'ErrorMsg',
					\ }
			endif

		" delimitMate
			let g:delimitMate_expand_cr = 1
			let g:delimitMate_expand_space = 1
			let g:delimitMate_jump_expansion = 1
			" imap <expr> <CR> <Plug>delimitMateCR

		" ft-markdown-syntax
			let g:markdown_fenced_languages= [ 'cpp', 'vim' ]

		" markdown-folding
			" let g:markdown_fold_style = 'nested'
			let g:markdown_fold_override_foldtext = 0

		" MuttAliases
			let g:mutt_alias_filename = '~/.mutt/muttrc'
			" let g:deoplete#omni#input_patterns.mail =
			" TODO.RM-Fri Oct 07 2016 00:56: Need to come up with regex pattern to
			" match Cc:, Bcc:
			" Fork repo and fix readme to mention i_CTRL-X_CTRL-O and fix the function

		" Man
			let g:no_plugin_maps = 1

		" Bullets
			let g:bullets_set_mappings = 0

		" Autoformat
			let g:autoformat_autoindent = 0
			let g:autoformat_retab = 0
			let g:autoformat_remove_trailing_spaces = 0

		" lldb.vim
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

" see :h modeline
" vim:tw=78:ts=2:sts=2:sw=2:
