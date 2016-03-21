"//////////////3/13/2016 8:33:59 PM////////////////
" Req to always be here
set nocompatible
" moved here otherwise conditional mappings get / instead ; as leader 
let mapleader="\<Space>"
let maplocalleader="\<Space>"

"WINDOWS_SETTINGS {{{
if has('win32')
	" Path variables
	let s:personal_path= $HOME . '\vimfiles\personal\'
	let s:plugged_path=  $HOME . '\vimfiles\plugged\'
	let s:custom_font =  'consolas:h8'

	set ffs=dos,unix
	set ff=dos

	if !has('gui_running')
		set term=xterm
		set t_Co=256
		let &t_AB="\e[48;5;%dm"
		let &t_AF="\e[38;5;%dm"
		nnoremap <CR> o<Esc>
		set t_ut=
	endif

	" consistent in all systems
	noremap <Leader>mq <C-q>

	" for this to work you must be in the root directory of your code
	" 1. kill cscope database connection
	" 2. delete previous cscope files
	" 3. create new cscope.fiels, cscope.out, and ctags files
	" 4. connect to new database
	noremap <Leader>tu :cs kill -1<CR>
	\:silent !del /F cscope.files cscope.out<CR>
	\:silent !dir /b /s *.cpp *.h *.hpp *.c > cscope.files<CR> 
	\:silent !cscope -b -i cscope.files -f cscope.out<CR>
	\:silent !ctags -R -f ./.svn/tags<CR>
	\:cs add cscope.out<CR>

	noremap <Leader>mr :!%<CR>
	" Copy and paste into system wide clipboard
	noremap <Leader><Space>v "*p
	noremap <Leader><Space>y "*yy
	nnoremap <Leader><Space>= :silent! let &guifont = substitute(
	\ &guifont,
	\ ':h\zs\d\+',
	\ '\=eval(submatch(0)+1)',
	\ '')<CR>
	nnoremap <Leader><Space>- :silent! let &guifont = substitute(
	\ &guifont,
	\ ':h\zs\d\+',
	\ '\=eval(submatch(0)-1)',
	\ '')<CR>

	nnoremap  o<Esc>

	" Windows specific plugins options {{{
	"Plugin 'ctrlpvim/ctrlp.vim' " quick file searchh"
		set wildignore+=*\\.git\\*,*\\.hg\\*,*\\.svn\\*  " Windows ('noshellslash')
		let g:ctrlp_custom_ignore = {
			\ 'dir':  '\v[\/]\.(git|hg|svn)$',
			\ 'file': '\v\.(tlog|log|db|obj|o|exe|so|dll|dfm)$',
			\ 'link': 'SOME_BAD_SYMBOLIC_LINKS',
			\ }
	" }}}
" }}}

" UNIX_SETTINGS {{{
elseif has('unix')
	" Path variables
	let s:personal_path= $HOME . '/.vim/personal/'
	let s:plugged_path=  $HOME . '/.vim/plugged/'
	let s:custom_font = 'monospace\ 8'

	set ffs=unix,dos
	set ff=unix
	" making C-v paste stuff from system register
	noremap <Leader>mq <C-v>
	if !has('gui_running')
		set t_Co=256
		" fixes colorscheme not filling entire backgroud
		set t_ut=
		" TODO: fix all this
		nmap x :w<CR>
		nnoremap <CR> o<Esc>
	endif
	" this one below DOES WORK in linux just make sure is ran at root folder
	noremap <Leader>tu :cs kill -1<CR>
	\:!rm cscope.files cscope.out<CR>
	\:!find . -iname '*.c' -o -iname '*.cpp' -o -iname '*.h' -o -iname '*.hpp' > cscope.files<CR>
  	\:!cscope -b -i cscope.files -f cscope.out<CR>
	\:cs add cscope.out<CR>
	\:silent !ctags -R --sort=yes --c++-kinds=+pl --fields=+iaS --extra=+q .<CR>

	noremap <Leader>mr :!./%<CR>
	noremap <Leader><Space>v "+p
	noremap <Leader><Space>y "+yy

	nnoremap <Leader><Space>= :silent! let &guifont = substitute(
	\ &guifont,
	\ '\ \zs\d\+',
	\ '\=eval(submatch(0)+1)',
	\ '')<CR>
	nnoremap <Leader><Space>- :silent! let &guifont = substitute(
	\ &guifont,
	\ '\ \zs\d\+',
	\ '\=eval(submatch(0)-1)',
	\ '')<CR>

	" VIM_PLUG_STUFF {{{
	"Plugin 'ctrlpvim/ctrlp.vim' " quick file searchh"
		set wildignore+=*/.git/*,*/.hg/*,*/.svn/*        " Linux/MacOSX
		let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'

	" Syntastic
		let g:syntastic_cpp_compiler_options = ' -std=c++14' 
endif
	" }}}
" }}}

" STUFF_FOR_BOTH_SYSTEMS {{{
	" PLUGINS_FOR_BOTH_SYSTEMS {{{
	" Call Vim-Plug Plugins should be from here below
	if !has('nvim')
		call plug#begin(s:plugged_path)
		Plug 'Shougo/neocomplete.vim'
	else
		call plug#begin('~/.config/nvim/autoupload/plug.vim')
		Plug 'Shougo/deoplete.nvim'
	endif
	"Plug 'OmniSharp/omnisharp-vim'
	"Plug 'tpope/vim-dispatch' " used for omnisharp completion 
	Plug 'chrisbra/vim-diff-enhanced'
	Plug 'scrooloose/nerdtree'
	Plug 'scrooloose/nerdcommenter'
	Plug 'lervag/vimtex' " Latex support
	Plug 'bling/vim-airline'	" Status bar line
	Plug 'Vim-R-plugin'
	Plug 'Shougo/neosnippet'
	Plug 'Shougo/neosnippet-snippets'
	Plug 'honza/vim-snippets'
	Plug 'tpope/vim-surround'
	Plug 'junegunn/rainbow_parentheses.vim'
	Plug 'morhetz/gruvbox' " colorscheme gruvbox 
	Plug 'scrooloose/syntastic'
	Plug 'ctrlpvim/ctrlp.vim'
	Plug 'octol/vim-cpp-enhanced-highlight'
	Plug 'Tagbar'
	Plug 'vimwiki/vimwiki', {'branch': 'dev'}

	" All of your Plugins must be added before the following line
	call plug#end()            " required
	" }}}

" GUI SETTINGS {{{
if has('gui_running')
	let &guifont = s:custom_font
	set guioptions-=T  " no toolbar
	set guioptions-=m  " no menu bar
	set guioptions-=r  " no scroll bar
	set guioptions-=l  " no scroll bar
	set guioptions-=L  " no scroll bar
	nnoremap <S-CR> O<Esc>
	" mapping <CR> in gvim to new empty line
endif

"}}}

" OmniCppComplete, Functions, and set settings {{{
let OmniCpp_NamespaceSearch = 1
let OmniCpp_GlobalScopeSearch = 1
let OmniCpp_ShowAccess = 1
let OmniCpp_ShowPrototypeInAbbr = 1 " show function parameters
let OmniCpp_MayCompleteDot = 1 " autocomplete after .
let OmniCpp_MayCompleteArrow = 1 " autocomplete after ->
let OmniCpp_MayCompleteScope = 1 " autocomplete after ::
let OmniCpp_DefaultNamespaces = ["std", "_GLIBCXX_STD"]
" }}}

" FUNCTIONS {{{
" Only works in vimwiki filetypes
" TODO: make every function much smarter
" TODO: autodownload files
function! s:WikiTable() abort
	if &ft =~ 'wiki'
		exe ":VimwikiTable " . input("Enter col row:")
	else
		echo "Current buffer is not of wiki filetype"
	endif
endfunction

" Input: empty- It will ask you what type of file you want to search
" 		 String- "1", "2", or specify files in which you want to search
function! s:GlobalSearch(type) abort 
	"echomsg string(a:type)  " Debugging purposes
	if a:type == "0" 
		echo "Search Filetypes:\n\t1.Any\n\t2.Cpp\n" 
		let l:file = nr2char(getchar())
	else
		let l:file = a:type
	endif
	"echomsg string(l:file)  " Debugging purposes
	if l:file == 1
		let l:file = "**/*"
	elseif l:file == 2
		let l:file = "**/*.cpp **/*.h **/*.c **/*.hpp"
	endif
	" search in all files of type l:file the input string recursively
	exe "vimgrep /" . input("Search in \"" . getcwd() . "\" for:") . "/ " . l:file
	copen 20
endfunction

" Commits current buffer
function! s:GitCommit() abort
	if <SID>CheckFileOrDir(1, ".git") > 0
		silent !git add .
		exe "silent !git commit -m \"" . input("Commit comment:") . "\""
		!git push origin master 
	else
		echo "No .git directory was found"
	endif
endfunction

" Should be performed on root .svn folder
function! s:SvnCommit() abort
	exe "!svn commit -m \"" . input("Commit comment:") . "\" ."
endfunction

function! s:FormatFile() abort
	let g:clang_format_path='clang-format-3.8'
	let l:lines="all"
	let l:format = s:personal_path . 'clang-format.py' 
	if filereadable(l:format) > 0
		exe "pyf " . l:format
	else	
		echo "File \"" . l:format . "\" does not exist"
	endif
endfunction

" TODO: make smarter
function! s:FindIf() abort
	while 1
		" jump to matching {
		 normal %
		 " check to see if there is another else
		 if match(getline(line(".")-1, line(".")), "else") > -1
			" search curr and previous 2 lines for }
			if match(getline(line(".")-2, line(".")), "}") > -1
				" jump to it
				exe "normal ?}\<CR>"
			" if there is no } could be no braces else if
			else
				" go up to lines and see what happens
				normal kk
			endif
		else
			" if original if was found copy it to @7 and jump back to origin
			exe "normal k^\"7y$`m"
			break
		endif
	endwhile
endfunction

function! s:TruncComment(comment) abort
	" brute trunc at 46
	let l:strip = a:comment
	if strchars(l:strip) > 46
		let l:strip = strpart(l:strip,0,46)
		let l:strip .= "..."
	endif
	" if theres a comment get rid of it
	let l:com = match(l:strip, "/")
	if l:com > -1
		let l:strip = strpart(l:strip,0,l:com-1)
	endif
	return l:strip
endfunction

" Gotchas: Start from the bottom up commeting
function! s:EndOfIfComment() abort
	" TDOD: Eliminate comments on lines very important
	" is there a } in this line?
	"let g:testa = 0  " Debugging variable
	let l:ref_col = match(getline("."), "}")
	if  l:ref_col > -1 " if it exists
		" Determine what kind of statement is this i.e: for, while, if, else if
		" jump to matchin {, mark it with m, copy previous line to @8, and jump back down to original }
		"exe "normal mm" . l:ref_col . "|%k^\"8y$j%"
		exe "normal mm" . l:ref_col . "|%"
		let l:upper_line = line(".")
		exe "normal k^\"8y$j%"
		" if original closing brace it is and else if || else
		if match(getline(line(".")-1, line(".")), "else") > -1
			let g:testa = 1
			" if { already contains closing if put it
			" TODO:fix this to make search for else not only in @8 line
			if match(getline(l:upper_line-1,l:upper_line), "else") > -1
				" search upwards until you find initial if and copy it to @7
				call <SID>FindIf()
				" truncate comment line in case too long
				let @7 = <SID>TruncComment(@7)
				" append // "initial if..." : "
				let l:end = "  // \""
				execute "normal a" . l:end . @7 . "\" : \"\<Esc>"
			else
				let l:end = "  // \""
				execute "normal a" . l:end . "\<Esc>"
			endif
		" search openning brace for else
		elseif match(getline(l:upper_line-1,l:upper_line), "else") > -1
			let g:testa = 2
			" search upwards until you find initial if and copy it to @7
			call <SID>FindIf()
			" truncate comment line in case too long
			let @7 = <SID>TruncComment(@7)
			" append // "initial if..." : "
			let l:end = "  // End of \""
			execute "normal a" . l:end . @7 . "\" : \"\<Esc>"
		" if not very easy
		else 
			" Append // End of "..."
			let l:end = "  // End of \""
			execute "normal a" . l:end . "\<Esc>"
		endif
		" truncate comment line in case too long
		let @8 = <SID>TruncComment(@8)
		execute "normal a" . @8 . "\""
	else
		echo "EndOfIfComment(): Closing brace } needs to be present at the line"
	endif
endfunction
nnoremap <Leader>ce :call <SID>EndOfIfComment()<CR>

function! s:CheckFileOrDir(type,name) abort
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
		return -1
	endif
endfunction

function! s:YankFrom() abort
	exe "normal :" . input("Yank From Line:") . "y\<CR>"
endfunction
nnoremap yl :call <SID>YankFrom()<CR>

function! s:DeleteLine() abort
	exe "normal :" . input("Delete Line:") . "d\<CR>``"
endfunction
nnoremap dl :call <SID>DeleteLine()<CR>

function! s:CommentLine() abort
	if exists("*NERDComment")
		exe "normal mm:" . input("Comment Line:") . "\<CR>"
		exe "normal :call NERDComment(\"n\", \"Toggle\")\<CR>`m"
	else
		echo "Please install NERDCommenter"
	endif
endfunction
nnoremap cl :call <SID>CommentLine()<CR>
 "}}}

" SET_OPTIONS {{{
filetype plugin on   
filetype indent on   
"set spell spelllang=en_us
"omnicomplete menu
set nospell
set diffexpr=
" save marks 
set viminfo='1000,f1,<800,%1024
set cursorline
set showtabline=1 " always show tabs in gvim, but not vim"
set tabstop=4     " a tab is four spaces
set backspace=indent,eol,start
                    " allow backspacing over everything in insert mode
set autoindent    " always set autoindenting on
set copyindent    " copy the previous indentation on autoindenting
set number        " always show line numbers
set shiftwidth=4  " number of spaces to use for autoindenting
set shiftround    " use multiple of shiftwidth when indenting with '<' and '>'
set showmatch     " set show matching parenthesis
set smartcase     " ignore case if search pattern is all lowercase,
                    "    case-sensitive otherwise
set smarttab      " insert tabs on the start of a line according to
                    "    shiftwidth, not tabstop
set hlsearch      " highlight search terms
set relativenumber
set incsearch     " show search matches as you type
set history=1000         " remember more commands and search history
set undolevels=1000      " use many muchos levels of undo
" ignore these files to for completion
set wildignore+=*.o,*.obj,*.bak,*.exe,*.py[co],*.swp,*~,*.pyc,.svn,.git
set completeopt=menuone,menu,longest,preview
set wildmenu
set wildmode=list:longest
set noundofile
set title                " change the terminal's title
set visualbell           " don't beep
set noerrorbells         " don't beep
set nobackup " no backup files 
set noswapfile
"set autochdir " working directory is always the same as the file you are editing
set sessionoptions+=localoptions,winpos
set hidden
" wont open a currently open buffer
set switchbuf=useopen
" see :h timeout this was done to make use of ' faster and keep the other
" timeout the same
set notimeout
set nottimeout
set timeoutlen=300
set ttimeoutlen=1000
set nowrap        " wrap lines
set nowrapscan        " do not wrap search at EOF
" will look in current directory for tags
" THE BEST FEATURE I'VE ENCOUNTERED SO FAR OF VIM
" CAN BELIEVE I DIDNT DO THIS BEFORE
set tags+=.\tags;\

if has('cscope')
	set cscopetag cscopeverbose
	if has('quickfix')
		set cscopequickfix=s+,c+,d+,i+,t+,e+
	endif
	cnoreabbrev csa cs add
	cnoreabbrev csf cs find
	cnoreabbrev csk cs kill
	cnoreabbrev csr cs reset
	cnoreabbrev css cs show
	cnoreabbrev csh cs help
endif
set matchpairs+=<:>
set smartindent " these 2 make search case smarter
set ignorecase
set autoread " autoload files written outside of vim
syntax on
" Display tabs and trailing spaces visually
"set list listchars=tab:\ \ ,trail:?
set linebreak    "Wrap lines at convenient points
"set scrolloff=8         "Start scrolling when we're 8 lines away from margins

" Open and close folds Automatically
set foldenable
"set foldmethod=indent   "fold based on indent
set foldnestmax=18      "deepest fold is 10 levels
"set nofoldenable        "dont fold by default
set foldlevel=1         "this is just what i use
" use this below option to set other markers
"'foldmarker' 'fmr'	string (default: "{{{,}}}")
set viewoptions=folds,options,cursor,unix,slash " better unix /
" For conceal markers.
if has('conceal')
	set conceallevel=2 concealcursor=nv
endif

" record undo history in this path
if has('persistent_undo')
	let dir= s:personal_path . 'undodir'
	" Create undo dir if it doesnt exist
	if !isdirectory(dir) 
		if exists("*mkdir") 
			call mkdir(dir, "p")
			let &undodir= dir
			set undofile
			set undolevels=10000
			set undoreload=10000
		else
			set noundofile
			echo "Failed to create undodir"
		endif
	endif
endif

set lazyredraw " Had to addit to speed up scrolling 
set ttyfast " Had to addit to speed up scrolling 

" }}}

" ALL_AUTOGROUP_STUFF {{{
augroup Filetypes
	autocmd!
	" Cpp
	autocmd FileType cpp,c,h,hpp setlocal omnifunc=omni#cpp#complete#Main
	autocmd FileType cpp,c,h,hpp setlocal cindent
	autocmd FileType cpp,c,h,hpp setlocal foldmethod=indent
	" All files
	autocmd FileType * RainbowParentheses
	autocmd FileType * setlocal textwidth=110
	" automatically open and close the popup menu / preview window
	autocmd CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
	autocmd FileType cs OmniSharpHighlightTypes
	autocmd FileType cs setlocal omnifunc=OmniSharp#Complete
	autocmd FileType nerdtree setlocal relativenumber
	autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
	autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
	autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
	autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
	autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
	" Wiki specific mappings
	autocmd FileType vimwiki nmap <buffer> <Leader>wn <Plug>VimwikiNextLink
	autocmd FileType vimwiki nmap <buffer> <Leader>wp <Plug>VimwikiPrevLink
	autocmd FileType vimwiki nmap <buffer> == <Plug>VimwikiAddHeaderLevel
	autocmd FileType vimwiki nmap <buffer> ++ <Plug>VimwikiRemoveHeaderLevel
	autocmd FileType vimwiki nmap <buffer> >> <Plug>VimwikiIncreaseLvlSingleItem
	autocmd FileType vimwiki nmap <buffer> << <Plug>VimwikiDecreaseLvlSingleItem
	autocmd FileType vimwiki nmap <buffer> <Leader>wa <Plug>VimwikiTabIndex
	"autocmd FileType vimwiki nmap <buffer><unique> <Leader>wt :call <SID>WikiTable()<CR>
	autocmd FileType vimwiki nmap <buffer> <Leader>wf <Plug>VimwikiFollowLink
	autocmd FileType vimwiki setlocal spell spelllang=en_us
	" Latex
	autocmd FileType tex setlocal spell spelllang=en_us
	autocmd FileType tex setlocal fdm=indent
	"autocmd FileType tex setlocal conceallevel=0  " never hide anything
	" Display help vertical window not split
	autocmd FileType help wincmd L
	" autofold my vimrc
	autocmd FileType vim setlocal foldmethod=marker
	" Arduino
	autocmd BufNewFile,BufReadPost *.ino,*.pde setlocal ft=arduino
	" automatic syntax for *.scp
	autocmd BufNewFile,BufReadPost *.scp setlocal syntax=asm
	" binary
	"autocmd BufNewFile,BufReadPost *.bin setlocal ft=xxd
	"autocmd BufWritePre xxd %!xxd -r | setlocal binary | setlocal ft=modibin
	"autocmd FileType xxd %!xxd

augroup END
" }}}

" CUSTOM MAPPINGS {{{
" on quickfix window go to line selected
noremap <Leader>qc :.cc<CR>
" go to next result
noremap <Leader>qn :cn<CR>
" go to previous result
noremap <Leader>qp :cn<CR>
" on quickfix window go to next file
noremap <Leader>qf :cnf<CR>
" on quickfix close window
noremap <Leader>ql :ccl<CR>
" open quickfix window
noremap <Leader>qo :copen 20<CR>

"//////MISCELANEOUS MAPPINGS/////////////
" edit vimrc on a new tab
noremap <Leader>mv :e $MYVIMRC<CR>
" source current document(usually used with vimrc) added airline
" replace auto sourcing of $MYVIMRC
noremap <Leader>ms :so %<CR>
"noremap <Leader>ms :so %<CR>:AirlineRefresh<CR>
 " used to save in command line something
nnoremap <A-s> :w<CR>
noremap <A-n> :noh<CR>
noremap <A-c> i<Space><Esc>
"noremap <Leader>mn :noh<CR>
" duplicate current char
nnoremap <Leader>mp ylp
vnoremap <Leader>mp ylp
noremap <Leader>mt :set relativenumber!<CR>
noremap <Leader>md :Dox<CR>

" FOLDING {{{
" Folding select text then S-f to fold or just S-f to toggle folding
nnoremap <Leader>ff za
onoremap <Leader>ff <C-C>za
nnoremap <Leader>ff zf
" toggle fold za
" next fold zj
" previous fold zk
" close all folds zM
" delete fold zd
" opens all folds at cursor zO
" }}}

" move between windows
noremap <Leader>h <C-w>h
noremap <Leader>j <C-w>j
noremap <Leader>k <C-w>k
noremap <Leader>l <C-w>l
" move windows positions
noremap <Leader>H <C-w>H
noremap <Leader>J <C-w>J
noremap <Leader>K <C-w>K
noremap <Leader>L <C-w>L
" expand windows positions
noremap <Leader>. <C-w>>
noremap <Leader>, <C-w><
noremap <Leader>- <C-w>-
noremap <Leader>= <C-w>+

" not paste the deleted word
nnoremap <Leader>p "0p
vnoremap <Leader>p "0p
" move current line up
nnoremap <A-k> ddkk""p
" move current line down
noremap <A-j> dd""p
" Close all
noremap <A-x> :qall<CR>
" open new to tab to explorer
noremap <Leader><Space>n :tab split<CR>
" Switch back and forth between header file
nnoremap <Leader>moh :e %:p:s,.h$,.X123X,:s,.cpp$,.h,:s,.X123X$,.cpp,<CR>"
" DIFF SUTFF {{{
" diff left and right window
noremap <Leader>do :windo diffthis<CR>
" diff go to next diff
noremap <C-Down> ]c
" diff go to previous diff
noremap <C-Up> [c
" diff get from the other window
noremap <C-Left> :diffget<CR>
" diff put difference onto other window
noremap <C-Right> :diffput<CR>
" close diff
noremap <Leader>dl :diffoff!<CR>
" off highlited search
" }}}

"SPELL_CHECK {{{
" search forward
noremap <Leader>sn ]s
" search backwards
noremap <Leader>sp [s
" suggestion
noremap <Leader>sC z=1<CR><CR>
noremap <Leader>sc z=
" toggle spelling
noremap <Leader>st :setlocal spell! spelllang=en_us<CR>

noremap <Leader>sf :call FixPreviousWord()<CR>
function! FixPreviousWord() abort
	normal [s1z=`m
endfunction
" add to dictionary
noremap <Leader>sa zg
" mark wrong
noremap <Leader>sw zw
" repeat last spell correction
noremap <Leader>sr :spellr<CR>
" SyntasticCheck toggle
noremap <Leader>so :SyntasticToggleMode<CR>
nnoremap <Leader>Sa :call <SID>GlobalSearch(1)<CR>
nnoremap <Leader>Sc :call <SID>GlobalSearch(2)<CR>
nnoremap <Leader>Sf :call <SID>GlobalSearch(0)<CR>
" Normal backspace functionalit y
" }}}

 " Substitute for ESC  
inoremap qq <Esc>
vnoremap qq <Esc>
cnoremap qq <Esc>
noremap <S-q> yyp
"TAB_STUFF {{{
noremap <S-j> :b#<CR>
noremap <A-t> gT
noremap <Leader>bo :CtrlPBuffer<CR>
noremap <Leader>bd :bd %<CR>
" deletes all buffers
noremap <Leader>bD :bufdo bd<CR>
noremap <Leader>bs :buffers<CR>:buffer<Space>
noremap <Leader>bS :bufdo 
" move tab to the left
nnoremap <silent> <A-Left> :execute 'silent! tabmove ' . (tabpagenr()-2)<CR>
" move tab to the right
noremap <silent> <A-Right> :execute 'silent! tabmove ' . (tabpagenr()+1)<CR>
noremap <Leader>be :enew<CR>
noremap <S-x> :tabclose<CR>
" }}}

" move to the beggning of line
noremap <S-w> $
" move to the end of line
noremap <S-b> ^
" jump to corresponding item<Leader> ending {,(, etc..
nnoremap <S-t> %
vnoremap <S-t> %
" insert tab spaces in normal mode
noremap <Tab> i<Tab><Esc>
" Automatically insert date
nnoremap <F5> a///////////////<Esc>"=strftime("%c")<CR>Pa///////////////<Esc>

" cd into current dir path and into dir above current path
nnoremap <Leader>cd :cd %:p:h<CR>
						\:pwd<CR>
nnoremap <Leader>cu :cd %:p:h<CR>
						\:cd ..<CR>
						\:pwd<CR>
nnoremap <Leader>cc :pwd<CR>

"SEARCH_REPLACE {{{
noremap <Leader>w /\<<c-r>=expand("<cword>")<cr>\>
noremap <Leader>W :%s/\<<c-r>=expand("<cword>")<cr>\>/
" These are only for command line
" insert in the middle of whole word search
cnoremap <A-w> \<\><Left><Left>
" insert visual selection search
cnoremap <A-c> <c-r>=expand("<cword>")<cr>
cnoremap <A-s> %s/
" This is a very good to show and search all current but a much better is 
"nnoremap gr :vimgrep <cword> %:p:h/*<CR>
			"\:copen 20<CR>
" remaped search to f
noremap <S-s> #
vnoremap // y/<C-R>"<CR>
" }}}

" Auto indent pasted text
nnoremap p p=`]<C-o>
nnoremap P P=`]<C-o>
" Visual shifting (does not exit Visual mode)
vnoremap < <gv
vnoremap > >gv
" refactor
nnoremap <A-r> :%s/\<<c-r>=expand("<cword>")<cr>\>//gc<Left><Left><Left>
vnoremap <A-r> :%s///gc<Left><Left><Left>

nnoremap <Down> :cn<CR>
nnoremap <Up> :cp<CR>
nnoremap <Right> :cnf<CR>
nnoremap <Left> :cpf<CR>

" vim-hex
"nnoremap <Leader>hr :%!xxd<CR>
				"\:set ft=xxd<CR>
"nnoremap <Leader>hw :%!xxd -r<CR>
				"\:set binary<CR>
				"\:set ft=<CR>

" Quick write session with F2
"TODO:
nnoremap <Leader>mz :exe("mksession! " . s:personal_path . "sessions\")<CR>
" And load session with F3
nnoremap <Leader>mx :exe("source! " . s:personal_path . "sessions\")<CR>

" Mappings to execute programs
nnoremap <Leader>ewf :!start cmd /k "WINGS.exe 3 . 4.ini" & exit<CR>
nnoremap <Leader>ewg :exe("!start cmd /k \"WINGS.exe 3 . " . input("Config file:", "", "file") . "\" & exit")<CR>

" VERSION_CONTROL {{{
" For all this commands you should be in the svn root folder
" Add all files
noremap <Leader>vA :!svn add * --force<CR>
" Add specific files
noremap <Leader>va :!svn add 
" Commit using typed message
noremap <Leader>vc :call SvnCommit()<CR>
" Commit using File for commit content
noremap <Leader>vC :!svn commit --force-log -F commit_msg.wiki<CR>
noremap <Leader>vd :!svn delete --keep-local 
" revert previous commit
noremap <Leader>vr :!svn revert -R .<CR>
noremap <Leader>vl :!svn cleanup .<CR>
" use this command line to delete unrevisioned or "?" svn files
"noremap <Leader>vL :!for /f "tokens=2*" %i in ('svn status ^| find "?"') do del %i<CR>
noremap <Leader>vs :!svn status .<CR>
noremap <Leader>vu :!svn update .<CR>
noremap <Leader>vo :!svn log .<CR>
noremap <Leader>vi :!svn info<CR>
noremap <Leader>gp :call <SID>GitCommit()<CR>
nnoremap <Leader>gP :!git add .<CR>
			\:!git commit -F commit_msg.wiki<CR>
			\:!git push CppTut master<CR>
" }}}

" see :h <c-r>
cnoremap <A-p> <c-r>0
" }}}

" PLUGIN_OPTIONS {{{
	"Plugin 'VundleVim/Vundle.vim' {{{
		noremap <Leader>Pl :PlugList<CR>
		" lists configured plugins
		noremap <Leader>Pi :PlugInstall<CR>
		noremap <Leader>Pu :PlugInstall!<CR>
		" installs plugins; append `!` to update or just :PluginUpdate
		noremap <Leader>Ps :PlugSearch<CR>
		" searches for foo; append `!` to refresh local cache
		noremap <Leader>Pc :PlugClean<CR>      
		" confirms removal of unused plugins; append `!` to auto-approve removal
		"
		" see :h vundle for more details or wiki for FAQ
	" }}}

	"Plugin 'scrooloose/nerdcommenter'" {{{
		let NERDUsePlaceHolders=0 " avoid commenter doing weird stuff
		let NERDCommentWholeLinesInVMode=2
		let NERDCreateDefaultMappings=0 " Eliminate default mappings
		let NERDRemoveAltComs=0 " Do not use alt comments /*
		let NERDMenuMode=0 " no menu
		let g:NERDCustomDelimiters = {
			\ 'vim': { 'left': '"', 'right': '' },
			\ 'vimwiki': { 'left': '%%', 'right': '' }}
			"\ 'vim': { 'left': '"', 'right': '' }
			"\ 'grondle': { 'left': '{{', 'right': '}}' }
		"\ }
		nmap - <plug>NERDCommenterToggle
		nmap <Leader>ct <plug>NERDCommenterToggle
		vmap - <plug>NERDCommenterToggle
		inoremap <C-c> <plug>NERDCommenterInsert
		nmap <Leader>ca <plug>NERDCommenterAppend
		nmap <Leader>cw <plug>NERDCommenterToEOL
		vmap <Leader>cs <plug>NERDCommenterSexy
		" }}}
	"Plugin 'scrooloose/NERDTree' {{{
		noremap <Leader>nb :Bookmark 
		let NERDTreeShowBookmarks=1  " B key to toggle
		noremap <Leader>no :NERDTree<CR>
		" enable line numbers
		let NERDTreeShowLineNumbers=1
		" make sure relative line numbers are used
		let NERDTreeShowHidden=1 " i key to toggle
		let NERDTreeMapJumpLastChild=',j' 
		let NERDTreeMapJumpFirstChild=',k' 
		let NERDTreeMapOpenExpl=',e' 
		let NERDTreeMapOpenVSplit=',s'
        let NERDTreeQuitOnOpen=1 " AutoClose after openning file
		" }}}

" Plugin 'lervag/vimtex' " Latex support {{{
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
		" }}}

" Plugin 'bling/vim-airline' " Status bar line {{{
		set laststatus=2
		let g:airline_section_b = '%{strftime("%c")}'
		let g:airline#extensions#bufferline#enabled = 1
		let g:airline#extensions#bufferline#overwrite_variables = 1
		" }}}

" Plugin 'file:///home/reinaldo/.vim/bundle/vim-hardy' {{{
		if has('unix')
			let g:hardy_arduino_path='/home/reinaldo/Downloads/arduino-1.6.5-r5/arduino'
		endif
		" }}}

" Plugin 'Shougo/neocomplete.vim' {{{
		"Note: This option must set it in .vimrc(_vimrc).  NOT IN .gvimrc(_gvimrc)!
		" Disable AutoComplPop.
		if !has('nvim')
			let g:acp_enableAtStartup = 0
			" Use neocomplete.
			let g:neocomplete#enable_at_startup = 1
			" Use smartcase.
			let g:neocomplete#enable_smart_case = 1
			let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'
			" Define dictionary.
			let g:neocomplete#sources#dictionary#dictionaries = {
				\ 'default' : '',
				\ 'vimshell' : $HOME.'/.vimshell_hist',
				\ 'scheme' : $HOME.'/.gosh_completions'
				\ }
			let g:neocomplete#data_directory = s:personal_path . 'neocomplete'  " let neocomplete
			" Define keyword.
			if !exists('g:neocomplete#keyword_patterns')
				let g:neocomplete#keyword_patterns = {}
			endif
			let g:neocomplete#keyword_patterns['default'] = '\h\w*'
			" Plugin key-mappings.
			inoremap <expr><C-g>     neocomplete#undo_completion()
			inoremap <expr><C-l>     neocomplete#complete_common_string()
			" Recommended key-mappings.
			" <CR>: close popup and save indent.
			inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
			function! s:my_cr_function()
				return (pumvisible() ? "\<C-y>" : "" ) . "\<CR>"
				" For no inserting <CR> key.
				"return pumvisible() ? "\<C-y>" : "\<CR>"
			endfunction
			" <TAB>: completion.
			"inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
			" <C-h>, <BS>: close popup and delete backword char.
			inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
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
			if !exists('g:neocomplete#force_omni_input_patterns')
				let g:neocomplete#force_omni_input_patterns = {}
			endif
			let g:neocomplete#sources#omni#input_patterns.php =
			\ '[^. \t]->\%(\h\w*\)\?\|\h\w*::\%(\h\w*\)\?'
			let g:neocomplete#sources#omni#input_patterns.c =
			\ '[^.[:digit:] *\t]\%(\.\|->\)\%(\h\w*\)\?'
			let g:neocomplete#sources#omni#input_patterns.cpp =
			\ '[^.[:digit:] *\t]\%(\.\|->\)\%(\h\w*\)\?\|\h\w*::\%(\h\w*\)\?'
			" For perlomni.vim setting.
			" https://github.com/c9s/perlomni.vim
			let g:neocomplete#sources#omni#input_patterns.perl =
			\ '[^. \t]->\%(\h\w*\)\?\|\h\w*::\%(\h\w*\)\?'
			" For smart TAB completion.
			imap <expr><TAB>  pumvisible() ? "\<C-n>" :
					\ <SID>check_back_space() ? "\<TAB>" :
					\ neocomplete#start_manual_complete()
			  function! s:check_back_space() 
				let col = col('.') - 1
				return !col || getline('.')[col - 1]  =~ '\s'
			  endfunction
		else
			let g:deoplete#enable_at_startup = 1	
			let g:deoplete#enable_smart_case = 1
			" <C-h>, <BS>: close popup and delete backword char.
			inoremap <expr><C-h> deoplete#mappings#smart_close_popup()."\<C-h>"
			inoremap <expr><BS>  deoplete#mappings#smart_close_popup()."\<C-h>"
			" <CR>: close popup and save indent.
			inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
			function! s:my_cr_function() abort
				return deoplete#mappings#close_popup() . "\<CR>"
			endfunction
			inoremap <silent><expr> <Tab>
			\ pumvisible() ? "\<C-n>" :
			\ deoplete#mappings#manual_complete()
		endif
		" }}}
		
" Plugin 'Shougo/neocomplete-snippets.vim' {{{
		" Plugin key-mappings.
		imap <C-k>     <Plug>(neosnippet_expand_or_jump)
		smap <C-k>     <Plug>(neosnippet_expand_or_jump)
		xmap <C-k>     <Plug>(neosnippet_expand_target)
		" SuperTab like snippets behavior.
		"imap <expr><TAB>
		" \ pumvisible() ? "\<C-n>" :
		" \ neosnippet#expandable_or_jumpable() ?
		" \    "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
		smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
		\ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
		let g:neosnippet#enable_snipmate_compatibility = 1
		let g:neosnippet#snippets_directory= s:plugged_path . 'vim-snippets'
		" }}}

" Plugin 'Vim-R-plugin' {{{
		" http://cran.revolutionanalytics.com
		" Install R, Rtools 
		" git clone https://github.com/jalvesaq/VimCom.git // Do this in command to
		" download the library then in R do the bottom command by substituting path
		" with your path to where you downloaded vimcom
		" install.packages("<location>", type = "source", repos = NULL)
		" put this in your InstallationRdir/etc/Rprofile.site
							"options(vimcom.verbose = 1)
							"library(vimcom)
							" }}}
							
" Plugin 'Tagbar' {{{
        let g:tagbar_autofocus = 1
        let g:tagbar_show_linenumbers = 2
        let g:tagbar_map_togglesort = "r"
		noremap <Leader>tt :TagbarToggle<CR>
		noremap <Leader>tk :cs kill -1<CR>
		noremap <silent> <Leader>tj <C-]>
		noremap <Leader>tr <C-t>
		noremap <Leader>tn :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
		" ReLoad cscope database
		noremap <Leader>tl :cs add $CSCOPE_DB<CR>
		" Find functions calling this function
		noremap <Leader>tc :cs find c <C-R>=expand("<cword>")<CR><CR>
		" Find functions definition
		noremap <Leader>tg :cs find g <C-R>=expand("<cword>")<CR><CR>
		" Find functions called by this function
		noremap <Leader>td :cs find d <C-R>=expand("<cword>")<CR><CR>
		noremap <Leader>ts :cs show<CR>
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
		" }}}

" Plugin 'ctrlpvim/ctrlp.vim' " quick file searchh {{{
		noremap <Leader>ao :CtrlP<CR>
		noremap <S-k> :CtrlPBuffer<CR>
		noremap <A-v> :vs<CR>:CtrlPBuffer<CR>
		noremap <A-o> :CtrlPMixed<CR>
		noremap <Leader>at :tabnew<CR>:CtrlPMRU<CR>
		noremap <Leader>av :vs<CR>:CtrlPMRU<CR>
		noremap <Leader>as :sp<CR>:CtrlPMRU<CR>
		noremap <Leader>al :CtrlPClearCache<CR>
		let g:ctrlp_match_window = 'bottom,order:btt,min:1,max:10,results:10'
		let g:ctrlp_cache_dir = s:personal_path . 'ctrlp'
		"if executable('ag')
			"let g:ctrlp_user_command = 'ag %s -l --nocolor --hidden -g ""'
		"endif
		" }}}

" Plugin 'Newtr' VIM built in Explorer {{{
		let g:netrw_sort_sequence='[\/]$,*,\.bak$,\.o$,\.h$,\.info$,\.swp$,\.obj$'
		let g:netrw_localcopydircmd	="copy /-y"
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

"/	Doxygen.vim {{{
		let g:DoxygenToolkit_briefTag_pre="@Description:  " 
		let g:DoxygenToolkit_paramTag_pre="@Var: " 
		let g:DoxygenToolkit_returnTag="@Returns:   " 
		let g:DoxygenToolkit_blockHeader="//////////////////////////////////////////////////////////////////////////" 
		let g:DoxygenToolkit_blockFooter="----------------------------------------------------------------------------" 
		let g:DoxygenToolkit_authorName="Reinaldo Molina" 
		let g:DoxygenToolkit_licenseTag=""
		" }}}

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

"/"Plugin 'scrooloose/syntastic' {{{
		set statusline+=%#warningmsg#
		set statusline+=%{SyntasticStatuslineFlag()}
		set statusline+=%*
		let g:syntastic_always_populate_loc_list = 1
		let g:syntastic_auto_loc_list = 1
		let g:syntastic_check_on_open = 0
		let g:syntastic_check_on_wq = 0
		"let g:syntastic_always_populate_loc_list = 1 " populates list of error so you can use lnext 
		" }}}
		
"/Plug 'octol/vim-cpp-enhanced-highlight' {{{
		let g:cpp_class_scope_highlight = 1	
		" turning this option breaks comments
		"let g:cpp_experimental_template_highlight = 1	
		" }}}
		
" Plugin 'morhetz/gruvbox' " colorscheme gruvbox  {{{
			colorscheme gruvbox
			set background=dark    " Setting dark mode
			" }}}

	" Plug 'vimwiki/vimwiki', {'branch': 'dev'} {{{
			" personal wiki configuraton. 
			" you can configure multiple wikis
			" see :h g:vimwiki_list
			" also look at vimwiki.vim vimwiki_defaults for all possible options
			"unmap <Leader>wt
			nmap <buffer> <Leader>wt :call <SID>WikiTable()<CR>
			let wiki = {}
			let wiki.path = s:personal_path . 'wiki'
			"let wiki.index = 'main'
			let wiki.auto_tags = 1
			let wiki.nested_syntaxes = {'python': 'python', 'c++': 'cpp'}
			let g:vimwiki_list = [wiki]

			let g:vimwiki_hl_cb_checked=1
			let g:vimwiki_menu=''
			let g:vimwiki_folding=''
			let g:vimwiki_table_mappings=0
			let g:vimwiki_use_calendar=0
			function! VimwikiLinkHandler(link)
				if match(a:link, ".cpp") != -1
					let l:neolink = strpart(a:link, 5)
					execute "e " . l:neolink
				endif
			endfunction
		" }}}
	" }}}
" }}}

