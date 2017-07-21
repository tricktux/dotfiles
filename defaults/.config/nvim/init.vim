" File:					init.vim
" Description:  Vim/Neovim configuration file
" Author:				Reinaldo Molina
" Version:			9.0.0
"								- Fully modularize config files
"								- Dein plugin
"								- Python functions files
" Date:					Sat Jun 03 2017 10:43
" Created:			Aug 2015
" Improvements:
		" - [ ] Create a after/syntax/gitcommit.vim to redline ahead and greenline
		"   up-to-date
		" - [ ] Delete duplicate music.
		" - [ ] Construct unified music library
		" - [ ] Markdown math formulas

" Req
	" moved here otherwise conditional mappings get / instead ; as leader
	let mapleader="\<Space>"
	let maplocalleader="\<Space>"
	let g:esc = '<C-j>'
	set nocompatible
	syntax on
	filetype plugin indent on

" PLUGINS_INIT
	" ~/.dotfiles/vim-utils/autoload/plugin.vim
	" Attempt to install vim-plug and all plugins in case of first use
	let g:location_local_vim = "~/.dotfiles/vim-utils/autoload/plugin.vim"
	let g:location_portable_vim = "../../.dotfiles/vim-utils/autoload/plugin.vim"
	if !empty(glob(g:location_local_vim))
		execute "source " . g:location_local_vim
		let g:plugins_present = 1
		let g:location_vim_utils = "~/.dotfiles/vim-utils"
	elseif !empty(glob(g:location_portable_vim))
		execute "source " . g:location_portable_vim
		execute "source ../../vimfiles/autoload/plug.vim"
		let g:plugins_present = 1
		let g:portable_vim = 1
		let g:location_vim_utils = getcwd() . '/../../.dotfiles/vim-utils'
	else
		echomsg "No plugins where loaded"
	endif

	" Choose a autcompl engine
	let g:tagbar_safe_to_use = 1
	" Possible values:
	" - ycm
	" - nvim_compl_manager
	" - shuogo
	" - autocomplpop
	if has('unix')
		let g:autcompl_engine = 'nvim_compl_manager'
	endif
	if !has('nvim') && has('win32')
		let g:autcompl_engine = 'autocomplpop'
	endif

	if exists('g:plugins_present') && plugin#Check() && plugin#Config()
			let g:plugins_loaded = 1
	else
		echomsg "No plugins where loaded"
	endif

" NVIM SPECIFIC
	" ~/.dotfiles/vim-utils/autoload/nvim.vim
	if has('nvim') && exists("g:plugins_loaded")
		call nvim#Config()
	endif

" WINDOWS_SETTINGS
	" ~/.dotfiles/vim-utils/autoload/win32.vim
	if has('win32') && exists("g:plugins_loaded")
		call win32#Config()

" UNIX_SETTINGS
	" ~/.dotfiles/vim-utils/autoload/unix.vim
	elseif has('unix') && exists("g:plugins_loaded")
		call unix#Config()
	endif

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
		set textwidth=118
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
			set statusline+=\ %{tagbar#currenttag('%s\ ','')}		 " Current function name
			set statusline+=\ %{neomake#statusline#QflistStatus('qf:\ ')}
			set statusline+=\ %{fugitive#statusline()}
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

	" Grep
		if exists("g:plugins_loaded")
			call utils#SetGrep()
		endif

	" Undofiles
		if !empty(glob(g:cache_path . 'undofiles'))
			let &undodir= g:cache_path . 'undofiles'
			set undofile
			set undolevels=1000      " use many muchos levels of undo
		endif

	" Tags
		set tags=./.tags;,.tags;
		if exists("g:plugins_loaded")
			" Load all tags and OneWings cscope database
			call ctags#SetTags()
		endif

" ALL_AUTOGROUP_STUFF
	" All of these options contain performance drawbacks but the most important
	" is foldmethod=syntax
	augroup Filetypes
		autocmd!
		" Nerdtree Fix
		autocmd FileType nerdtree setlocal relativenumber
		" Set omnifunc for all others 									" not showing
		autocmd FileType cs compiler msbuild
		" Latex
		autocmd FileType tex setlocal spell spelllang=en_us
		autocmd FileType tex compiler tex
		" Display help vertical window not split
		autocmd FileType help wincmd L
		autocmd FileType help :nnoremap <buffer> q ZZ
		" wrap syntastic messages
		autocmd FileType mail setlocal wrap
		autocmd FileType mail setlocal spell spelllang=es,en
		autocmd FileType mail setlocal omnifunc=muttaliases#CompleteMuttAliases
		" Python
		" autocmd FileType python setlocal foldmethod=syntax
		autocmd FileType help setlocal relativenumber
	augroup END

	" To improve syntax highlight speed. If something breaks with highlight
	" increase these number below
	" augroup vimrc
		" autocmd!
		" autocmd BufWinEnter,Syntax * syn sync minlines=80 maxlines=80
	" augroup END


	if exists("g:plugins_loaded")
		augroup VimType
			autocmd!
			" Sessions
			" Note: Fri Mar 03 2017 14:13 - This never works.
			" autocmd VimEnter * call utils#LoadSession('default.vim')
			autocmd VimLeave * call utils#SaveSession('default.vim')
			" Keep splits normalize
			autocmd VimResized * call utils#NormalizeWindowSize()
		augroup END

		augroup BuffTypes
			autocmd!
			autocmd BufNewFile,BufReadPost * call utils#BufDetermine()
		augroup END
	endif

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

	" Depends on autoread being set
	augroup AutoRead
		autocmd!
		autocmd CursorHold * silent! checktime
	augroup END

	if has('nvim')
		augroup Terminal
			autocmd!
			autocmd TermOpen * setlocal nonumber
		augroup END
	endif

" CUSTOM MAPPINGS
	" List of super useful mappings
	" = fixes indentantion
	" gq formats code
	" Free keys: <Leader>fnzxkiy;h
	" Taken keys: <Leader>qwertasdjcvgp<space>mbolu

	" Quickfix and Location stuff
		nnoremap <Leader>qO :lopen 20<CR>
		nnoremap <Leader>qo :call quickfix#OpenQfWindow()<CR>
		" nnoremap <silent> <Leader>ll :call quickfix#ToggleList("Location List", 'l')<CR>
		nnoremap <silent> U :call quickfix#ToggleList("Quickfix List", 'c')<CR>
		nnoremap <Leader>ln :call quickfix#ListsNavigation("next")<CR>
		nnoremap <Leader>lp :call quickfix#ListsNavigation("previous")<CR>
		nnoremap <Leader>qn :call quickfix#ListsNavigation("next")<CR>
		nnoremap <Leader>qp :call quickfix#ListsNavigation("previous")<CR>
		nnoremap <Leader>ql :ccl<CR>
					\:lcl<CR>

	" FileType Specific mappings use <Leader>l
		" Refer to ~/.dotfiles/vim-utils/after/ftplugin to find these

	" j and k
	" Display line movements unless preceded by a count and
	" Save movements larger than 5 lines to the jumplist. Use Ctrl-o/Ctrl-i.
		nnoremap <expr> j v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj'
		nnoremap <expr> k v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk'

	" Miscelaneous Mappings <Leader>j?
		" nnoremap <Leader>Ma :Man
		" Most used misc get jk, jj, jl, j;
		" TODO.RM-Fri Apr 28 2017 14:25: Go through mappings and figure out the
		" language specific ones so that you can move them into ftplugin
		" nnoremap <Leader>jk :call utils#Make()<CR>
		" ga " prints ascii of char under cursor
		" gA " prints radix of number under cursor
		" Untouchable g mappings: g;, gt, gr, gf, gd, g, gg, gs
		nnoremap gl :e $MYVIMRC<CR>
		nmap gj <Plug>FileBrowser
		nmap gk <Plug>Make

		" Refactor word under the cursor
		nnoremap <Leader>r :%s/\<<c-r>=expand("<cword>")<cr>\>//gc<Left><Left><Left>
		vnoremap <Leader>r "hy:%s/<C-r>h//gc<left><left><left>
		" duplicate current char
		nnoremap <Leader>d ylp
		vnoremap <Leader>d ylp
		" Reload syntax
		nnoremap <Leader>js <Esc>:syntax sync fromstart<CR>
		" Sessions
		nnoremap <Leader>jes :call utils#SaveSession()<CR>
		nnoremap <Leader>jel :call utils#LoadSession()<CR>
		nnoremap <Leader>jee :call utils#LoadSession('default.vim')<CR>
		" Count occurrances of last search
		nnoremap <Leader>jc :%s///gn<CR>
		" Indenting
		nnoremap <Leader>j2 :setlocal ts=2 sw=2 sts=2<CR>
		nnoremap <Leader>j4 :setlocal ts=4 sw=4 sts=4<CR>
		nnoremap <Leader>j8 :setlocal ts=8 sw=8 sts=8<CR>
		" not paste the deleted word
		nnoremap <Leader>p "0p
		vnoremap <Leader>p "0p
		" Force wings_syntax on a file
		nnoremap <Leader>jw :set filetype=wings_syntax<CR>
		" Create file with name under the cursor
		" Diff Sutff
		nnoremap <Leader>j. :call utils#LastCommand()<CR>
		nnoremap <Leader>- :call utils#GuiFont("-")<CR>
		nnoremap <Leader>= :call utils#GuiFont("+")<CR>

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
		cnoremap <C-k> <Up>
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
		nmap <S-t> %
		vmap <S-t> %
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

		" decrease number
		nnoremap <Leader>a <c-x>
		vnoremap <Leader>a <c-x>

		nnoremap yl :call utils#YankFrom()<CR>
		nnoremap dl :call utils#DeleteLine()<CR>

		nnoremap <S-CR> O<Esc>
		" Display highlighted numbers as ascii chars. Only works on highlighted text
		vnoremap <Leader>ah :<c-u>s/<count>\x\x/\=nr2char(printf("%d", "0x".submatch(0)))/g<cr><c-l>`<
		vnoremap <Leader>ha :<c-u>s/\%V./\=printf("%x",char2nr(submatch(0)))/g<cr><c-l>`<

		" Search forward/backwards but return
		nnoremap * *N
		nnoremap # #N

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
		nnoremap <Leader>cd :lcd %:h<CR>
					\:pwd<CR>
		nnoremap <Leader>cu :lcd ..<CR>
					\:pwd<CR>
		" cd into dir. press <Tab> after ci to see folders
		nnoremap <Leader>ci :lcd
		nnoremap <Leader>cc :pwd<CR>
		nnoremap <Leader>c1 :lcd ~/.dotfiles
		" TODO.RM-Thu Jun 01 2017 10:10: Create mappings like c21 and c22

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
		if has('unix')
			nnoremap <silent> <A-h> :call utils#TmuxMove('h')<cr>
			nnoremap <silent> <A-j> :call utils#TmuxMove('j')<cr>
			nnoremap <silent> <A-k> :call utils#TmuxMove('k')<cr>
			nnoremap <silent> <A-l> :call utils#TmuxMove('l')<cr>
		else
			nnoremap <silent> <A-h> <C-w>h
			nnoremap <silent> <A-j> <C-w>j
			nnoremap <silent> <A-k> <C-w>k
			nnoremap <silent> <A-l> <C-w>l
		endif

	" Spell Check <Leader>s?
		" search forward
		nnoremap <Leader>sj ]s
		" search backwards
		nnoremap <Leader>sk [s
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
		" Search '&filetype' type of files, and word under the cursor
		nmap gsu :call utils#FileTypeSearch(1, 1)<CR>
		" Search '&filetype' type of files, and prompt for search word
		nmap gsi :call utils#FileTypeSearch(1, 8)<CR>
		" Search all type of files, and word under the cursor
		nmap gsa :call utils#FileTypeSearch(8, 1)<CR>
		" Search all type of files, and prompt for search word
		nmap gss :call utils#FileTypeSearch(8, 8)<CR>
		" Search visual selection text
		vnoremap // y/<C-R>"<CR>

	" Substitute for ESC
		execute "vnoremap " . g:esc . " <Esc>"
		execute "inoremap " . g:esc . " <Esc>"

	" Buffers Stuff <Leader>b?
		if !exists("g:plugins_loaded")
			nnoremap <S-k> :buffers<CR>:buffer<Space>
		else
			nnoremap <Leader>bs :buffers<CR>:buffer<Space>
		endif
		nnoremap <Leader>bd :bp\|bw #\|bd #<CR>
		nnoremap <S-j> :b#<CR>
		" deletes all buffers
		nnoremap <Leader>bl :%bd<CR>
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
		nnoremap <Leader>vA :!svn add . --force<CR>
		" Add specific files
		nnoremap <Leader>va :!svn add --force
		" Commit using typed message
		nnoremap <Leader>vc :call utils#SvnCommit()<CR>
		" Commit using File for commit content
		nnoremap <Leader>vC :!svn commit --force-log -F %<CR>
		nnoremap <Leader>vd :!svn rm --force
		" revert previous commit
		"nnoremap <Leader>vr :!svn revert -R .<CR>
		nnoremap <Leader>vl :!svn cleanup .<CR>
		" use this command line to delete unrevisioned or "?" svn files
		"nnoremap <Leader>vL :!for /f "tokens=2*" %i in ('svn status ^| find "?"') do del %i<CR>
		" nnoremap <Leader>vs :!svn status .<CR>
		nnoremap <Leader>vu :!svn update .<CR>
		" Overwritten from plugin.vim
		" nnoremap <Leader>vo :!svn log .<CR>
		" nnoremap <Leader>vi :!svn info<CR>

	" Terminal mappings <Leader>t?
	if has('nvim')
		nnoremap <Leader>tc :term cmus<bar>keepalt file cmus<cr>
	endif
		
	" Tags mappings <Leader>t?
		nnoremap <silent> gt <C-]>
		nnoremap gr <C-t>

	" Wiki mappings <Leader>w?
		" TODO.RM-Thu Dec 15 2016 16:00: Add support for wiki under SW-Testbed
		nnoremap <Leader>wt :call utils#WikiOpen('TODO.md')<CR>
		nnoremap <Leader>wo :call utils#WikiOpen()<CR>
		nnoremap <Leader>ws :call utils#WikiSearch()<CR>
		" This mapping is special is to search the cpp-reference offline help with w3m
		nnoremap <Leader>wc :W3m local /home/reinaldo/Downloads/reference/en/index.html<CR>
		nnoremap <Leader>wu :W3m local /home/reinaldo/Downloads/reference/en/index.html<CR>

	" Comments <Leader>o
		nmap - <plug>NERDCommenterToggle
		nmap <Leader>ot <plug>NERDCommenterAltDelims
		vmap - <plug>NERDCommenterToggle
		imap <C-c> <plug>NERDCommenterInsert
		nmap <Leader>oa <plug>NERDCommenterAppend
		vmap <Leader>os <plug>NERDCommenterSexy
		" mapping ol conflicts with mapping o to new line
		nnoremap cl :call utils#CommentLine()<CR>
		nnoremap <Leader>oe :call utils#EndOfIfComment()<CR>
		nnoremap <Leader>ou :call utils#UpdateHeader()<CR>
		nnoremap <Leader>os :grep --cpp TODO.RM<CR>

" SYNTAX_OPTIONS
	" ft-java-syntax
		let java_highlight_java_lang_ids=1
		let java_highlight_functions="indent"
		let java_highlight_debug=1
		let java_space_errors=1
		let java_comment_strings=1
		hi javaParen ctermfg=blue guifg=#0000ff

	" ft-c-syntax
		let c_gnu = 1
		let c_ansi_constants = 1
		let c_ansi_typedefs = 1
		let c_minlines = 500
		" Breaks too often
		" let c_curly_error = 1

	" ft-markdown-syntax
		let g:markdown_fenced_languages= [ 'cpp', 'vim', 'dosini', 'wings_syntax' ]

	" ft-python-syntax
		" This option also highlights erroneous whitespaces
		let python_highlight_all = 1

	" Man
		" let g:no_man_maps = 1
		let g:ft_man_folding_enable = 1

	" Never load netrw
		let g:loaded_netrw       = 1
		let g:loaded_netrwPlugin = 1

	" Nerdtree (Dont move. They need to be here)
		let NERDTreeShowBookmarks=1  " B key to toggle
		let NERDTreeShowLineNumbers=1
		let NERDTreeShowHidden=1 " i key to toggle
		let NERDTreeQuitOnOpen=1 " AutoClose after openning file
		let NERDTreeBookmarksFile=g:cache_path . '.NERDTreeBookmarks'
	" NerdCommenter
		let NERDSpaceDelims=1  " space around comments
		let NERDUsePlaceHolders=0 " avoid commenter doing weird stuff
		let NERDCommentWholeLinesInVMode=2
		let NERDCreateDefaultMappings=0 " Eliminate default mappings
		let NERDRemoveAltComs=1 " Remove /* comments
		let NERD_c_alt_style=0 " Do not use /* on C nor C++
		let NERD_cpp_alt_style=0
		let NERDMenuMode=0 " no menu
		let g:NERDCustomDelimiters = {
					\ 'vim': { 'left': '"', 'right': '', 'leftAlt': '#', 'rightAlt': ''},
					\ 'markdown': { 'left': '//', 'right': '' },
					\ 'dosini': { 'left': ';', 'leftAlt': '//', 'right': '', 'rightAlt': '', 'leftAlt1': ';', 'rightAlt1': '' },
					\ 'wings_syntax': { 'left': '//', 'right': '' }}

" HIGHLITING
" ~/.dotfiles/vim-utils/autoload/highlight.vim
	" Wed Jun 28 2017 09:32: Why did I added nvim here. Not sure. Removing 
	" TODO.RM-Tue Jul 11 2017 00:18: Fix this here  
	if exists("g:plugins_loaded")
		" C
		call highlight#Set('cTypeTag',                { 'fg': g:brown })
		call highlight#Set('cPreProcTag',             { 'fg': g:cyan })
		call highlight#Set('cFunctionTag',            { 'fg': g:darkred })
		call highlight#Set('cMemberTag',              { 'link': 'cMember' })
		call highlight#Set('cEnumTag',                { 'link': 'cEnum' })

		" Color_Coded
		" call highlight#Set('Variable',								{ 'link' : 'cTypeTag' })
		" call highlight#Set('Namespace',								{ 'fg' : g:cyan })
		" call highlight#Set('EnumConstant',						{ 'link' : 'cEnum' })
		" call highlight#Set('Member',			 						{ 'link' : 'cMember' })
		let s:grey_blue = '#8a9597'
		let s:light_grey_blue = '#a0a8b0'
		let s:dark_grey_blue = '#34383c'
		let s:mid_grey_blue = '#64686c'
		let s:beige = '#ceb67f'
		let s:light_orange = '#ebc471'
		let s:yellow = '#e3d796'
		let s:violet = '#a982c8'
		let s:magenta = '#a933ac'
		let s:green = '#e0a96f'
		let s:lightgreen = '#c2c98f'
		let s:red = '#d08356'
		let s:cyan = '#74dad9'
		let s:darkgrey = '#1a1a1a'
		let s:grey = '#303030'
		let s:lightgrey = '#605958'
		let s:white = '#fffedc'
		let s:orange = '#d08356'
		exe 'hi Member guifg='.s:cyan .' guibg='.s:darkgrey .' gui=italic'
		exe 'hi Variable guifg='.s:light_grey_blue .' guibg='.s:darkgrey .' gui=none'
		exe 'hi Namespace guifg='.s:red .' guibg='.s:darkgrey .' gui=none'
		exe 'hi EnumConstant guifg='.s:lightgreen .' guibg='.s:darkgrey .' gui=none'

		" Cpp
		call highlight#Set('cppTypeTag',              { 'fg': g:brown })
		call highlight#Set('cppPreProcTag',           { 'fg': g:cyan })
		call highlight#Set('cppFunctionTag',          { 'fg': g:darkred })
		call highlight#Set('cppMemberTag',            { 'link': 'cppMember' })
		call highlight#Set('cppEnumTag',              { 'link': 'cppEnum' })

		" Search
		call highlight#Set('Search',									{ 'fg': g:turquoise4 }, 'bold')
		call highlight#Set('IncSearch',								{ 'bg': g:white }, 'bold')
		highlight IncSearch cterm=bold gui=bold
		highlight Search cterm=bold gui=bold
		highlight Comment cterm=italic gui=italic

		" Vim
		call highlight#Set('vimAutoGroupTag',					{ 'fg': g:brown })
		call highlight#Set('vimCommandTag',						{ 'fg': g:cyan })
		call highlight#Set('vimFuncNameTag',					{ 'fg': g:darkred })

		" Python
		call highlight#Set('pythonClassTag',          { 'fg': g:brown })
		call highlight#Set('pythonFunctionTag',       { 'fg': g:darkred })
		call highlight#Set('pythonMethodTag',         { 'link': 'cMember' })

		" Java
		call highlight#Set('javaClassTag',						{ 'fg': g:brown })
		call highlight#Set('javaMethodTag',						{ 'fg': g:darkred })
		call highlight#Set('javaInterfaceTag',        { 'link': 'cMember' })
	endif

" CUSTOM_COMMANDS
	" TODO.RM-Fri Jun 02 2017 16:10: Keep doing this. Until you Substitute
	" all rarely used <Leader>j mappings for commands

	" Convention: All commands names need to start with the autoload file name.
	" And use camel case. This way is easier to search
	command! -nargs=+ -complete=command UtilsCaptureCmdOutput call utils#CaptureCmdOutput(<f-args>)
	command! UtilsProfile call utils#ProfilePerformance()
	command! UtilsDiffSet call utils#SetDiff()
	command! UtilsDiffOff call utils#UnsetDiff()
	command! UtilsDiffReset call utils#UnsetDiff()<bar>call utils#SetDiff()
	command! UtilsIndentWholeFile execute("normal! mzgg=G`z")
	" Remove Trailing Spaces
	command! UtilsRemoveTrailingSpaces execute('let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>')
	" Convert fileformat to dos
	command! UtilsFileFormat2Dos :e ++ff=dos<CR>

" vim:tw=78:ts=2:sts=2:sw=2:
