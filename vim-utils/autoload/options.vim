

function options#Set() abort
	" SET_OPTIONS
	" Regular stuff
	"set spell spelllang=en_us
	"omnicomplete menu
	" save marks

	let &path .='.,,..,../..,./*,./*/*,../*,~/,~/**,/usr/include/*' " Useful for the find command
	set shiftwidth=4 tabstop=4
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
	set showcmd				" Show partial commands in the last lines
	set smartcase     " ignore case if search pattern is all lowercase,
	"    case-sensitive otherwise
	set ignorecase
	set infercase
	set hlsearch      " highlight search terms
	set number
	set relativenumber
	set incsearch     " show search matches as you type
	set history=1000         " remember more commands and search history
	" ignore these files to for completion
	set completeopt=menuone,longest,preview,noselect,noinsert
	" set complete+=kspell " currently not working
	" set wildmenu " Sun Jul 16 2017 20:24. Dont like this way. Its weird 
	set wildmode=list:longest
	set wildignore+=*.o,*.obj,*.bak,*.exe,*.py[co],*.swp,*~,*.pyc,.svn,.git
	set title                " change the terminal's title
	set visualbell           " don't beep
	set noerrorbells         " don't beep
	set nobackup " no backup files
	set noswapfile
	"set autochdir " working directory is always the same as the file you are editing
	" Took out options from here. Makes the session script too long and annoying
	set sessionoptions=buffers,curdir,folds,tabpages
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
	" set foldmethod=indent
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

	if !has('nvim')
		set noesckeys " No mappings that start with <esc>
	else
		set inccommand = "nosplit"
	endif

	" no mouse enabled
	set mouse=""
	set laststatus=2
	set textwidth=98
	" makes vim autocomplete - bullets
	set comments+=b:-,b:*
	set nolist " Do not display extra characters
	set scroll=8
	set modeline
	set modelines=1
	" Set omni for all filetypes
	set omnifunc=syntaxcomplete#Complete
	" Mon Jun 05 2017 11:59: Suppose to Fix cd to relative paths in windows
	let &cdpath = ',' . substitute(substitute($CDPATH, '[, ]', '\\\0', 'g'), ':', ',', 'g')

	" Status Line and Colorscheme
	if exists('g:plugins_loaded')
		" set background=dark    " Setting dark mode
		" colorscheme gruvbox
		" colorscheme onedark
		" set background=light
		let g:colorscheme_night_time = 20
		let g:colorscheme_day_time = 7
		let g:colorscheme_day = 'PaperColor'
		let g:colorscheme_night = 'gruvbox'
		execute "colorscheme " . g:colorscheme_day
		set background=light
		augroup FluxLike
			autocmd!
			autocmd VimEnter,BufEnter * call utils#Flux()
		augroup END
	else
		colorscheme desert
	endif

	" If this not and android device and we have no plugins setup "ugly"
	" status line
	if !exists("g:android") && !exists('g:plugins_loaded')
		set statusline =
		set statusline+=\ [%n]                                  "buffernr
		set statusline+=\ %<%F\ %m%r%w                         "File+path
		set statusline+=\ %y\                                  "FileType
		set statusline+=\ %{''.(&fenc!=''?&fenc:&enc).''}      "Encoding
		set statusline+=\ %{(&bomb?\",BOM\":\"\")}\            "Encoding2
		set statusline+=\ %{&ff}\                              "FileFormat (dos/unix..)
		" set statusline+=\ %{tagbar#currenttag('%s\ ','')}		 " Current function name
		" set statusline+=\ %{neomake#statusline#QflistStatus('qf:\ ')}
		" set statusline+=\ %{fugitive#statusline()}
		set statusline+=\ %=\ row:%l/%L\ (%03p%%)\             "Rownumber/total (%)
		set statusline+=\ col:%03c\                            "Colnr
		set statusline+=\ \ %m%r%w\ %P\ \                      "Modified? Readonly? Top/bot.
		" If you want to put color to status line needs to be after command
		" colorscheme. Otherwise this commands clears it the color
	endif

	" Performance Settings
	" see :h slow-terminal
	hi NonText cterm=NONE ctermfg=NONE
	set scrolljump=5
	set sidescroll=15 " see help for sidescroll
	if !has('nvim') " this options were deleted in nvim
		set ttyscroll=3
		set ttyfast " Had to addit to speed up scrolling
	endif
	set lazyredraw " Had to addit to speed up scrolling
	" Mon May 01 2017 11:21: This breaks split window highliting
	" Tue Jun 13 2017 20:55: Giving it another try 
	set synmaxcol=200 " Will not highlight passed this column #

	" CLI
	if !has('gui_running') && !exists('g:GuiLoaded')
		if $TERM ==? 'linux'
			set t_Co=8
		else
			set t_Co=256
		endif
		" fixes colorscheme not filling entire backgroud
		set t_ut=
		" Set blinking cursor shape everywhere
		if has('nvim')
			" let $NVIM_TUI_ENABLE_TRUE_COLOR=1
			set termguicolors
			" let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1
			" This was Sub by set guicursor. But its default value its okay
			" Fixes broken nmap <c-h> inside of tmux
			nnoremap <BS> :noh<CR>
		endif

		if exists('$TMUX')
			let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
			let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
		elseif has('win32')
			if !has('nvim')
				set term=xterm
			endif
			set t_Co=256
			let &t_AB="\e[48;5;%dm"
			let &t_AF="\e[38;5;%dm"
		else
			let &t_SI = "\<Esc>[5 q"
			let &t_EI = "\<Esc>[1 q"
		endif
	endif

	" TODO-[RM]-(Tue Aug 22 2017 10:43): Move this function calls to init#vim or
	" options.vim
	" Grep
	if exists("g:plugins_loaded")
		call utils#SetGrep()
	endif

	" Undofiles
	if exists("g:plugins_loaded") && exists("g:undofiles_path") && !empty(glob(g:undofiles_path))
		let &undodir= g:undofiles_path
		set undofile
		set undolevels=1000      " use many muchos levels of undo
	endif

	" Tags
	set tags=./.tags;,.tags;
	if exists("g:plugins_loaded")
		" Load all tags and OneWings cscope database
		call ctags#SetTags()
	endif
endfunction

" vim:tw=78:ts=2:sts=2:sw=2:
