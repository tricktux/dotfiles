set nocompatible
filetype off                  " required
" Change all mappings from <C- into <Leader>m except those of insert mode 
" command line change cursor in Insert mode
" fix paste and delete
if has('win32')
	" TODO: delete this and see results and install Console 2
	source $VIMRUNTIME/vimrc_example.vim
	source $VIMRUNTIME/mswin.vim
	behave mswin
	set ffs=dos

	"//////////////////Vundle Stuff for windows/////////////////////
	" set the runtime path to include Vundle and initialize
	set rtp+=$HOME/vimfiles/bundle/Vundle.vim/
	call vundle#begin('$HOME/vimfiles/bundle/')
	" alternatively, pass a path where Vundle should install plugins
	"call vundle#begin('~/some/path/here')

	" let Vundle manage Vundle, required
	Plugin 'VundleVim/Vundle.vim'
	Plugin 'chrisbra/vim-diff-enhanced'
	Plugin 'scrooloose/nerdtree'
	Plugin 'scrooloose/nerdcommenter'
	Plugin 'lervag/vimtex' " Latex support
	Plugin 'bling/vim-airline'	" Status bar line
	Plugin 'Vim-R-plugin'
	Plugin 'Shougo/neocomplete.vim'
	Plugin 'Tagbar'
	Plugin 'juneedahamed/vc.vim' " SVN, GIT, HG, and BZR repo support
	Plugin 'Raimondi/delimitMate' " AutoClose brackets, etc...
	"Plugin 'Shougo/unite.vim' " quick file searchh
	Plugin 'ctrlpvim/ctrlp.vim' " quick file searchh
		set wildignore+=*\\.git\\*,*\\.hg\\*,*\\.svn\\*  " Windows ('noshellslash')
		let g:ctrlp_custom_ignore = {
			\ 'dir':  '\v[\/]\.(git|hg|svn)$',
			\ 'file': '\v\.(exe|so|dll|dfm)$',
			\ 'link': 'SOME_BAD_SYMBOLIC_LINKS',
			\ }
		let g:ctrlp_user_command = ['.hg', 'for /f "tokens=1" %%a in (''hg root'') '
			\ . 'do hg --cwd %s status -numac -I . %%a']           " Windows
	Plugin 'oblitum/rainbow' " braces coloring
	Plugin 'morhetz/gruvbox' " colorscheme gruvbox 
	Plugin 'nathanaelkane/vim-indent-guides' 


	" All of your Plugins must be added before the following line
	call vundle#end()            " required
	" To ignore plugin indent changes, instead use:
	"filetype plugin on
	"
	" Brief help
	" Put your non-Plugin stuff after this line
	"///////////////////////////////////////////////////////////////////
	"//////////////////////Specific settings for Windows///////////////
	" Execute current R script in command line
	" Quick write session with F2
	nnoremap <Leader>mz :mksession! C:\vim_sessions\
	" And load session with F3
	nnoremap <Leader>mx :source C:\vim_sessions\
	" configure tags - add additional tags here or comment out not-used ones
	set tags+=$HOME/vimfiles/tags/cpp
	set tags+=$HOME/vimfiles/tags/tags
	" sets path to cscope.exe 

	"au BufEnter *.c *.cpp *.h *.hpp call LoadWinCscope()"
	if has('gui_running')
		set guifont=consolas:h8
		"colorscheme desert
		set guioptions-=T  " no toolbar
		nnoremap <S-CR> o<Esc>
	else
		set t_Co=256
		nnoremap <CR> o<Esc>
	endif

	" consistent in all systems
	noremap <Leader>mq <C-q>
	" for this to work you must be in the root directory of your code
	" doesnt work dont know why created script for this
	noremap <Leader>tu :!dir /b /s *.cpp *.h > cscope.files<CR> 
	\:!cscope -b -i cscope.files -f cscope.out<CR>
	\:cs kill -1<CR>:cs add cscope.out<CR>
	\:!ctags -R --sort=yes --c++-kinds=+pl --fields=+iaS --extra=+q .<CR>
	noremap <Leader>mr :!%<CR>

endif

if has('unix')
	set ffs=unix
	" Quick write session with F2
	nnoremap <Leader>mz :mksession! /home/reinaldo/.vim/sessions/
	" And load session with F3
	nnoremap <Leader>mx :source /home/reinaldo/.vim/sessions/
	" ///////////////VIM_VUNDLE_STUFF////////////////////////
	" set the runtime path to include Vundle and initialize
	set rtp+=~/.vim/bundle/Vundle.vim
	call vundle#begin()

	Plugin 'VundleVim/Vundle.vim'
	Plugin 'scrooloose/nerdcommenter'
	Plugin 'scrooloose/nerdtree'
	Plugin 'chrisbra/vim-diff-enhanced'
	"Plugin 'fugitive.vim' "git plugin
	Plugin 'lervag/vimtex' " Latex support
	Plugin 'taketwo/vim-ros'
	Plugin 'bling/vim-airline' " Status bar line
	Plugin 'file:///home/reinaldo/.vim/bundle/vim-hardy' "Arduino
	Plugin 'Shougo/neocomplete.vim'
	Plugin 'Vim-R-plugin'
	Plugin 'Tagbar'
	Plugin 'juneedahamed/vc.vim' " SVN, GIT, HG, and BZR repo support
	Plugin 'Raimondi/delimitMate' " AutoClose brackets, etc...
	"Plugin 'Shougo/unite.vim' " quick file searchh
	Plugin 'ctrlpvim/ctrlp.vim' " quick file searchh
		set wildignore+=*/.git/*,*/.hg/*,*/.svn/*        " Linux/MacOSX
		let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
		let g:ctrlp_user_command =
			\ ['.hg', 'hg --cwd %s status -numac -I . $(hg root)'] " MacOSX/Linux

	Plugin 'oblitum/rainbow' " braces coloring
	Plugin 'morhetz/gruvbox' " colorscheme gruvbox 
	Plugin 'nathanaelkane/vim-indent-guides' 
	Plugin 'mattn/emmet-vim' " HTML fast code
	" Track the engine.
	Plugin 'SirVer/ultisnips'  	" Track the engine.
		" Snippets are separated from the engine. Add this if you want them:
		Plugin 'honza/vim-snippets'

	"///////////////LH-CPP//////////////////"
	"Plugin 'LucHermitte/lh-vim-lib'"
	"Plugin 'LucHermitte/lh-tags'"
	"Plugin 'LucHermitte/lh-dev'"
	"Plugin 'LucHermitte/lh-brackets'"
	"Plugin 'LucHermitte/searchInRuntime'"
	"Plugin 'LucHermitte/mu-template'"
	"Plugin 'tomtom/stakeholders_vim'"
	"Plugin 'LucHermitte/lh-cpp'"
	"//////////////////////////////////////


	" All of your Plugins must be added before the following line
	call vundle#end()            " required
	" ////////////////////////////////////////////////////////
	"///////////////////Specific settings for Unix////////////////////////
	" This is to make it consistent with Windows making C-q be visual block mode now
	noremap <Leader>mq <C-v>
	" making C-v paste stuff from system register
	noremap ,v "+p
	autocmd BufNewFile,BufReadPost *.ino,*.pde setlocal ft=arduino
	"au BufEnter *.c *.cpp *.h *.hpp :call LinuxLoadCscope()<CR>"
	" configure tags - add additional tags here or comment out not-used ones
	set tags+=~/.vim/tags/cpp
	set tags+=~/.vim/tags/tags
	set tags+=~/.vim/tags/copter
	if has('gui_running')
		set guioptions-=T  " no toolbar
		set guifont=Monospace\ 9
		nnoremap <S-CR> o<Esc>
	else
		set t_Co=256
		nnoremap <CR> o<Esc>
	endif
	" Use a blinking upright bar cursor in Insert mode, a blinking block in normal
	"if &term == 'xterm' || &term == 'screen-256color'"
		"let &t_SI = "\<Esc>[5 q""
		"let &t_EI = "\<Esc>[1 q""
	"endif"

	"if exists('$TMUX')"
		"let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\""
		"let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\""
	"endif"

	" this one below DOES WORK in linux just make sure is ran at root folder
	noremap <Leader>tu :!find . -iname '*.c' -o -iname '*.cpp' -o -iname '*.h' -o -iname '*.hpp' > cscope.files<CR>
  	\:!cscope -b -i cscope.files -f cscope.out<CR>
	\:cs kill -1<CR>:cs add cscope.out<CR>
	\:!ctags -R --sort=yes --c++-kinds=+pl --fields=+iaS --extra=+q .<CR>
	nmap <Leader>mr :!./%<CR>

endif

"/////////////////////STUFF_FOR_BOTH_SYSTEMS///////////////////////
	" Omni complete stuff
	" build tags of your own project with Ctrl-F12

	" OmniCppComplete
	let OmniCpp_NamespaceSearch = 1
	let OmniCpp_GlobalScopeSearch = 1
	let OmniCpp_ShowAccess = 1
	let OmniCpp_ShowPrototypeInAbbr = 1 " show function parameters
	let OmniCpp_MayCompleteDot = 1 " autocomplete after .
	let OmniCpp_MayCompleteArrow = 1 " autocomplete after ->
	let OmniCpp_MayCompleteScope = 1 " autocomplete after ::
	let OmniCpp_DefaultNamespaces = ["std", "_GLIBCXX_STD"]
	" automatically open and close the popup menu / preview window
	au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
	set completeopt=menuone,menu,longest,preview
	" ////////////////////////////////////////////////////////
"/////////Stuff to show tab numbers at begginig///////////////////
" set up tab labels with tab number, buffer name, number of windows
function! GuiTabLabel()
	let label = ''
	let bufnrlist = tabpagebuflist(v:lnum)
	" Add '+' if one of the buffers in the tab page is modified
	for bufnr in bufnrlist
		if getbufvar(bufnr, "&modified")
		let label = '+'
		break
		endif
	endfor
	" Append the tab number
	let label .= v:lnum.': '
	" Append the buffer name
	let name = bufname(bufnrlist[tabpagewinnr(v:lnum) - 1])
	if name == ''
		" give a name to no-name documents
		if &buftype=='quickfix'
		let name = '[Quickfix List]'
		else
		let name = '[No Name]'
		endif
	else
		" get only the file name
		let name = fnamemodify(name,":t")
	endif
	let label .= name
	" Append the number of windows in the tab page
	let wincount = tabpagewinnr(v:lnum, '$')
	return label . '  [' . wincount . ']'
endfunction
set guitablabel=%{GuiTabLabel()}
"////////////////////////////////////////////////////////
"///////////////////FUNCTION_FOR_DIFF///////////////////
set diffexpr=
"MyDiff()
function! MyDiff()
   let opt = '-a --binary '
   if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
   if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
   let arg1 = v:fname_in
   if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
   let arg2 = v:fname_new
   if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
   let arg3 = v:fname_out
   if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
   if $VIMRUNTIME =~ ' '
     if &sh =~ '\<cmd'
       if empty(&shellxquote)
         let l:shxq_sav = ''
         set shellxquote&
       endif
       let cmd = '"' . $VIMRUNTIME . '\diff"'
     else
       let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
     endif
   else
     let cmd = $VIMRUNTIME . '\diff'
   endif
   silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3
   if exists('l:shxq_sav')
     let &shellxquote=l:shxq_sav
   endif
 endfunction
"////////////////////////////////////////////////////////
function! LinuxLoadCscope()
  let db = findfile("cscope.out", ".;")
  if (!empty(db))
    let path = strpart(db, 0, match(db, "/cscope.out$"))
    set nocscopeverbose " suppress 'duplicate connection' error
    exe "cs add " . db . " " . path
    set cscopeverbose
  endif
endfunction
function! WinLoadCscope()
	if (executable("cscope") && has("cscope"))
		let UpperPath = findfile("cscope.out", ".;")
		if (!empty(UpperPath))
			let path = strpart(UpperPath, 0, match(UpperPath, "cscope.out$") - 1)	
			if (!empty(path))
				let s:CurrentDir = getcwd()
				let direct = strpart(s:CurrentDir, 0, 2) 
				let s:FullPath = direct . path
				let s:AFullPath = globpath(s:FullPath, "cscope.out")
				let s:CscopeAddString = "cs add " . s:AFullPath . " " . s:FullPath 
				execute s:CscopeAddString 
			endif
		endif
	endif
endfunction
"////////////SET_OPTIONS///////////////////////////
filetype plugin on   
filetype indent on   

let mapleader=";"
let maplocalleader=";"
"set spell spelllang=en_us
set nospell
" save marks 
set viminfo='1000,f1
set cursorline
set showtabline=2 " always show tabs in gvim, but not vim
set tabstop=4     " a tab is four spaces
set backspace=indent,eol,start
                    " allow backspacing over everything in insert mode
set autoindent    " always set autoindenting on
set copyindent    " copy the previous indentation on autoindenting
set number        " always show line numbers
set shiftwidth=4  " number of spaces to use for autoindenting
set shiftround    " use multiple of shiftwidth when indenting with '<' and '>'
set showmatch     " set show matching parenthesis
set ignorecase    " ignore case when searching
set smartcase     " ignore case if search pattern is all lowercase,
                    "    case-sensitive otherwise
set smarttab      " insert tabs on the start of a line according to
                    "    shiftwidth, not tabstop
set hlsearch      " highlight search terms
set incsearch     " show search matches as you type
set history=1000         " remember more commands and search history
set undolevels=1000      " use many muchos levels of undo
set wildignore=*.swp,*.bak,*.pyc,*.class
set noundofile
set title                " change the terminal's title
set visualbell           " don't beep
set noerrorbells         " don't beep
set nobackup
set noswapfile
set autochdir " working directory is always the same as the file you are editing
" automatic syntax for *.scp
autocmd! BufNewFile,BufRead *.scp set syntax=asm
syntax on
" on quickfix window go to line selected
noremap <Leader>qg :.cc<CR>
" on quickfix close window
noremap <Leader>ql :ccl<CR>
" open quickfix window
noremap <Leader>qo :copen 20<CR>

"//////MISCELANEOUS MAPPINGS/////////////
" edit vimrc on a new tab
noremap <Leader>mv :tabedit $MYVIMRC<CR>
" source current document(usually used with vimrc)
noremap <Leader>ms :so %<CR>
noremap <Leader>ma :w<CR> " used to save in command line 
noremap <Leader>mn :noh<CR>
" duplicate current char
nnoremap <Leader>mp ylp
" open explorer on current tab
"lnoremap <Leader>op :e.<CR>
" move to upper window
noremap ,h <C-w>h
noremap ,J <C-w>j
noremap ,K <C-w>k
noremap ,l <C-w>l
" Switch back and forth between header file
nnoremap <Leader>moh :e %:p:s,.h$,.X123X,:s,.cpp$,.h,:s,.X123X$,.cpp,<CR>"
" Run current script

" ////////////////DIFF SUTFF///////////////
" diff left and right window
noremap <Leader>do :windo diffthis<CR>
" diff go to next diff
noremap <Leader>dn ]c
" diff go to previous diff
noremap <Leader>dp [c
" diff get from the other window
noremap <Leader>dg :diffget<CR>
" diff put difference onto other window
noremap <Leader>du :diffput<CR>
" close diff
noremap <Leader>dl :diffoff!<CR> ZZ
" off highlited search
" ///////////////////////////////////////

"///////////SPELL_CHECK////////////////
" search forward
nmap <Leader>sf ]s
" search backwards
nmap <Leader>sb [s
" suggestion
nmap <Leader>sc z=
" toggle spelling
nmap <Leader>st :setlocal spell! spelllang=en_us<CR>
" add to dictionary
nmap <Leader>sa zg
" mark wrong
nmap <Leader>sw zw
" repeat last spell correction
nmap <Leader>sr :spellr<CR>

" Insert empty line below
" Substitute for ESC   
nnoremap <Space> i <Esc> 
" Normal backspace functionalit y
nnoremap <Backspace> hxh<Esc> 
 " Substitute for ESC  
imap qq <Esc>
 " Substitute for ESC  
vmap qq <Esc>
" save all buffer s
"map <C-s> :w<CR>"
" not paste the deleted word
map ,p "0p
" move current line up
nnoremap ,k ddkk""p
" move current line down
noremap ,j dd""p
" duplicate current line down
map <S-q> yyp

"/////////////TAB_STUFF//////////////////////
" move to the right tab
noremap <S-k> gt
" move to the left tab
noremap <S-j> gT
" move tab to the left
nnoremap <silent> <A-Left> :execute 'silent! tabmove ' . (tabpagenr()-2)<CR>
" move tab to the right
noremap <silent> <A-Right> :execute 'silent! tabmove ' . (tabpagenr()+1)<CR>
nmap <S-t> :Te<CR>
" dupplicate current tab
" bring line down up
"noremap  <C-J> <S-j>
" move to the beggning of line
noremap <S-w> $
" move to the end of line
noremap <S-b> ^
" jump to corresponding item<Leader> ending {,(, etc..
nnoremap t %
vnoremap t %
" Close all
nmap ,x :qall!<CR>
" open new to tab to explorer
nmap ,n :tab split<CR>
" insert tab spaces in normal mode
noremap <Tab> i<Tab><Esc>
noremap <S-x> :tabclose<CR>

" This is a very good to show and search all current but a much better is 
" to download vim-easygrep its a lot better 
nnoremap gr :vimgrep <cword> %:p:h/*<CR> :copen 20<CR>
" nnoremap gr :vimgrep <cword>/".input("Replace with: ")" %:p:h/*<CR> :copen 20<CR>
" remaped search to f
noremap f #
" remaped delete to use it for scrolling
"noremap ,d d"
	
"//////////FOLDING//////////////
" Folding select text then S-f to fold or just S-f to toggle folding
" Inoremap <S-f> <C-O>za interferes when input mode is on
nnoremap <S-f> za
onoremap <S-f> <C-C>za
vnoremap <S-f> zf
" Save folding
if has('unix')
	autocmd BufWinLeave ?* mkview
	autocmd BufWinEnter ?* silent loadview
endif
" Automatically insert date
nnoremap <F5> "=strftime("%c")<CR>P
inoremap <F5> <C-R>=strftime("%c")<CR>
"//////////SCROLLING//////////////
"noremap e <C-y><C-y><C-y><C-y><C-y><C-y><C-y><C-y><C-y><C-y><C-y><C-y><C-y><C-y><C-y><C-Y>26k"
"noremap <Leader>e 26k"
noremap e 26k
"noremap d <C-e><C-e><C-e><C-e><C-e><C-e><C-e><C-e><C-e><C-e><C-e><C-e><C-e><C-e><C-e><C-e>26j"
noremap s 26j
" Search for highlighted word
vnoremap // y/<C-R>"<CR>
inoremap <C-k> ->
set nowrap        " wrap lines
" will look in current directory for tags
" THE BEST FEATURE I'VE ENCOUNTERED SO FAR OF VIM
" CAN BELIEVE I DIDNT DO THIS BEFORE
set tags+=.\tags;\

if has('cscope')
	set cscopetag cscopeverbose

	if has('quickfix')
		set cscopequickfix=s+,c+,d+,i+,t+,e+
	endif

	if has('win32')
		set csprg=C:\vim_sessions\cscope.exe
	endif

	cnoreabbrev csa cs add
	cnoreabbrev csf cs find
	cnoreabbrev csk cs kill
	cnoreabbrev csr cs reset
	cnoreabbrev css cs show
	cnoreabbrev csh cs help

	if &filetype=="cpp" || &filetype=="c"|| &filetype=="hpp"|| &filetype=="h"
		if filereadable("cscope.out")
				cs add cscope.out
				" else add database pointed to by environment
		elseif $CSCOPE_DB != ""
			cs kill -1 " in case was loaded before
			cs add $CSCOPE_DB
		endif
	endif

	"command -nargs=0 Cscope cs add $VIMSRC/src/cscope.out $VIMSRC/src
endif"


" /////////////////PLUGIN_OPTIONS////////////////////////////////////////////
	"Plugin 'VundleVim/Vundle.vim'
		noremap <Leader>pl :PluginList<CR>
		" lists configured plugins
		noremap <Leader>pi :PluginInstall<CR>
		" installs plugins; append `!` to update or just :PluginUpdate
		noremap <Leader>ps :PluginSearch<CR>
		" searches for foo; append `!` to refresh local cache
		noremap <Leader>pc :PluginClean<CR>      
		" confirms removal of unused plugins; append `!` to auto-approve removal
		"
		" see :h vundle for more details or wiki for FAQ

" /////////////////PLUGIN_OPTIONS////////////////////////////////////////////
	"Plugin 'scrooloose/nerdcommenter'
		let NERDCommentWholeLinesInVMode=2
		let NERDCreateDefaultMappings=0 " Eliminate default mappings
		let NERDRemoveAltComs=0 " Do not use alt comments /*
		let NERDMenuMode=0 " no menu
		let g:NERDCustomDelimiters = {
			\ 'vim': { 'left': '"', 'right': '"' }}
			"\ 'vim': { 'left': '"', 'right': '' }
			"\ 'grondle': { 'left': '{{', 'right': '}}' }
		"\ }
		nmap - <plug>NERDCommenterToggle
		vmap - <plug>NERDCommenterToggle
		imap <C-c> <plug>NERDCommenterInsert
		nmap <Leader>ca <plug>NERDCommenterAppend
		nmap <Leader>cy <plug>NERDCommenterYank
		nmap <Leader>cw <plug>NERDCommenterToEOL
	"Plugin 'scrooloose/NERDTree'
		nmap <Leader>nb :Bookmark 
		let NERDTreeShowBookmarks=1  " B key to toggle
		nmap <Leader>no :NERDTree<CR>
		let NERDTreeShowHidden=1 " i key to toggle
		let NERDTreeMapJumpLastChild=',j' 
		let NERDTreeMapJumpFirstChild=',k' 
		let NERDTreeMapOpenExpl=',e' 
        let NERDTreeQuitOnOpen=1 " AutoClose after openning file
" ///////////////////////////////////////////////////////////////////
	"Plugin 'vc.vim' "version control plugin
		noremap <Leader>va :VCAdd<CR>
		noremap <Leader>vc :VCCommit<CR> 
		noremap <Leader>vp :VCPush<CR> 
		noremap <Leader>ga :!git add %<CR>
		noremap <Leader>gc :!git commit -m "
		noremap <Leader>gp :!git push origin master<CR> 
		"typical order also depends where you are pushing
		noremap <Leader>vd :VCDiff<CR> 
		noremap <Leader>vl :VCLog<Space>
" ///////////////////////////////////////////////////////////////////
	"Plugin 'lervag/vimtex' " Latex support
		let g:vimtex_view_enabled = 0

		" latexmk
		let g:vimtex_latexmk_continuous=1
		let g:vimtex_latexmk_callback=1
		" neocomplete stuff of vimtex
		if !exists('g:neocomplete#sources#omni#input_patterns')
			let g:neocomplete#sources#omni#input_patterns = {}
		endif
		let g:neocomplete#sources#omni#input_patterns.tex =
				\ '\v\\%('
				\ . '\a*%(ref|cite)\a*%(\s*\[[^]]*\])?\s*\{[^{}]*'
				\ . '|includegraphics%(\s*\[[^]]*\])?\s*\{[^{}]*'
				\ . '|%(include|input)\s*\{[^{}]*'
				\ . ')'
		" AutoComplete 
		let g:vimtex_complete_close_braces=1
		let g:vimtex_complete_recursive_bib=1
		let g:vimtex_complete_img_use_tail=1

		" ToC
		let g:vimtex_toc_enabled=1
		let g:vimtex_index_show_help=1
" ///////////////////////////////////////////////////////////////////
	"Plugin 'xuhdev/vim-latex-live-preview'
		"autocmd Filetype tex setl updatetime=1000
		"let g:livepreview_previewer = 'okular'
		" LLPStartPreview
" ///////////////////////////////////////////////////////////////////
	"Plugin 'bling/vim-airline' " Status bar line
		set laststatus=2
" ///////////////////////////////////////////////////////////////////
	"Plugin 'file:///home/reinaldo/.vim/bundle/vim-hardy'
		if has('unix')
			let g:hardy_arduino_path='/home/reinaldo/Downloads/arduino-1.6.5-r5/arduino'
		endif
" ///////////////////////////////////////////////////////////////////
	"Plugin 'Valloric/YouCompleteMe'  "Smart autocomplete
	" Installation instructions:
	"	run ~/Google Drive/scripts/install_software/vim_ycm.sh
	"let g:ycm_global_ycm_extra_conf = '~/.ycm_extra_conf.py'

	" potential plugins
	"Plugin 'scrooloose/syntastic'
	"Plugin 'vim-scripts/UltiSnips'
" ///////////////////////////////////////////////////////////////////
	"Plugin 'Shougo/neocomplete.vim'
		"Note: This option must set it in .vimrc(_vimrc).  NOT IN .gvimrc(_gvimrc)!
		" Disable AutoComplPop.
		let g:acp_enableAtStartup = 0
		" Use neocomplete.
		let g:neocomplete#enable_at_startup = 1
		" Use smartcase.
		let g:neocomplete#enable_smart_case = 1
		" Set minimum syntax keyword length.
		let g:neocomplete#sources#syntax#min_keyword_length = 3
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
		inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
		" <C-h>, <BS>: close popup and delete backword char.
		inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
		inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
		" Close popup by <Space>.
		"inoremap <expr><Space> pumvisible() ? "\<C-y>" : "\<Space>"

		" AutoComplPop like behavior.
		"let g:neocomplete#enable_auto_select = 1

		" Shell like behavior(not recommended).
		"set completeopt+=longest
		"let g:neocomplete#enable_auto_select = 1
		"let g:neocomplete#disable_auto_complete = 1
		"inoremap <expr><TAB>  pumvisible() ? "\<Down>" : "\<C-x>\<C-u>"

		" Enable omni completion.
		autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
		autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
		autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
		autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
		autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
		autocmd FileType cpp setlocal omnifunc=omni#cpp#complete#Main

		" Enable heavy omni completion.
		if !exists('g:neocomplete#sources#omni#input_patterns')
			let g:neocomplete#sources#omni#input_patterns = {}
		endif
		"let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
		"let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
		"let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

		" For perlomni.vim setting.
		" https://github.com/c9s/perlomni.vim
		let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'

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
		nmap <Leader>tt :TagbarToggle<CR>
		nmap <Leader>tj <C-]>
		nmap <Leader>tr <C-t>
		nmap <Leader>tn :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
		" ReLoad cscope database
		if has('unix')
			noremap <Leader>tl :call LinuxLoadCscope()<CR>
		else
			noremap <Leader>tl :call WinLoadCscope()<CR>
		endif
		" Find functions calling this function
		nmap <Leader>tc :cs find c <C-R>=expand("<cword>")<CR><CR>
		" Find functions called by this function
		nmap <Leader>td :cs find d <C-R>=expand("<cword>")<CR><CR>
		nmap <Leader>ts :cs show<CR>

" ///////////////////////////////////////////////////////////////////
	"Plugin 'ctrlpvim/ctrlp.vim' " quick file searchh
		nmap <Leader>ao :CtrlP<CR>
		nmap <Leader>am :CtrlPMRU<CR>
		let g:ctrlp_match_window = 'bottom,order:btt,min:1,max:10,results:10'

" ///////////////////////////////////////////////////////////////////
	"Plugin 'Newtr' VIM built in Explorer
		let g:netrw_sort_sequence='[\/]$,*,\.bak$,\.o$,\.h$,\.info$,\.swp$,\.obj$'
		let g:netrw_localcopydircmd	="copy /-y"

" ///////////////////////////////////////////////////////////////////
	"Plugin 'oblitum/rainbow' " braces coloring
		let g:rainbow_active = 1

		"let g:rainbow_load_separately = [
			"\ [ '*' , [['(', ')'], ['\[', '\]'], ['{', '}']] ],
			"\ [ '*.tex' , [['(', ')'], ['\[', '\]']] ],
			"\ [ '*.cpp' , [['(', ')'], ['\[', '\]'], ['{', '}']] ],
			"\ [ '*.{html,htm}' , [['(', ')'], ['\[', '\]'], ['{', '}'], ['<\a[^>]*>', '</[^>]*>']] ],
			"\ ]

		"let g:rainbow_guifgs = ['RoyalBlue3', 'DarkOrange3', 'DarkOrchid3', 'FireBrick']
		"let g:rainbow_ctermfgs = ['lightblue', 'lightgreen', 'lightyellow', 'red', 'magenta']

" ///////////////////////////////////////////////////////////////////
	"Plugin 'Yggdroot/indentLine' " shows line indents
		let g:indentLine_enabled = 1

" ///////////////////////////////////////////////////////////////////
	"Plugin 'nathanaelkane/vim-indent-guides' 
		let g:indent_guides_auto_colors = 1
		let g:indent_guides_guide_size = 1
		let g:indent_guides_start_level = 3
		let g:indent_guides_faster = 1
		set lazyredraw " Had to addit to speed up scrolling 
		set ttyfast " Had to addit to speed up scrolling 
		"autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=red   ctermbg=3
		"autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=green ctermbg=4"
" ///////////////////////////////////////////////////////////////////
		"Plugin 'morhetz/gruvbox' " colorscheme gruvbox 
			colorscheme gruvbox
			set background=dark    " Setting dark mode
" ///////////////////////////////////////////////////////////////////
	"Plugin 'SirVer/ultisnips'  	" Track the engine.
	" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
		let g:UltiSnipsExpandTrigger="<nop>"
		let g:UltiSnipsJumpForwardTrigger="<c-b>"
		let g:UltiSnipsJumpBackwardTrigger="<c-z>"
		" makes possible the use of CR to enter snippet 
		let g:ulti_expand_or_jump_res = 0
		function! ExpandSnippetOrCarriageReturn()
			let snippet = UltiSnips#ExpandSnippetOrJump()
			if g:ulti_expand_or_jump_res > 0
				return snippet
			else
				return "\<CR>"
			endif
		endfunction
		inoremap <expr> <CR> pumvisible() ? "<C-R>=ExpandSnippetOrCarriageReturn()<CR>" : "\<CR>"
		""""""""""""""""""""""""""""""""""""""""""""""""""
		" If you want :UltiSnipsEdit to split your window.
		"let g:UltiSnipsEditSplit="vertical""
"//////////////////////////////////////////////////////////////////////////////////////////
	"Plugin 'mattn/emmet-vim' [> HTML fast code"
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
	" Deleted plugins
	"Plugin 'justmao945/vim-clang'
"/////////////////////////////////MISC NOTES/////////////////////////////////////////////
"useful command to convert all , into new lines
	":%s,/\r/g  
" to umap something simply type it in the command :unmap ii for example
" :w xxx - save as xxx keep working on original
" :sav xxx -save as xxx switch to new file
" H - jump cursor to begging of screen
" M - jump cursor to middle of screen
" L - jump cursor to end of screen
" vib - visual mode select all inside ()
" cib - even better
" ci" - inner quotes
" ci< - inner <>
" :nmap shows all your normal mode mappings
" :vmap shows all your visual mode mappings
" :imap shows all your insert mode mappings
" :map shows all mappings
" :mapclear Clears all mappings then do :so % 
" <C-q> in windows Visual Block mode
" <C-v> in linux Visual Block mode
" A insert at end of line
" To read output of a command use:
"   	:read !<command>
" Create vim log run vim with command:
"	vim -V9myVimLog
" When using <plug> do a :nmap and make sure your option is listed, usually at the end
" Search for INdENTGUIDES to join braces with \
" LUA Installation in windows:
" 	download latest vim from DOWNLOAD VIM in bookmarks
" 	Donwload lua windows binaries from the website for the architecture you
" 	have
" 	Put lua in your path and also lua52.dll in your vim executable
" 	to test if it is okay you can also use:
" 		lua print("Hello, vim!")
" 		this will tell you the error you are getting
" 		last time wih only the lua53.dll fixed it
" Instructions to installing GVim on windows
" 	- copy your vim Installation folder 
" 	- install git
" 	- copy the curl.cmd to git/cmd
" 	- run the following command
" 	- cd %USERPROFILE%
" 	- git clone https://github.com/gmark/Vundle.vim.git
" 	%USERPROFILE%/vimfiles/bundle/Vundle.vim
" 	- set up your git
" 		git config --global user.name "Reinaldo Molina"
"		git config --global user.email rmolin88@gmail.com
"		git config --global core.editor gvim 
"   	git config credential.helper 'cache --timeout=3600'		#not working				 
"		*make sure you have internet
"		git init
"		git add remote origin https://github.com/rmolin88/vimrc.git
"		this downloads your _vimrc
" 	- add ctags folder to path
" 	- the latest vim folder should have the lua53.dll already inside
" 	- Cscope:
" 		- To create database:
" 			- Win: 
" 			add cscope.exe and sort.exe to PATH
" 			do this command on root folder of files
	" 			dir /b /s *.cpp *.h > cscope.files
	" 			cscope -b
" 			This will create the cscope.out
" 			then in vim cs add <PATH to cscope.out>
"			- Linux:
"			download latest
"			./configure
"			make
"			sudo make install
" Installin vim in unix:
"	- Download vim_source_install.sh from drive
"	- run. done
"
" --------------------------

	
