set nocompatible
" moved here otherwise conditional mappings get / instead ; as leader 
	let mapleader="\<Space>"
let maplocalleader="\<Space>"
if has('win32')
	source $VIMRUNTIME/mswin.vim
	behave mswin
	set ffs=dos

	" Quick write session with F2
	nnoremap <Leader>mz :mksession! C:\vim_sessions\
	" And load session with F3
	nnoremap <Leader>mx :source C:\vim_sessions\
	set viewdir=C:\vim_sessions\
	" configure tags - add additional tags here or comment out not-used ones
	set tags+=$HOME/vimfiles/tags/cpp
	set tags+=$HOME/vimfiles/tags/tags
	" sets path to cscope.exe 

	"au BufEnter *.c *.cpp *.h *.hpp call LoadWinCscope()"
	if has('gui_running')
		set guifont=consolas:h8
		set guioptions-=T  " no toolbar
		set guioptions-=m  " no menu bar
		set guioptions-=r  " no scroll bar
		nnoremap <S-CR> o<Esc>
	else
		set term=xterm
		set t_Co=256
		let &t_AB="\e[48;5;%dm"
		let &t_AF="\e[38;5;%dm"
		nnoremap <CR> o<Esc>
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


	"//////////////////Windows specific plugins options/////////////////////
	"Plugin 'ctrlpvim/ctrlp.vim' " quick file searchh"
		set wildignore+=*\\.git\\*,*\\.hg\\*,*\\.svn\\*  " Windows ('noshellslash')
		let g:ctrlp_custom_ignore = {
			\ 'dir':  '\v[\/]\.(git|hg|svn)$',
			\ 'file': '\v\.(exe|so|dll|dfm)$',
			\ 'link': 'SOME_BAD_SYMBOLIC_LINKS',
			\ }
		let g:ctrlp_user_command = ['.hg', 'for /f "tokens=1" %%a in (''hg root'') '
			\ . 'do hg --cwd %s status -numac -I . %%a']           " Windows

	" NeoComplete/NeoSnippets for Windows
		"let g:neosnippet#snippets_directory='~\vimfiles\plugged\vim-snippets'
		let g:neocomplete#data_directory = 'C:\vim_sessions' " let neocomplete
		"store its stuff


	" Call Vim-Plug Windows Specific Plugins should be from here below
	call plug#begin('~/vimfiles/plugged')
		Plug 'OmniSharp/omnisharp-vim'
" /////////// /////////// /////////// /////////// /////////// /////////// ////
elseif has('unix')
	set ffs=unix
	nnoremap <Leader>mz :mksession! /home/reinaldo/.vim/sessions/
	nnoremap <Leader>mx :source /home/reinaldo/.vim/sessions/
	noremap <Leader>mq <C-v>
	" making C-v paste stuff from system register
	" configure tags - add additional tags here or comment out not-used ones
	set tags+=~/.vim/tags/cpp
	set tags+=~/.vim/tags/tags
	set tags+=~/.vim/tags/copter
	if has('gui_running')
		set guioptions-=T  " no toolbar
		set guioptions-=m  " no menu bar
		set guioptions-=r  " no scroll bar
		set guifont=Monospace\ 9
		nnoremap <S-CR> o<Esc>
	else
		set t_Co=256
		" fixes nerdtree showing weird car issue
		"set encoding=utf-8
		" fixes issue colorscheme background not filling up entire screen in
		" command line
		set t_ut=
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

	" ///////////////VIM_VUNDLE_STUFF////////////////////////
	" set the runtime path to include Vundle and initialize
	if !has('nvim')
		call plug#begin('~/.vim/plugged')
	else
		call plug#begin('~/.config/nvim/autoupload/plug.vim')
	endif



	"Plugin 'ctrlpvim/ctrlp.vim' " quick file searchh"
		set wildignore+=*/.git/*,*/.hg/*,*/.svn/*        " Linux/MacOSX
		let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
		let g:ctrlp_user_command =
			\ ['.hg', 'hg --cwd %s status -numac -I . $(hg root)'] " MacOSX/Linux

	" Syntastic
		let g:syntastic_cpp_compiler_options = ' -std=c++11' 

endif

"/////////////////////STUFF_FOR_BOTH_SYSTEMS///////////////////////
"/////////////////////PLUGINS_FOR_BOTH_SYSTEMS///////////////////////
	Plug 'chrisbra/vim-diff-enhanced'
	Plug 'scrooloose/nerdtree'
	Plug 'scrooloose/nerdcommenter'
	Plug 'lervag/vimtex' " Latex support
	Plug 'bling/vim-airline'	" Status bar line
	Plug 'Vim-R-plugin'
	if has('nvim')
		Plug 'Shougo/deoplete.nvim'
	else
		Plug 'Shougo/neocomplete.vim'
		Plug 'tpope/vim-dispatch' " used for omnisharp completion 
	endif
	Plug 'Shougo/neosnippet'
	Plug 'Shougo/neosnippet-snippets'
	Plug 'honza/vim-snippets'
	Plug 'tpope/vim-surround'
	Plug 'junegunn/rainbow_parentheses.vim'
	Plug 'tpope/vim-surround'
	Plug 'morhetz/gruvbox' " colorscheme gruvbox 
	Plug 'mhinz/vim-janah' " colorscheme 
	Plug 'AlessandroYorba/Sierra' " colorscheme 
	Plug 'nathanaelkane/vim-indent-guides' 
	Plug 'mattn/emmet-vim' " HTML fast code
	Plug 'scrooloose/syntastic'
	Plug 'ctrlpvim/ctrlp.vim'
	Plug 'octol/vim-cpp-enhanced-highlight'
	Plug 'Tagbar'

	" All of your Plugins must be added before the following line
	call plug#end()            " required
"------------------ALL_AUTOGROUP_STUFF--------------------
" Enable omni completion.
augroup Filetypes
	autocmd!
	autocmd FileType cpp setlocal omnifunc=omni#cpp#complete#Main
	autocmd FileType cpp setlocal textwidth=80
	autocmd FileType cpp setlocal cindent
	autocmd FileType * IndentGuidesToggle
	autocmd FileType * RainbowParentheses
	autocmd FileType cs OmniSharpHighlightTypes
	autocmd FileType cs setlocal omnifunc=OmniSharp#Complete
	autocmd FileType nerdtree setlocal relativenumber
	autocmd FileType text call TextEnableCodeSnip('cpp', '@begin=cpp@', '@end=cpp@','SpecialComment')
	autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
	autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
	autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
	autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
	autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
augroup END

" automatically open and close the popup menu / preview window
au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
" automatic syntax for *.scp
autocmd BufNewFile,BufRead *.scp set syntax=asm
if has('unix')
	autocmd BufNewFile,BufReadPost *.ino,*.pde setlocal ft=arduino
endif
"-----------------------------------------------------------

" OmniCppComplete, Functions, and set settings
let OmniCpp_NamespaceSearch = 1
let OmniCpp_GlobalScopeSearch = 1
let OmniCpp_ShowAccess = 1
let OmniCpp_ShowPrototypeInAbbr = 1 " show function parameters
let OmniCpp_MayCompleteDot = 1 " autocomplete after .
let OmniCpp_MayCompleteArrow = 1 " autocomplete after ->
let OmniCpp_MayCompleteScope = 1 " autocomplete after ::
let OmniCpp_DefaultNamespaces = ["std", "_GLIBCXX_STD"]
" ////////////////////////////////////////////////////////
" //////////////////FUNCTIONS//////////////////////////////////////
function! SetCppOptions()
endfunction
" ////////////////////////////////////////////////////////
function! GetString(type)
	call inputsave()
	if a:type == "git"
		let g:search = input("Commit Comment:")
	elseif a:type == "search"
		let g:search = input("Search for:")
	endif
	call inputrestore()
endfunction
" ////////////////////////////////////////////////////////
" nobody using it because it breaks switching buffers
"let g:skipview_files = [
            "\ '[Quickfix List]',
            "\ '[]',
            "\ '[EXAMPLE PLUGIN BUFFER]'
            "\ ]
"function! MakeViewCheck()
    "if has('quickfix') && &buftype =~ 'quickfix'
        "" Buffer is quickfix dont save
        "return 0
    "endif
    "if has('quickfix') && &buftype =~ 'nofile'
        "" Buffer is marked as not a file
        "return 0
    "endif
    "if empty(glob(expand('%:p')))
        "" File does not exist on disk
        "return 0
    "endif
    "if len($TEMP) && expand('%:p:h') == $TEMP
        "" We're in a temp dir
        "return 0
    "endif
    "if len($TMP) && expand('%:p:h') == $TMP
        "" Also in temp dir
        "return 0
    "endif
    "if index(g:skipview_files, expand('%')) >= 0
        "" File is in skip list
        "return 0
    "endif
    "return 1
"endfunction
" ////////////////////////////////////////////////////////
"Function to enable different code snippets inside txt files
function! TextEnableCodeSnip(filetype,start,end,textSnipHl) abort
  let ft=toupper(a:filetype)
  let group='textGroup'.ft
  if exists('b:current_syntax')
    let s:current_syntax=b:current_syntax
    " Remove current syntax definition, as some syntax files (e.g. cpp.vim)
    " do nothing if b:current_syntax is defined.
    unlet b:current_syntax
  endif
  execute 'syntax include @'.group.' syntax/'.a:filetype.'.vim'
  try
    execute 'syntax include @'.group.' after/syntax/'.a:filetype.'.vim'
  catch
  endtry
  if exists('s:current_syntax')
    let b:current_syntax=s:current_syntax
  else
    unlet b:current_syntax
  endif
  execute 'syntax region textSnip'.ft.'
  \ matchgroup='.a:textSnipHl.'
  \ start="'.a:start.'" end="'.a:end.'"
  \ contains=@'.group
endfunction
"call TextEnableCodeSnip(  'c',   '@begin=c@',   '@end=c@', 'SpecialComment')
"call TextEnableCodeSnip('sql', '@begin=sql@', '@end=sql@', 'SpecialComment')
" ////////////////////////////////////////////////////////
function! SetCsOptions()
endfunction
" ////////////////////////////////////////////////////////
"////////////SET_OPTIONS///////////////////////////
filetype plugin on   
filetype indent on   
"set spell spelllang=en_us
"omnicomplete menu
set completeopt=menuone,menu,longest,preview
set nospell
set diffexpr=
" save marks 
set viminfo='1000,f1,<800,%1024
set cursorline
set showtabline=2 " always show tabs in gvim, but not vim"
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
set wildignore=*.o,*.obj,*.bak,*.exe,*.py[co],*.swp,*~,*.pyc,.svn,.git
set noundofile
set title                " change the terminal's title
set visualbell           " don't beep
set noerrorbells         " don't beep
set nobackup
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

	"if has('win32')
		"set csprg=C:\vim_sessions\cscope.exe
	"endif

	cnoreabbrev csa cs add
	cnoreabbrev csf cs find
	cnoreabbrev csk cs kill
	cnoreabbrev csr cs reset
	cnoreabbrev css cs show
	cnoreabbrev csh cs help

endif
set matchpairs+=<:>
set smartindent
set ignorecase
" ////////////////////////////////////////////////////////
		" Custom Mappings
syntax on
" on quickfix window go to line selected
noremap <Leader>qc :.cc<CR>
" on quickfix window go to line selected
noremap <Leader>qn :cn<CR>
" on quickfix window go to line selected
noremap <Leader>qf :cnf<CR>
" on quickfix close window
noremap <Leader>ql :ccl<CR>
" open quickfix window
noremap <Leader>qo :copen 20<CR>

"//////MISCELANEOUS MAPPINGS/////////////
" edit vimrc on a new tab
noremap <Leader>mv :tabedit $MYVIMRC<CR>
" source current document(usually used with vimrc) added airline
" replace auto sourcing of $MYVIMRC
noremap <Leader>ms :so %<CR>
"noremap <Leader>ms :so %<CR>:AirlineRefresh<CR>
 " used to save in command line something
"noremap <Leader>ma :w<CR>
nnoremap <A-s> :w<CR>
noremap <A-n> :noh<CR>
noremap <A-c> i<Space><Esc>
"noremap <Leader>mn :noh<CR>
" duplicate current char
nnoremap <Leader>mp ylp
vnoremap <Leader>mp ylp
noremap <Leader>mt :set relativenumber!<CR>
noremap <Leader>md :Dox<CR>
"//////////FOLDING//////////////
" Folding select text then S-f to fold or just S-f to toggle folding
nnoremap <Leader>ff za
onoremap <Leader>ff <C-C>za
vnoremap <Leader>ff zf
" next fold
vnoremap <Leader>fn zj
" previous fold
vnoremap <Leader>fp zk
" close all open folds
vnoremap <Leader>fo zM
" delete fold
vnoremap <Leader>fd zd
" delete all fold
vnoremap <Leader>fD zE
" opens all folds at cursor
vnoremap <Leader>fo zO
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
nnoremap <Leader><Space>p "0p
vnoremap <Leader><Space>p "0p
" move current line up
nnoremap <A-k> ddkk""p
" move current line down
noremap <A-j> dd""p
" Close all
noremap <Leader><Space>x :qall!<CR>
" open new to tab to explorer
noremap <Leader><Space>n :tab split<CR>
" previous cursor position
noremap <Leader>e <c-o>
" Switch back and forth between header file
nnoremap <Leader>moh :e %:p:s,.h$,.X123X,:s,.cpp$,.h,:s,.X123X$,.cpp,<CR>"
" ////////////////DIFF SUTFF///////////////
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
" ///////////////////////////////////////
"///////////SPELL_CHECK////////////////
" search forward
noremap <Leader>sn ]s
" search backwards
noremap <Leader>sp [s
" suggestion
noremap <Leader>sc z=
" toggle spelling
noremap <Leader>st :setlocal spell! spelllang=en_us<CR>
" add to dictionary
noremap <Leader>sa zg
" mark wrong
noremap <Leader>sw zw
" repeat last spell correction
noremap <Leader>sr :spellr<CR>
" SyntasticCheck toggle
noremap <Leader>so :SyntasticToggleMode<CR>
" Normal backspace functionalit y
nnoremap <Backspace> hxh<Esc> 
 " Substitute for ESC  
inoremap qq <Esc>
vnoremap qq <Esc>
noremap <S-q> yyp
"/////////////TAB_STUFF//////////////////////
noremap <S-j> :b#<CR>
noremap <Leader><Space>k gt
noremap <Leader><Space>j gT
noremap <Leader>bo :CtrlPBuffer<CR>
noremap <Leader>bd :bd %<CR>
" deletes all buffers
noremap <Leader>bD :bufdo bd<CR>
noremap <Leader>bs :buffers<CR>:buffer<Space>
noremap <Leader>bS :bufdo 
" move to the left tab
"noremap <S-j> gT
" move tab to the left
nnoremap <silent> <A-Left> :execute 'silent! tabmove ' . (tabpagenr()-2)<CR>
" move tab to the right
noremap <silent> <A-Right> :execute 'silent! tabmove ' . (tabpagenr()+1)<CR>
noremap <Leader>be :enew<CR>
noremap <S-x> :tabclose<CR>
" Uncomment below everytime you mapclear
" This will map 1-99gb. i.e: 12gb :12b<CR>
let c = 1
while c <= 99
  execute "nnoremap " . c . "gb :" . c . "b\<CR>"
  let c += 1
endwhile
"/////////////TAB_STUFF//////////////////////
" move to the beggning of line
noremap <S-w> $
" move to the end of line
noremap <S-b> ^
" jump to corresponding item<Leader> ending {,(, etc..
nnoremap <S-t> %
vnoremap <S-t> %
" insert tab spaces in normal mode
noremap <Tab> i<Tab><Esc>
" This is a very good to show and search all current but a much better is 
nnoremap gr :vimgrep <cword> %:p:h/*<CR> :copen 20<CR>
nnoremap gs :call GetString("search")<CR>:exe "vimgrep " . search . " %:p:h/*"<CR> :copen 20<CR>
" remaped search to f
noremap <S-s> #
vnoremap // y/<C-R>"<CR>
" Automatically insert date
nnoremap <F5> i///////////////<Esc>"=strftime("%c")<CR>Pa///////////////<Esc>
"//////////SCROLLING//////////////
noremap e 20k
vnoremap e 20k
noremap <S-e> 20j
vnoremap <S-e> 20j
" cd into current dir path and into dir above current path
nnoremap <Leader>cd :cd %:p:h<CR>
						\:pwd<CR>
nnoremap <Leader>cu :cd %:p:h<CR>
						\:cd ..<CR>
						\:pwd<CR>
"/////////////SEARCH_REPLACE//////////////////
noremap <Leader>w /\<<c-r>=expand("<cword>")<cr>\>
noremap <Leader>W :%s/\<<c-r>=expand("<cword>")<cr>\>/

" These are only for command line
" insert in the middle of whole word search
cnoremap <A-w> \<\><Left><Left>
" insert visual selection search
cnoremap <A-c> <c-r>=expand("<cword>")<cr>
cnoremap <A-s> %s/
"////////////////////////////////////////////////////////////////////////////////////////
" /////////////////PLUGIN_OPTIONS////////////////////////////////////////////
	"Plugin 'VundleVim/Vundle.vim'
		noremap <Leader>pl :PlugList<CR>
		" lists configured plugins
		noremap <Leader>pi :PlugInstall<CR>
		noremap <Leader>pu :PlugInstall!<CR>
		" installs plugins; append `!` to update or just :PluginUpdate
		noremap <Leader>ps :PlugSearch<CR>
		" searches for foo; append `!` to refresh local cache
		noremap <Leader>pc :PlugClean<CR>      
		" confirms removal of unused plugins; append `!` to auto-approve removal
		"
		" see :h vundle for more details or wiki for FAQ

" /////////////////PLUGIN_OPTIONS////////////////////////////////////////////
	"Plugin 'scrooloose/nerdcommenter'"
		let NERDUsePlaceHolders=0 " avoid commenter doing weird stuff
		let NERDCommentWholeLinesInVMode=2
		let NERDCreateDefaultMappings=0 " Eliminate default mappings
		let NERDRemoveAltComs=0 " Do not use alt comments /*
		let NERDMenuMode=0 " no menu
		let g:NERDCustomDelimiters = {
			\ 'vim': { 'left': '"', 'right': '' }}
			"\ 'vim': { 'left': '"', 'right': '' }
			"\ 'grondle': { 'left': '{{', 'right': '}}' }
		"\ }
		nmap - <plug>NERDCommenterToggle
		vmap - <plug>NERDCommenterToggle
		inoremap <C-c> <plug>NERDCommenterInsert
		nmap <Leader>ca <plug>NERDCommenterAppend
		nmap <Leader>cw <plug>NERDCommenterToEOL
	"Plugin 'scrooloose/NERDTree'
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
" ///////////////////////////////////////////////////////////////////
	"Plugin 'vc.vim' "version control plugin
	" TODO: fix this either bring it back or figure better way to do it
		" --------SVN----------
		" For all this commands you should be in the svn root folder
		" Add all files
		noremap <Leader>vA :!svn add * --force<CR>
		" Add specific files
		noremap <Leader>va :!svn add 
		" Commit using typed message
		noremap <Leader>vc :call GetString("git")<CR>
					\:exe "!svn commit -m \"" . search . "\" ."<CR>
		" Commit using File for commit content
		noremap <Leader>vC :!svn commit -F commit_msg .<CR>
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

		noremap <Leader>gp :silent !git add %<CR>
			\:call GetString("git")<CR>
			\:exe "silent !git commit -m \"" . search . "\""<CR>
			\:!git push origin master<CR> 
" ///////////////////////////////////////////////////////////////////
	"Plugin 'lervag/vimtex' " Latex support
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
" ///////////////////////////////////////////////////////////////////
	"Plugin 'bling/vim-airline' " Status bar line
		set laststatus=2
		let g:airline_section_b = '%{strftime("%c")}'
		let g:airline#extensions#bufferline#enabled = 1
		let g:airline#extensions#bufferline#overwrite_variables = 1
		" Bufferline
			let g:bufferline_rotate = 1
" ///////////////////////////////////////////////////////////////////
	"Plugin 'file:///home/reinaldo/.vim/bundle/vim-hardy'
		if has('unix')
			let g:hardy_arduino_path='/home/reinaldo/Downloads/arduino-1.6.5-r5/arduino'
		endif
" ///////////////////////////////////////////////////////////////////
	"Plugin 'Shougo/neocomplete.vim'
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
			" Close popup by <Space>.
			"inoremap <expr><Space> pumvisible() ? "\<C-y>" : "\<Space>"

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
			inoremap <expr><TAB>  pumvisible() ? "\<C-n>" :
					\ <SID>check_back_space() ? "\<TAB>" :
					\ neocomplete#start_manual_complete()
			  function! s:check_back_space() "{{{
				let col = col('.') - 1
				return !col || getline('.')[col - 1]  =~ '\s'
			  endfunction"}}}

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
		
" ///////////////////////////////////////////////////////////////////
	"Plugin 'Shougo/neocomplete-snippets.vim'
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
		" For conceal markers.
		if has('conceal')
			set conceallevel=2 concealcursor=niv
		endif

		let g:neosnippet#enable_snipmate_compatibility = 1

" ///////////////////////////////////////////////////////////////////
	"Plugin 'Vim-R-plugin'
		" http://cran.revolutionanalytics.com
		" Install R, Rtools 
		" git clone https://github.com/jalvesaq/VimCom.git // Do this in command to
		" download the library then in R do the bottom command by substituting path
		" with your path to where you downloaded vimcom
		" install.packages("<location>", type = "source", repos = NULL)
		" put this in your InstallationRdir/etc/Rprofile.site
							"options(vimcom.verbose = 1)
							"library(vimcom)
							
" ///////////////////////////////////////////////////////////////////
	"Plugin 'Tagbar'
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

" ///////////////////////////////////////////////////////////////////
	"Plugin 'ctrlpvim/ctrlp.vim' " quick file searchh
		noremap <Leader>ao :CtrlP<CR>
		noremap <S-k> :CtrlPBuffer<CR>
		noremap <A-v> :vs<CR>:CtrlPBuffer<CR>
		noremap <A-o> :CtrlPMixed<CR>
		noremap <Leader>at :tabnew<CR>:CtrlPMRU<CR>
		noremap <Leader>av :vs<CR>:CtrlPMRU<CR>
		noremap <Leader>as :sp<CR>:CtrlPMRU<CR>
		noremap <Leader>al :CtrlPClearCache<CR>
		let g:ctrlp_match_window = 'bottom,order:btt,min:1,max:10,results:10'

" ///////////////////////////////////////////////////////////////////
	"Plugin 'Newtr' VIM built in Explorer
		let g:netrw_sort_sequence='[\/]$,*,\.bak$,\.o$,\.h$,\.info$,\.swp$,\.obj$'
		let g:netrw_localcopydircmd	="copy /-y"

" ///////////////////////////////////////////////////////////////////
	"Plugin 'nathanaelkane/vim-indent-guides' 
		let g:indent_guides_enable_on_vim_startup = 1
		let g:indent_guides_auto_colors = 1
		let g:indent_guides_guide_size = 1
		let g:indent_guides_start_level = 3
		let g:indent_guides_faster = 1
		set lazyredraw " Had to addit to speed up scrolling 
		set ttyfast " Had to addit to speed up scrolling 
" ///////////////////////////////////////////////////////////////////
	"Plug 'junegunn/rainbow_parentheses.vim'
		let g:rainbow#max_level = 16
		let g:rainbow#pairs = [['(', ')'], ['[', ']'], ['{', '}']]

		" List of colors that you do not want. ANSI code or #RRGGBB
		let g:rainbow#blacklist = [233, 234]
" ///////////////////////////////////////////////////////////////////
	"Plugin 'mattn/emmet-vim' " HTML fast code"
		let g:user_emmet_settings = {
		\  'php' : {
		\    'extends' : 'html',
		\    'filters' : 'c',
		\  },
		\  'xml' : {
		\    'extends' : 'html',
		\  },
		\  'haml' : {
		\    'extends' : 'html',
		\  },
		\}
"//////////////////////////////////////////////////////////////////////////////////////////
"	Doxygen.vim
		let g:DoxygenToolkit_briefTag_pre="@Description:  " 
		let g:DoxygenToolkit_paramTag_pre="@Var: " 
		let g:DoxygenToolkit_returnTag="@Returns:   " 
		let g:DoxygenToolkit_blockHeader="//////////////////////////////////////////////////////////////////////////" 
		let g:DoxygenToolkit_blockFooter="----------------------------------------------------------------------------" 
		let g:DoxygenToolkit_authorName="Reinaldo Molina" 
		let g:DoxygenToolkit_licenseTag=""
"//////////////////////////////////////////////////////////////////////////////////////////
"	OmniSharp Stuff
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

"//////////////////////////////////////////////////////////////////////////////////////////
	""Plugin 'scrooloose/syntastic'
		set statusline+=%#warningmsg#
		set statusline+=%{SyntasticStatuslineFlag()}
		set statusline+=%*

		let g:syntastic_always_populate_loc_list = 1
		let g:syntastic_auto_loc_list = 1
		let g:syntastic_check_on_open = 0
		let g:syntastic_check_on_wq = 0
		"let g:syntastic_always_populate_loc_list = 1 " populates list of error so you can use lnext 
"//////////////////////////////////////////////////////////////////////////////////////////
	"Plug 'octol/vim-cpp-enhanced-highlight'
		let g:cpp_class_scope_highlight = 1	
		" turning this option breaks comments
		"let g:cpp_experimental_template_highlight = 1	
" //////////////////////////////////////////////////////////////////
		"Plugin 'morhetz/gruvbox' " colorscheme gruvbox 
			"colorscheme desert
			colorscheme gruvbox
			"colorscheme janah
			"colorscheme sierra
			set background=dark    " Setting dark mode
