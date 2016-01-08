set nocompatible
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
	"Stuff to show tab numbers at begginig
	set showtabline=2 " always show tabs in gvim, but not vim
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

	"--------------------------------- Vundle Stuff for windows--------
	filetype off                  " required

	" set the runtime path to include Vundle and initialize
	set rtp+=$HOME/vimfiles/bundle/Vundle.vim/
	call vundle#begin('$HOME/vimfiles/bundle/')
	" alternatively, pass a path where Vundle should install plugins
	"call vundle#begin('~/some/path/here')

	" let Vundle manage Vundle, required
	Plugin 'VundleVim/Vundle.vim'

	"Plugin 'Valloric/YouCompleteMe'
	" Instructions to install YCM after that install LLVM
	" install cmake and add it to path
	" and run following command cmake -G "Visual Studio 14" -DPATH_TO_LLVM_ROOT="C:\Program Files (x86)\LLVM" . ..\third_party\ycmd\cpp
	" The following are examples of different formats supported.
	" Keep Plugin commands between vundle#begin/end.
	" plugin on GitHub repo
	"Plugin 'tpope/vim-fugitive'
	" plugin from http://vim-scripts.org/vim/scripts.html
	" Plugin 'L9'
	" Git plugin not hosted on GitHub
	"Plugin 'git://git.wincent.com/command-t.git'
	" git repos on your local machine (i.e. when working on your own plugin)
	"P lugin 'file:///home/gmarik/path/to/plugin'
	" The sparkup vim script is in a subdirectory of this repo called vim.
	" Pass the path to set the runtimepath properly.
	"Pl ugin 'rstacruz/sparkup', {'rtp': 'vim/'}
	" Avoid a name conflict with L9
	"Plu gin 'user/L9', {'name': 'newL9'}

	" All of your Plugins must be added before the following line
	call vundle#end()            " required
	filetype plugin indent on    " required
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
	"--------------------------------- Vundle Stuff for windows ENDS--------

endif
if has('unix')
	if has('gui_running')
		set guioptions-=T  " no toolbar
		set guifont=Monospace\ 8
		colorscheme desert
	endif
	set ffs=unix
	" Quick write session with F2
	map <F2> :mksession! /home/reinaldo/.vim/sessions/
	" And load session with F3
	map <F3> :source /home/reinaldo/.vim/sessions/
	"au BufWinLeave * mkview
	"au BufWinEnter * silent loadview
	"if has("autocmd")
	"	au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
	"endif
	"Stuff to show tab numbers at begginig
	set showtabline=2 " always show tabs in gvim, but not vim
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

	" ///////////////VIM_VUNDLE_STUFF////////////////////////
	set nocompatible
	filetype off                  " required

	" set the runtime path to include Vundle and initialize
	set rtp+=~/.vim/bundle/Vundle.vim
	call vundle#begin()
	" alternatively, pass a path where Vundle should install plugins
	"call vundle#begin('~/some/path/here')

	" let Vundle manage Vundle, required
	Plugin 'VundleVim/Vundle.vim'

	" List all of your plugins below this line
	Plugin 'file:///home/reinaldo/.vim/bundle/vim-hardy'
	
	" Smart autocomplete
	"Plugin 'Valloric/YouCompleteMe'
	" Installation instructions:
	"	run ~/Google Drive/scripts/install_software/vim_ycm.sh
	"let g:ycm_global_ycm_extra_conf = '~/.ycm_extra_conf.py'

	Plugin 'scrooloose/nerdcommenter'
	Plugin 'scrooloose/nerdtree'
	Plugin 'chrisbra/vim-diff-enhanced'

	" All of your Plugins must be added before the following line
	call vundle#end()            " required
	filetype plugin indent on    " requiredutocmd BufNewFile,BufReadPost *.ino,*.pde setlocal ft=arduino
	" use :PluginInstall to install plugins
	" use :PluginInstall! to uninstall plugins after you delete them from this list
	" ////////////////////////////////////////////////////////
endif

if has('unix')
	if has('gui_running')
		set guioptions-=T  " no toolbar
		set guifont=Monospace\ 8
		colorscheme desert
	endif
	set ffs=unix
	" Quick write session with F2
	map <F2> :mksession! /home/reinaldo/.vim/sessions/
	" And load session with F3
	map <F3> :source /home/reinaldo/.vim/sessions/
	"au BufWinLeave * mkview
	"au BufWinEnter * silent loadview
	"if has("autocmd")
	"	au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
	"endif
	"Stuff to show tab numbers at begginig
	set showtabline=2 " always show tabs in gvim, but not vim
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

	" ///////////////VIM_VUNDLE_STUFF////////////////////////
	set nocompatible
	filetype off                  " required

	" set the runtime path to include Vundle and initialize
	set rtp+=~/.vim/bundle/Vundle.vim
	call vundle#begin()
	" alternatively, pass a path where Vundle should install plugins
	"call vundle#begin('~/some/path/here')

	" let Vundle manage Vundle, required
	Plugin 'VundleVim/Vundle.vim'
	" Command to install Vundle in linux
	"	git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

	" List all of your plugins below this line
	Plugin 'file:///home/reinaldo/.vim/bundle/vim-hardy'
	
	" Smart autocomplete
	"Plugin 'Valloric/YouCompleteMe'
	" Installation instructions:
	"	run ~/Google Drive/scripts/install_software/vim_ycm.sh
	"let g:ycm_global_ycm_extra_conf = '~/.ycm_extra_conf.py'

	Plugin 'scrooloose/nerdcommenter'
	Plugin 'scrooloose/nerdtree'
	Plugin 'chrisbra/vim-diff-enhanced'

	" All of your Plugins must be added before the following line
	call vundle#end()            " required
	filetype plugin indent on    " requiredutocmd BufNewFile,BufReadPost *.ino,*.pde setlocal ft=arduino
	" use :PluginInstall to install plugins
	" use :PluginInstall! to uninstall plugins after you delete them from this list
	" ////////////////////////////////////////////////////////
endif
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
let mapleader=","
set nowrap        " don't wrap lines
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
syntax on
" comment line uses plug in
map - <Leader>ci
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
" move to upper window
map <Leader>o <C-w>k
" move to lower window
noremap <C-m> <C-w>j
" not paste the deleted word
map <C-p> "0p
" on quickfix window go to line selected
nnoremap <Leader>c :.cc<CR>
" on quickfix close window
nnoremap <Leader>cl :ccl<CR>
" open quickfix window
nnoremap <Leader>co :copen 20<CR>
" edit vimrc on a new tab
nnoremap <Leader>v :tabedit $MYVIMRC<CR>
" source current document(usually used with vimrc)
nnoremap <Leader>s :so %<CR>
" diff left and right window
nnoremap <Leader>d :windo diffthis<CR>
" close diff
nnoremap <Leader>dl :diffoff!<CR> ZZ
" off highlited search
nnoremap <Leader>n :noh<CR>
" duplicate current char
nnoremap <Leader>p ylp
" move current line up
nnoremap <C-k> ddkk""p
" move current line down
noremap <C-j> dd""p
" duplicate current line down
map <S-q> yyp
" move to the right tab
noremap <S-k> gt
" move to the left tab
noremap <S-j> gT
" move tab to the left
nnoremap <silent> <A-Left> :execute 'silent! tabmove ' . (tabpagenr()-2)<CR>
" move tab to the right
nnoremap <silent> <A-Right> :execute 'silent! tabmove ' . tabpagenr()<CR>
nmap <S-t> :Te<CR>
" open explorer on current tab
noremap <Leader>op :e.<CR>
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
"This is a very good to show and search all current but a much better is 
"to download vim-easygrep its a lot better 
nnoremap gr :vimgrep <cword> %:p:h/*<CR> :copen 20<CR>
"nnoremap gr :vimgrep <cword>/".input("Replace with: ")" %:p:h/*<CR> :copen 20<CR>
set autochdir " working directory is always the same as the file you are editing

noremap <C-d> d
	
" folding select text then S-f to fold or just S-f to toggle folding
"inoremap <S-f> <C-O>za interferes when input mode is on
nnoremap <S-f> za
onoremap <S-f> <C-C>za
vnoremap <S-f> zf


" ------MISC NOTES-------------
"useful command to convert all , into new lines
	":%s,/\r/g  
" to umap something simply type it in the command :unmap ii for example
" :w xxx - save as xxx keep working on original
" :sav xxx -save as xxx switch to new file
" H - jump cursor to begging of screen
" M - jump cursor to middle of screen
" L - jump cursor to end of screen
" --------------------------

noremap e <C-y><C-y><C-y><C-y><C-y><C-y><C-y><C-y><C-y><C-y><C-y><C-y><C-y><C-y><C-y><C-Y>26k
noremap d <C-e><C-e><C-e><C-e><C-e><C-e><C-e><C-e><C-e><C-e><C-e><C-e><C-e><C-e><C-e><C-e>26j

" automatic syntax for *.scp
autocmd! BufNewFile,BufRead *.scp set syntax=asm
" save marks 
set viminfo='1000,f1
set cursorline
"highlight current line
nnoremap <silent> <Leader>l :exe "let m=matchadd('WildMenu','\\<\\w*\\%" . line(".") . "l\\%" . col(".") . "c\\w*\\>')"<CR>
"clear highlighted line
nnoremap <silent> <Leader><CR> :call clearmatches()<CR>
" remaped search to s
noremap s #
" insert tab spaces in normal mode
noremap <Tab> i<Tab><Esc>
noremap <S-x> :tabclose<CR>
