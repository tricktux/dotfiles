set nocompatible
filetype off                  " required
if has('win32')
	source $VIMRUNTIME/vimrc_example.vim
	source $VIMRUNTIME/mswin.vim
	behave mswin
	set ffs=dos
	if has('gui_running')
		set guifont=consolas:h8
		colorscheme desert
		set guioptions-=T  " no toolbar
	endif
	" Quick write session with F2
	map <F2> :mksession! C:\Program Files (x86)\Vim\vimfiles\sessions\
	" And load session with F3
	map <F3> :source C:\Program Files (x86)\Vim\vimfiles\sessions\

	"//////////////////Vundle Stuff for windows/////////////////////

	" set the runtime path to include Vundle and initialize
	set rtp+=$HOME/vimfiles/bundle/Vundle.vim/
	call vundle#begin('$HOME/vimfiles/bundle/')
	" alternatively, pass a path where Vundle should install plugins
	"call vundle#begin('~/some/path/here')

	" let Vundle manage Vundle, required
	Plugin 'VundleVim/Vundle.vim'
	Plugin 'chrisbra/vim-diff-enhanced'
	Plugin 'LaTeX-Suite-aka-Vim-LaTeX'
	Plugin 'fugitive.vim'

	" Status bar line
	Plugin 'bling/vim-airline'
	set laststatus=2

	" All of your Plugins must be added before the following line
	call vundle#end()            " required
	" To ignore plugin indent changes, instead use:
	"filetype plugin on
	"
	" Brief help
	" :PluginList       - lists configured plugins
	" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
	" :PluginSearch foo - searches for foo; append `!` to refresh local cache
	" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
	"
	" see :h vundle for more details or wiki for FAQ
	" Put your non-Plugin stuff after this line
	"///////////////////////////////////////////////////////////////////
	"//////////////////////Specific settings for Windows///////////////
	set nowrap        " don't wrap lines

endif

if has('unix')
	if has('gui_running')
		set guioptions-=T  " no toolbar
		set guifont=Monospace\ 9
		colorscheme desert
	endif
	set ffs=unix
	" Quick write session with F2
	map <F2> :mksession! /home/reinaldo/.vim/sessions/
	" And load session with F3
	map <F3> :source /home/reinaldo/.vim/sessions/
	" ///////////////VIM_VUNDLE_STUFF////////////////////////
	" set the runtime path to include Vundle and initialize
	set rtp+=~/.vim/bundle/Vundle.vim
	call vundle#begin()

	Plugin 'VundleVim/Vundle.vim'

	Plugin 'file:///home/reinaldo/.vim/bundle/vim-hardy'
	let g:hardy_arduino_path='/home/reinaldo/Downloads/arduino-1.6.5-r5/arduino'
	"Plugin '4Evergreen4/vim-hardy'
	
	"Smart autocomplete
	"Plugin 'Valloric/YouCompleteMe'
	" Installation instructions:
	"	run ~/Google Drive/scripts/install_software/vim_ycm.sh
	"let g:ycm_global_ycm_extra_conf = '~/.ycm_extra_conf.py'Plugin 'justmao945/vim-clang'Plugin 'justmao945/vim-clang'

	"Another trial at autocomplete
	" Track the engine.
	Plugin 'SirVer/ultisnips'

	" Snippets are separated from the engine. Add this if you want them:
	Plugin 'honza/vim-snippets'

	" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
	let g:UltiSnipsExpandTrigger="<tab>"
	let g:UltiSnipsJumpForwardTrigger="<c-b>"
	let g:UltiSnipsJumpBackwardTrigger="<c-z>"

	" If you want :UltiSnipsEdit to split your window.
	let g:UltiSnipsEditSplit="vertical"

	Plugin 'scrooloose/nerdcommenter'
	Plugin 'chrisbra/vim-diff-enhanced'
	"git plugin
	Plugin 'fugitive.vim'
	Plugin 'justmao945/vim-clang'

	" Status bar line
	Plugin 'bling/vim-airline'
	set laststatus=2

	" potential plugins
	"Plugin 'scrooloose/syntastic'
	"Plugin 'vim-scripts/UltiSnips'
	"Plugin 'taketwo/vim-ros'

	" All of your Plugins must be added before the following line
	call vundle#end()            " required
	" ////////////////////////////////////////////////////////
	"///////////////////Specific settings for Unix////////////////////////
	" This is to make it consistent with Windows making C-q be visual block mode now
	noremap <C-q> <C-v>
	" making C-v paste stuff from system register
	noremap <C-v> "+p
	set wrap        " wrap lines
	autocmd BufNewFile,BufReadPost *.ino,*.pde setlocal ft=arduino
	" Omni complete stuff
	au BufNewFile,BufRead,BufEnter *.cpp,*.hpp set omnifunc=omni#cpp#complete#Main
	" configure tags - add additional tags here or comment out not-used ones
	set tags+=~/.vim/tags/cpp
	set tags+=~/.vim/tags/tags
	" build tags of your own project with Ctrl-F12
	map <C-F12> :!ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q .<CR>

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


endif

"/////////////////////STUFF_FOR_BOTH_SYSTEMS///////////////////////

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
set diffexpr=MyDiff()
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

"////////////SET_OPTIONS///////////////////////////
let mapleader=","
" save marks 
set viminfo='1000,f1
filetype plugin indent on   
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
set title                " change the terminal's title
set visualbell           " don't beep
set noerrorbells         " don't beep
set nobackup
set noswapfile
set autochdir " working directory is always the same as the file you are editing
" automatic syntax for *.scp
autocmd! BufNewFile,BufRead *.scp set syntax=asm
syntax on
"////////////////////////////////////////////////////////
" comment line uses plug in
noremap - <Leader>ci
" on quickfix window go to line selected
noremap <Leader>c :.cc<CR>
" on quickfix close window
noremap <Leader>cl :ccl<CR>
" open quickfix window
noremap <Leader>co :copen 20<CR>
" edit vimrc on a new tab
noremap <Leader>v :tabedit $MYVIMRC<CR>
" source current document(usually used with vimrc)
noremap <Leader>s :so %<CR>
" diff left and right window
noremap <Leader>d :windo diffthis<CR>
" close diff
noremap <Leader>dl :diffoff!<CR> ZZ
" off highlited search
noremap <Leader>n :noh<CR>
" duplicate current char
nnoremap <Leader>p ylp
" open explorer on current tab
noremap <Leader>op :e.<CR>
" move to upper window
noremap <Leader>o <C-w>k
"/////////////GIT_PLUGIN/////////////////////
noremap <Leader>gw :Gwrite<CR> 
noremap <Leader>gr :Gremove<CR> 
noremap <Leader>gc :Gcommit<CR> 
noremap <Leader>gp :!git push origin master<CR> 
"typical order also depends where you are pushing
noremap <Leader>gd :Gdiff<CR> 
noremap <Leader>gb :Git branch<Space>
"///////////////////////////////////////////

" Insert empty line below
nnoremap <S-CR> o<Esc>
" Substitue for ESC   
nnoremap <Space> i <Esc> 
" Normal backspace functionalit y
nnoremap <Backspace> hxh<Esc> 
 " Substitue for ESC  
imap qq <Esc>
 " Substitue for ESC  
vmap qq <Esc>
" save all buffer s
map <C-s> :wall<CR>
" move from left window
map <C-h> <C-w>h
" move to right window 
map <C-l> <C-w>l
" move to lower window
noremap <C-m> <C-w>j
" not paste the deleted word
map <C-p> "0p
" move current line up
nnoremap <C-k> ddkk""p
" move current line down
noremap <C-j> dd""p
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
nnoremap <silent> <A-Right> :execute 'silent! tabmove ' . tabpagenr()<CR>
nmap <S-t> :Te<CR>
" dupplicate current tab
" bring line down up
"noremap  <C-J> <S-j>
" move to the beggning of line
noremap <S-w> $
" move to the end of line
noremap <S-b> ^
" jump to corresponding item<Leader> ending {,(, etc..
noremap t %
" Close all
nmap <C-x> :qall!<CR>
" open new to tab to explorer
nmap <C-n> :tab split<CR>
" insert tab spaces in normal mode
noremap <Tab> i<Tab><Esc>
noremap <S-x> :tabclose<CR>

"This is a very good to show and search all current but a much better is 
"to download vim-easygrep its a lot better 
nnoremap gr :vimgrep <cword> %:p:h/*<CR> :copen 20<CR>
"nnoremap gr :vimgrep <cword>/".input("Replace with: ")" %:p:h/*<CR> :copen 20<CR>

" remaped search to s
noremap s #
" remaped delete to use it for scrolling
noremap <C-d> d
	
"//////////FOLDING//////////////
" folding select text then S-f to fold or just S-f to toggle folding
"inoremap <S-f> <C-O>za interferes when input mode is on
nnoremap <S-f> za
onoremap <S-f> <C-C>za
vnoremap <S-f> zf

"//////////SCROLLING//////////////
noremap e <C-y><C-y><C-y><C-y><C-y><C-y><C-y><C-y><C-y><C-y><C-y><C-y><C-y><C-y><C-y><C-Y>26k
noremap d <C-e><C-e><C-e><C-e><C-e><C-e><C-e><C-e><C-e><C-e><C-e><C-e><C-e><C-e><C-e><C-e>26j



"///////////////MISC NOTES///////////////////
"useful command to convert all , into new lines
	":%s,/\r/g  
" to umap something simply type it in the command :unmap ii for example
" :w xxx - save as xxx keep working on original
" :sav xxx -save as xxx switch to new file
" H - jump cursor to begging of screen
" M - jump cursor to middle of screen
" L - jump cursor to end of screen
" vib - visual mode select all inside ()
" <C-q> in windows Visual Block mode
" <C-v> in linux Visual Block mode
" --------------------------


