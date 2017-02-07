" File:					init.vim
" Description:  Vim/Neovim configuration file
" Author:				Reinaldo Molina
" Version:			6.0.1
"								Support for portable vim version
"								files
" Date:					Wed Jan 18 2017 09:53
" Improvements:
		" - [ ] Markdown tables
		" - [ ] Delete duplicate music.
		" - [ ] Construct unified music library
		" - [ ] Markdown math formulas

" Req
	" moved here otherwise conditional mappings get / instead ; as leader
	let mapleader="\<Space>"
	let maplocalleader="\<Space>"
	set nocompatible
	syntax on
	filetype plugin indent on

" PLUGINS_INIT
	" ~/.dotfiles/vim-utils/autoload/plugin.vim
	" Attempt to install vim-plug and all plugins in case of first use
	let g:location_local_vim = "~/.dotfiles/vim-utils/autoload/plugin.vim"
	let g:location_portable_vim = "../.dotfiles/vim-utils/autoload/plugin.vim"
	if !empty(glob(g:location_local_vim))
		execute "source " . g:location_local_vim
		let b:plugins_present = 1
		let g:location_vim_utils = "~/.dotfiles/vim-utils"
	elseif !empty(glob(g:location_portable_vim))
		execute "source " . g:location_portable_vim
		let b:plugins_present = 1
		let g:portable_vim = 1
		let g:location_vim_utils = getcwd() . '/../.dotfiles/vim-utils'
	else
		echomsg "No plugins where loaded"
	endif

	if exists('b:plugins_present') && plugin#Check()
			if plugin#Config()
				let b:plugins_loaded = 1
			else
				echomsg "No plugins where loaded"
			endif
	else
		echomsg "No plugins where loaded"
	endif

" NVIM SPECIFIC
	" ~/.dotfiles/vim-utils/autoload/nvim.vim
	if has('nvim') && exists("b:plugins_loaded")
		call nvim#Config()
	endif

" WINDOWS_SETTINGS
	" ~/.dotfiles/vim-utils/autoload/win32.vim
	if has('win32') && exists("b:plugins_loaded")
		call win32#Config()

" UNIX_SETTINGS
	" ~/.dotfiles/vim-utils/autoload/unix.vim
	elseif has('unix') && exists("b:plugins_loaded")
		call unix#Config()
	endif

" SET_OPTIONS
	" Regular stuff
		"set spell spelllang=en_us
		"omnicomplete menu
		" save marks
		
		let &path .='.,,..,../..,./*,./*/*,../*,~/,~/**,/usr/include/*' " Useful for the find command
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
		set sessionoptions=buffers,curdir,folds,tabpages,resize,winsize,winpos,help
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
		set tags=./tags;,tags;
		set tags+=~/.cache/tags_sys
		set tags+=~/.cache/tags_sys2
		set tags+=~/.cache/tags_unreal
		set tags+=~/.cache/tags_clang

		" let &tags .= substitute(glob("`find ~/.cache/ -name tags* -print`"), "\n", ",", "g")
		" Note: There is also avr tags created by .dotfiles/scripts/maketags.sh
		" !ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ -f ~/.cache/ctags/tags_sys /usr/include
		" !ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ -f ~/.cache/ctags/tags_sys2 /usr/local/include

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

		set noesckeys " No mappings that start with <esc>

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

	" Status Line
		if exists('b:plugins_loaded')
			set background=dark    " Setting dark mode
			colorscheme gruvbox
			" set background=light
			" colorscheme PaperColor
		else
			colorscheme desert
		endif

		if !exists("g:android")
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
			set showcmd
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
		set synmaxcol=140 " Will not highlight passed this column #

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
				let $NVIM_TUI_ENABLE_TRUE_COLOR=1
				let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1
				" Fixes broken nmap <c-h> inside of tmux
				nnoremap <BS> :noh<CR>
				set shada='1000,f1,<500
			endif

			if exists('$TMUX')
				let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
				let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
			elseif has('win32')
				set term=xterm
				let &t_AB="\e[48;5;%dm"
				let &t_AF="\e[38;5;%dm"
			else
				let &t_SI = "\<Esc>[5 q"
				let &t_EI = "\<Esc>[1 q"
			endif
		endif
		
	" Grep
		if exists("b:plugins_loaded")
			call utils#SetGrep()
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
		" wrap syntastic messages
		autocmd FileType qf setlocal wrap
		autocmd FileType mail setlocal wrap
		autocmd FileType mail setlocal spell spelllang=es,en
		autocmd FileType mail setlocal omnifunc=muttaliases#CompleteMuttAliases
		" Markdown
	augroup END

	augroup BuffTypes
	autocmd!
		" Arduino
		autocmd BufNewFile,BufReadPost *.ino,*.pde setf arduino
		" Automatic syntax for wings
		autocmd BufNewFile,BufReadPost *.scp setf wings_syntax
		autocmd BufNewFile,BufReadPost *.log setf unreal-log
		autocmd BufNewFile,BufReadPost *.set,*.sum setf dosini
		"Automatically go back to where you were last editing this file
		autocmd BufReadPost *
			\ if line("'\"") > 0 && line("'\"") <= line("$") |
			\ exe "normal g`\"" |
			\ endif
	augroup END
	" To improve syntax highlight speed. If something breaks with highlight
	" increase these number below
	augroup vimrc
		autocmd!
		autocmd BufWinEnter,Syntax * syn sync minlines=80 maxlines=80
	augroup END


	if exists("b:plugins_loaded")
		augroup VimType
			autocmd!
			" Sessions
			" autocmd VimEnter * call utils#LoadSession('default.vim')
			autocmd VimLeave * call utils#SaveSession('default.vim')
			" Keep splits normalize
			autocmd VimResized * call utils#NormalizeWindowSize()
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

" CUSTOM MAPPINGS
	" List of super useful mappings
	" ga " prints ascii of char under cursor
	" gA " prints radix of number under cursor
	" = fixes indentantion
	" gq formats code
	" Free keys: <Leader>fnzxkiy;
	" Taken keys: <Leader>qwertasdjcvghp<space>mbol

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

	" Vim-Table-Mode <Leader>l?
		" See plugin for the mappings set by this plugin
		
	" Miscelaneous Mappings <Leader>j?
		" nnoremap <Leader>Ma :Man
		" Most used misc get jk, jj, jl, j;
		nnoremap <Leader>jk :call utils#Make()<CR>
		nnoremap <Leader>jl :e $MYVIMRC<CR>
		nnoremap <Leader>j; :NERDTree<CR>
		" Alternate between header and source file
		nnoremap <Leader>jq :call utils#SwitchHeaderSource()<CR>
		" nnoremap <Leader>jq :e %:p:s,.h$,.X123X,:s,.cpp$,.h,:s,.X123X$,.cpp,<CR>
		" Refactor word under the cursor
		nnoremap <Leader>jr :%s/\<<c-r>=expand("<cword>")<cr>\>//gc<Left><Left><Left>
		vnoremap <Leader>jr "hy:%s/<C-r>h//gc<left><left><left>
		" Indent whole file
		nnoremap <Leader>ji mzgg=G`z
		nnoremap <Leader>jh K
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

		" Convert fileformat to dos
		nnoremap <Leader>jD :e ++ff=dos<CR>


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
		nnoremap <Leader>A <c-x>
		nnoremap yl :call utils#YankFrom()<CR>
		nnoremap dl :call utils#DeleteLine()<CR>

		nnoremap <S-CR> O<Esc>

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
		nnoremap <Leader>ch :cd<CR>
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
		"TODO.RM-Wed Nov 30 2016 10:22: Improve grep to autodetect filetype  
		nnoremap <Leader>S :grep --cpp
		nnoremap <S-s> #<C-o>
		vnoremap // y/<C-R>"<CR>

	" Substitute for ESC
		inoremap <C-j> <Esc>
		vnoremap <C-j> <Esc>

	" Buffers Stuff <Leader>b?
		if !exists("b:plugins_loaded")
			nnoremap <S-k> :buffers<CR>:buffer<Space>
		else
			nnoremap <Leader>bs :buffers<CR>:buffer<Space>
		endif
		nnoremap <S-j> :b#<CR>
		nnoremap <Leader>bd :bp\|bw #\|bd #<CR>
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
		"nnoremap <Leader>vr :!svn revert -R .<CR>
		nnoremap <Leader>vl :!svn cleanup .<CR>
		" use this command line to delete unrevisioned or "?" svn files
		"nnoremap <Leader>vL :!for /f "tokens=2*" %i in ('svn status ^| find "?"') do del %i<CR>
		nnoremap <Leader>vs :!svn status .<CR>
		nnoremap <Leader>vu :!svn update .<CR>
		nnoremap <Leader>vo :!svn log .<CR>
		nnoremap <Leader>vi :!svn info<CR>

	" Todo mappings <Leader>t?
		nnoremap <Leader>td :call utils#TodoCreate()<CR>
		nnoremap <Leader>tm :call utils#TodoMark()<CR>
		nnoremap <Leader>tM :call utils#TodoClearMark()<CR>
		nnoremap <Leader>ta :call utils#TodoAdd()<CR>

	" Wiki mappings <Leader>w?
		" TODO.RM-Thu Dec 15 2016 16:00: Add support for wiki under SW-Testbed  
		nnoremap <Leader>wt :call utils#WikiOpen('TODO.md')<CR>
		nnoremap <Leader>wo :call utils#WikiOpen()<CR>
		nnoremap <Leader>ws :call utils#WikiSearch()<CR>
		" This mapping is special is to search the cpp-reference offline help with w3m
		nnoremap <Leader>wc :W3m local /home/reinaldo/Downloads/reference/en/index.html<CR>
		nnoremap <Leader>wu :W3m local /home/reinaldo/Downloads/reference/en/index.html<CR>

	" Comments <Leader>o
		nnoremap <Leader>od :call utils#CommentDelete()<CR>
		" Comment Indent Increase/Reduce
		nnoremap <Leader>oi :call utils#CommentIndent()<CR>
		nnoremap <Leader>oI :call utils#CommentReduceIndent()<CR>
		" mapping ol conflicts with mapping o to new line
		nnoremap cl :call utils#CommentLine()<CR>
		nnoremap <Leader>oe :call utils#EndOfIfComment()<CR>
		nnoremap <Leader>ou :call utils#UpdateHeader()<CR>
		nnoremap <Leader>os :grep --cpp TODO.RM<CR>

	" Compiler
		nnoremap <Leader>Cb :compiler borland<CR>
		" msbuild errorformat looks horrible resetting here
		nnoremap <Leader>Cv :compiler msbuild<CR>
									\:set errorformat&<CR>
		nnoremap <Leader>Cg :compiler gcc<CR>
					\:setlocal makeprg=mingw32-make<CR>

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
		let c_minlines = 15
		" Breaks too often
		" let c_curly_error = 1

	" ft-markdown-syntax
		let g:markdown_fenced_languages= [ 'cpp', 'vim' ]

	" Man
		let g:no_plugin_maps = 1

	" NERD plugins options cant be anywhere else
		let NERDTreeShowBookmarks=1  " B key to toggle
		let NERDTreeShowLineNumbers=1
		let NERDTreeShowHidden=1 " i key to toggle
		let NERDTreeQuitOnOpen=1 " AutoClose after openning file
		let NERDTreeBookmarksFile=g:cache_path . '.NERDTreeBookmarks'
		" Do not load netrw
		let g:loaded_netrw       = 1
		let g:loaded_netrwPlugin = 1
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
		let NERDSpaceDelims=1  " space around comments
" vim:tw=78:ts=2:sts=2:sw=2:
