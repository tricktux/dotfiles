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

	"//////////////////Vundle Stuff for windows/////////////////////
	" set the runtime path to include Vundle and initialize
	set rtp+=$HOME/vimfiles/bundle/Vundle.vim/
	call vundle#begin('$HOME/vimfiles/bundle/')
	" alternatively, pass a path where Vundle should install plugins
	"call vundle#begin('~/some/path/here')

	" let Vundle manage Vundle, required
	Plugin 'VundleVim/Vundle.vim'
	"Plugin 'chrisbra/vim-diff-enhanced'
	"Plugin 'scrooloose/nerdtree'
	Plugin 'scrooloose/nerdcommenter'
	Plugin 'lervag/vimtex' " Latex support
	"Plugin 'fugitive.vim'
	Plugin 'bling/vim-airline'	" Status bar line
	Plugin 'Vim-R-plugin'
	Plugin 'Shougo/neocomplete.vim'
	Plugin 'Tagbar'
	Plugin 'juneedahamed/vc.vim' " SVN, GIT, HG, and BZR repo support
	Plugin 'Raimondi/delimitMate' " AutoClose brackets, etc...

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
	map <F2> :mksession! C:\Users\h129522\Downloads\vim\sessions\
	" And load session with F3
	map <F3> :source C:\Users\h129522\Downloads\vim\sessions\
	" configure tags - add additional tags here or comment out not-used ones
	set tags+=$HOME/vimfiles/tags/cpp
	set tags+=$HOME/vimfiles/tags/tags

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
	Plugin 'scrooloose/nerdcommenter'
	Plugin 'scrooloose/nerdtree'
	Plugin 'chrisbra/vim-diff-enhanced'
	Plugin 'fugitive.vim' "git plugin
	Plugin 'lervag/vimtex' " Latex support
	Plugin 'taketwo/vim-ros'
	Plugin 'bling/vim-airline' " Status bar line
	Plugin 'file:///home/reinaldo/.vim/bundle/vim-hardy' "Arduino
	Plugin 'Shougo/neocomplete.vim'
	Plugin 'Vim-R-plugin'
	Plugin 'Tagbar'

	" All of your Plugins must be added before the following line
	call vundle#end()            " required
	" ////////////////////////////////////////////////////////
	"///////////////////Specific settings for Unix////////////////////////
	" This is to make it consistent with Windows making C-q be visual block mode now
	noremap <C-q> <C-v>
	" making C-v paste stuff from system register
	noremap <C-v> "+p
	autocmd BufNewFile,BufReadPost *.ino,*.pde setlocal ft=arduino
	" configure tags - add additional tags here or comment out not-used ones
	set tags+=~/.vim/tags/cpp
	set tags+=~/.vim/tags/tags
	set tags+=~/.vim/tags/copter


endif

"/////////////////////STUFF_FOR_BOTH_SYSTEMS///////////////////////
	" Omni complete stuff
	" build tags of your own project with Ctrl-F12
	map <C-F12> :!ctags -R --sort=yes --c++-kinds=+pl --fields=+iaS --extra=+q .<CR>

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
" LaTex Stuff
set grepprg=grep\ -nH\ $*
set sw=2
set iskeyword+=:

filetype plugin on   
filetype indent on   

let mapleader=","
let maplocalleader=","
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
"////////////////////////////////////////////////////////
" comment line uses plug in
nmap - <Leader>ci
vmap - <Leader>ci
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
" Switch back and forth between header file
nnoremap <Leader>oh :e %:p:s,.h$,.X123X,:s,.cpp$,.h,:s,.X123X$,.cpp,<CR>"
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
nnoremap <S-CR> o<Esc>
" Substitute for ESC   
nnoremap <Space> i <Esc> 
" Normal backspace functionalit y
nnoremap <Backspace> hxh<Esc> 
 " Substitute for ESC  
imap qq <Esc>
 " Substitute for ESC  
vmap qq <Esc>
" save all buffer s
map <C-s> :w<CR>
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
" Close all
nmap <C-x> :qall!<CR>
" open new to tab to explorer
nmap <C-n> :tab split<CR>
" insert tab spaces in normal mode
noremap <Tab> i<Tab><Esc>
noremap <S-x> :tabclose<CR>

" This is a very good to show and search all current but a much better is 
" to download vim-easygrep its a lot better 
nnoremap gr :vimgrep <cword> %:p:h/*<CR> :copen 20<CR>
" nnoremap gr :vimgrep <cword>/".input("Replace with: ")" %:p:h/*<CR> :copen 20<CR>

" remaped search to s
noremap s #
" remaped delete to use it for scrolling
noremap <C-d> d
	
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
noremap e <C-y><C-y><C-y><C-y><C-y><C-y><C-y><C-y><C-y><C-y><C-y><C-y><C-y><C-y><C-y><C-Y>26k
noremap d <C-e><C-e><C-e><C-e><C-e><C-e><C-e><C-e><C-e><C-e><C-e><C-e><C-e><C-e><C-e><C-e>26j
" Search for highlighted word
vnoremap // y/<C-R>"<CR>
inoremap <C-k> ->
set nowrap        " wrap lines


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
	"Plugin 'scrooloose/nerdcommenter'
		"nmap <Leader>nb :Bookmark 
		"nmap <Leader>no :NERDTree<CR>
		"let NERDTreeShowBookmarks=1  " B key to toogle
		"let NERDTreeShowHidden=1 " i key to toogle
		"let NERDTreeMapJumpLastChild=',j' 
		"let NERDTreeMapJumpFirstChild=',k' 
		"let NERDTreeMapOpenExpl=',e' 
" ///////////////////////////////////////////////////////////////////
	"Plugin 'vc.vim' "version control plugin
		noremap <Leader>va :VCAdd<CR>
		noremap <Leader>vc :VCCommit<CR> 
		noremap <Leader>vp :VCPush<CR> 
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
		" install.packages("C:\\Users\\h129522\\Downloads\\vim\\vimcom\\VimCom", type = "source", repos = NULL)
		" put this in your InstallationRdir/etc/Rprofile.site
							"options(vimcom.verbose = 1)
							"library(vimcom)
							
" ///////////////////////////////////////////////////////////////////
	"Plugin 'Tagbar'
		nmap <Leader>tt :TagbarToggle<CR>

" ///////////////////////////////////////////////////////////////////
	"Plugin 'Newtr' VIM built in Explorer
		let g:netrw_sort_sequence='[\/]$,*,\.bak$,\.o$,\.h$,\.info$,\.swp$,\.obj$'
		let g:netrw_localcopydircmd	="copy /-y"
" ///////////////////////////////////////////////////////////////////
	" Deleted plugins
	"Plugin 'justmao945/vim-clang'
"//////////////////////////////////////////////////////////////////////////////////////////
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
" <C-q> in windows Visual Block mode
" <C-v> in linux Visual Block mode
" LUA Installation in windows:
" 	download latest vim from DOWNLOAD VIM in bookmarks
" 	Donwload lua windows binaries from the website for the architecture you
" 	have
" 	Put lua in your path and also lua52.dll in your vim executable
" - To read output of a command use:
"   	:read !<command>
" --------------------------

	
