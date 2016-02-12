set nocompatible
filetype off                  " required
" moved here otherwise conditional mappings get / instead ; as leader 
let mapleader="\<Space>"
let maplocalleader="\<Space>"
if has('win32')
	source $VIMRUNTIME/vimrc_example.vim
	source $VIMRUNTIME/mswin.vim
	behave mswin
	set ffs=dos


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
	noremap <Leader>tu :silent !dir /b /s *.cpp *.h *.cs > cscope.files<CR> 
	\:silent !cscope -b -i cscope.files -f cscope.out<CR>
	\:cs kill -1<CR>:cs add cscope.out<CR>
	\:silent !ctags -R -f ./.svn/tags<CR>
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

	"//////////////////Vundle Stuff for windows/////////////////////
	" set the runtime path to include Vundle and initialize
	set rtp+=$HOME/vimfiles/bundle/Vundle.vim/
	call vundle#begin('$HOME/vimfiles/bundle/')
	" alternatively, pass a path where Vundle should install plugins
	"call vundle#begin('~/some/path/here')
	"Plugin 'ctrlpvim/ctrlp.vim' " quick file searchh"
		set wildignore+=*\\.git\\*,*\\.hg\\*,*\\.svn\\*  " Windows ('noshellslash')
		let g:ctrlp_custom_ignore = {
			\ 'dir':  '\v[\/]\.(git|hg|svn)$',
			\ 'file': '\v\.(exe|so|dll|dfm)$',
			\ 'link': 'SOME_BAD_SYMBOLIC_LINKS',
			\ }
		let g:ctrlp_user_command = ['.hg', 'for /f "tokens=1" %%a in (''hg root'') '
			\ . 'do hg --cwd %s status -numac -I . %%a']           " Windows

	" make of the copy command for NerdTree for windows
		let g:NERDTreeCopyCmd= 'cp -r '
endif

if has('unix')
	set ffs=unix
	nnoremap <Leader>mz :mksession! /home/reinaldo/.vim/sessions/
	nnoremap <Leader>mx :source /home/reinaldo/.vim/sessions/
	noremap <Leader>mq <C-v>
	" making C-v paste stuff from system register
	autocmd BufNewFile,BufReadPost *.ino,*.pde setlocal ft=arduino
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
	" this one below DOES WORK in linux just make sure is ran at root folder
	noremap <Leader>tu :silent !find . -iname '*.c' -o -iname '*.cpp' -o -iname '*.h' -o -iname '*.hpp' > cscope.files<CR>
  	\:silent !cscope -b -i cscope.fiels -f cscope.out<CR>
	\:cs kill -1<CR>:cs add cscope.out<CR>
	\:silent !ctags -R --sort=yes --c++-kinds=+pl --fields=+iaS --extra=+q .<CR>
	nmap <Leader>mr :!./%<CR>
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
	set rtp+=~/.vim/bundle/Vundle.vim
	call vundle#begin()
	"Plugin 'ctrlpvim/ctrlp.vim' " quick file searchh"
		set wildignore+=*/.git/*,*/.hg/*,*/.svn/*        " Linux/MacOSX
		let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
		let g:ctrlp_user_command =
			\ ['.hg', 'hg --cwd %s status -numac -I . $(hg root)'] " MacOSX/Linux
	Plugin 'file:///home/reinaldo/.vim/bundle/vim-hardy' "Arduino

endif

"/////////////////////STUFF_FOR_BOTH_SYSTEMS///////////////////////
"/////////////////////PLUGINS_FOR_BOTH_SYSTEMS///////////////////////
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
	"Plugin 'Raimondi/delimitMate' " AutoClose brackets, etc...
	Plugin 'tpope/vim-surround'
	Plugin 'junegunn/rainbow_parentheses.vim'
	Plugin 'morhetz/gruvbox' " colorscheme gruvbox 
	Plugin 'nathanaelkane/vim-indent-guides' 
	Plugin 'mattn/emmet-vim' " HTML fast code
	Plugin 'Shougo/neosnippet'
	Plugin 'Shougo/neosnippet-snippets'
	Plugin 'honza/vim-snippets'
	" support for c sharp coding
	Plugin 'OmniSharp/omnisharp-vim'
	" used to support omnisharp server
	Plugin 'tpope/vim-dispatch'
	Plugin 'scrooloose/syntastic'
	Plugin 'ctrlpvim/ctrlp.vim'


	" All of your Plugins must be added before the following line
	call vundle#end()            " required
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
function! SetCppOptions()
	setlocal omnifunc=omni#cpp#complete#Main
	set cindent
	IndentGuidesToggle
	RainbowParentheses
endfunction
"///////////////////FUNCTION_FOR_DIFF///////////////////
set diffexpr=
"////////////////////////////////////////////////////////
"////////////SET_OPTIONS///////////////////////////
filetype plugin on   
filetype indent on   

"set spell spelllang=en_us
set nospell
" save marks 
set viminfo='1000,f1,<800
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
set ignorecase    " ignore case when searching
set smartcase     " ignore case if search pattern is all lowercase,
                    "    case-sensitive otherwise
set smarttab      " insert tabs on the start of a line according to
                    "    shiftwidth, not tabstop
set hlsearch      " highlight search terms
set relativenumber
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
" source current document(usually used with vimrc)
noremap <Leader>ms :so %<CR>
 " used to save in command line 
noremap <Leader>ma :w<CR>
noremap <Leader>mn :noh<CR>
" duplicate current char
nnoremap <Leader>mp ylp
nmap <Leader>mt :set relativenumber!<CR>
nmap <Leader>md :Dox<CR>
"//////////FOLDING//////////////
" Folding select text then S-f to fold or just S-f to toggle folding
nnoremap <Leader>mf za
onoremap <Leader>mf <C-C>za
vnoremap <Leader>mf zf
" move to upper window
noremap <Leader>h <C-w>h
noremap <Leader>mh <C-w>H
noremap <Leader>j <C-w>j
noremap <Leader>mj <C-w>J
noremap <Leader>k <C-w>k
noremap <Leader>mk <C-w>K
noremap <Leader>l <C-w>l
noremap <Leader>ml <C-w>L
noremap <Leader>m. 20<C-w>>
noremap <Leader>m, 20<C-w><
" not paste the deleted word
nmap <Leader><Space>p "0p
vmap <Leader><Space>p "0p
" move current line up
nnoremap <Leader>K ddkk""p
" move current line down
noremap <Leader>J dd""p
" Close all
nmap <Leader><Space>x :qall!<CR>
" open new to tab to explorer
nmap <Leader><Space>n :tab split<CR>
" previous cursor position
nmap <Leader>e <c-o>
" next cursor position
"nmap ,s <c-i>" this is never going to work because you cant separate tab and
"c-i
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
nmap <Leader>sn ]s
" search backwards
nmap <Leader>sp [s
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
" SyntasticCheck toggle
nmap <Leader>so :SyntasticCheck<CR>:SyntasticToggleMode<CR>

" Insert empty line below
" Substitute for ESC   
 "nnoremap <Space> i <Esc> 
" Normal backspace functionalit y
nnoremap <Backspace> hxh<Esc> 
 " Substitute for ESC  
imap qq <Esc>
 " Substitute for ESC  
vmap qq <Esc>
" save all buffer s
"map <C-s> :w<CR>"
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
nnoremap T %
vnoremap T %
" insert tab spaces in normal mode
nmap <Tab> i<Tab><Esc>
noremap <S-x> :tabclose<CR>

" This is a very good to show and search all current but a much better is 
" to download vim-easygrep its a lot better 
nnoremap gr :vimgrep <cword> %:p:h/*<CR> :copen 20<CR>
" nnoremap gr :vimgrep <cword>/".input("Replace with: ")" %:p:h/*<CR> :copen 20<CR>
" remaped search to f
noremap S #
" remaped delete to use it for scrolling
"noremap ,d d"
	
if has('unix')
	autocmd BufWinLeave ?* mkview
	autocmd BufWinEnter ?* silent loadview
endif
" Automatically insert date
nnoremap <F5> "=strftime("%c")<CR>P
inoremap <F5> <C-R>=strftime("%c")<CR>
"//////////SCROLLING//////////////
nmap e 20k
vmap e 20k
nmap s 20j
vmap s 20j
" repeat last f command forward
"nmap , ,
" repeat last f command backwards
"nmap " ,
" see :h timeout this was done to make use of ' faster and keep the other
" timeout the same
set notimeout
set nottimeout
set timeoutlen=300
set ttimeoutlen=1000
" Search for highlighted word
vnoremap // y/<C-R>"<CR>
imap <C-l> ->
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

endif


" /////////////////PLUGIN_OPTIONS////////////////////////////////////////////
	"Plugin 'VundleVim/Vundle.vim'
		noremap <Leader>pl :PluginList<CR>
		" lists configured plugins
		noremap <Leader>pi :PluginInstall<CR>
		noremap <Leader>pu :PluginInstall!<CR>
		" installs plugins; append `!` to update or just :PluginUpdate
		noremap <Leader>ps :PluginSearch<CR>
		" searches for foo; append `!` to refresh local cache
		noremap <Leader>pc :PluginClean<CR>      
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
		imap <C-c> <plug>NERDCommenterInsert
		nmap <Leader>ca <plug>NERDCommenterAppend
		nmap <Leader>cy <plug>NERDCommenterYank
		nmap <Leader>cw <plug>NERDCommenterToEOL
	"Plugin 'scrooloose/NERDTree'
		nmap <Leader>nb :Bookmark 
		let NERDTreeShowBookmarks=1  " B key to toggle
		nmap <Leader>no :NERDTree<CR>
		" enable line numbers
		let NERDTreeShowLineNumbers=1
		" make sure relative line numbers are used
		autocmd FileType nerdtree setlocal relativenumber
		let NERDTreeShowHidden=1 " i key to toggle
		let NERDTreeMapJumpLastChild=',j' 
		let NERDTreeMapJumpFirstChild=',k' 
		let NERDTreeMapOpenExpl=',e' 
		let NERDTreeMapOpenVSplit=',s'
        let NERDTreeQuitOnOpen=1 " AutoClose after openning file
" ///////////////////////////////////////////////////////////////////
	"Plugin 'vc.vim' "version control plugin
		noremap <Leader>va :VCAdd<CR>
		noremap <Leader>vc :VCCommit<CR> 
		noremap <Leader>vp :VCPush<CR> 
		noremap <Leader>ga :silent !git add %<CR>
		noremap <Leader>gc :silent !git commit -m "
		noremap <Leader>gp :!git push origin master<CR> 
		"typical order also depends where you are pushing
		noremap <Leader>vd :VCDiff<CR> 
		noremap <Leader>vl :VCLog<CR>
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
	"Plugin 'bling/vim-airline' " Status bar line
		set laststatus=2
" ///////////////////////////////////////////////////////////////////
	"Plugin 'file:///home/reinaldo/.vim/bundle/vim-hardy'
		if has('unix')
			let g:hardy_arduino_path='/home/reinaldo/Downloads/arduino-1.6.5-r5/arduino'
		endif
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
		autocmd FileType cpp call SetCppOptions()
		

		" Enable heavy omni completion.
		if !exists('g:neocomplete#sources#omni#input_patterns')
			let g:neocomplete#sources#omni#input_patterns = {}
		endif
		"let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
		"let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
		"let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

		" For perlomni.vim setting.
		" https://github.com/c9s/perlomni.vim
		"let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'
		let g:neocomplete#sources#omni#input_patterns.cs = '.*[^=\);]'
		"let g:neocomplete#sources.cs = ['omni']
		let g:neocomplete#enable_refresh_always = 0
		"let g:echodoc_enable_at_startup = 1
		
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
		" Enable snipMate compatibility feature.
		let g:neosnippet#enable_snipmate_compatibility = 1

		" Tell Neosnippet about the other snippets
		let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/snippets'

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
		nmap <Leader>tt :TagbarToggle<CR>
		nmap <Leader>tk :cs kill -1<CR>
		nmap <silent> <Leader>tj <C-]>
		nmap <Leader>tr <C-t>
		nmap <Leader>tn :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
		" ReLoad cscope database
		noremap <Leader>tl :cs add $CSCOPE_DB<CR>
		" Find functions calling this function
		nmap <Leader>tc :cs find c <C-R>=expand("<cword>")<CR><CR>
		" Find functions definition
		nmap <Leader>tg :cs find g <C-R>=expand("<cword>")<CR><CR>
		" Find functions called by this function
		nmap <Leader>td :cs find d <C-R>=expand("<cword>")<CR><CR>
		nmap <Leader>ts :cs show<CR>

" ///////////////////////////////////////////////////////////////////
	"Plugin 'ctrlpvim/ctrlp.vim' " quick file searchh
		nmap <Leader>ao :CtrlP<CR>
		nmap <Leader>am :CtrlPMRU<CR>
		nmap <Leader>at :tabnew<CR>:CtrlPMRU<CR>
		nmap <Leader>av :vs<CR>:CtrlPMRU<CR>
		nmap <Leader>as :sp<CR>:CtrlPMRU<CR>
		let g:ctrlp_match_window = 'bottom,order:btt,min:1,max:10,results:10'

" ///////////////////////////////////////////////////////////////////
	"Plugin 'Newtr' VIM built in Explorer
		let g:netrw_sort_sequence='[\/]$,*,\.bak$,\.o$,\.h$,\.info$,\.swp$,\.obj$'
		let g:netrw_localcopydircmd	="copy /-y"

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
	"Plug 'junegunn/rainbow_parentheses.vim'
		let g:rainbow#max_level = 16
		let g:rainbow#pairs = [['(', ')'], ['[', ']'], ['{', '}']]

		" List of colors that you do not want. ANSI code or #RRGGBB
		let g:rainbow#blacklist = [233, 234]
" ///////////////////////////////////////////////////////////////////

	""Plugin 'SirVer/ultisnips'  	" Track the engine.
	"" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
		"let g:UltiSnipsExpandTrigger="<nop>"
		"let g:UltiSnipsJumpForwardTrigger="<c-b>"
		"let g:UltiSnipsJumpBackwardTrigger="<c-z>"
		"" makes possible the use of CR to enter snippet 
		"let g:ulti_expand_or_jump_res = 0
		"function! ExpandSnippetOrCarriageReturn()
			"let snippet = UltiSnips#ExpandSnippetOrJump()
			"if g:ulti_expand_or_jump_res > 0
				"return snippet
			"else
				"return "\<CR>"
			"endif
		"endfunction
		"inoremap <expr> <CR> pumvisible() ? "<C-R>=ExpandSnippetOrCarriageReturn()<CR>" : "\<CR>"
		"""""""""""""""""""""""""""""""""""""""""""""""""""
		" If you want :UltiSnipsEdit to split your window.
		"let g:UltiSnipsEditSplit="vertical""
"//////////////////////////////////////////////////////////////////////////////////////////
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
		autocmd FileType cs call SetCsOptions()

		" Synchronous build (blocks Vim)
		"autocmd FileType cs nnoremap <F5> :wa!<cr>:OmniSharpBuild<cr>
		" Builds can also run asynchronously with vim-dispatch installed
		noremap <leader>ob :wa!<cr>:OmniSharpBuildAsync<cr>
		" automatic syntax check on events (TextChanged requires Vim 7.4)
		"autocmd BufEnter,TextChanged,InsertLeave *.cs SyntasticCheck


		"The following commands are contextual, based on the current cursor position.

		"autocmd FileType cs nnoremap gd :OmniSharpGotoDefinition<cr>
		""finds members in the current buffer
		"autocmd FileType cs nnoremap <leader>fm :OmniSharpFindMembers<cr>
		"" cursor can be anywhere on the line containing an issue
		"autocmd FileType cs nnoremap <leader>x  :OmniSharpFixIssue<cr>
		"autocmd FileType cs nnoremap <leader>fx :OmniSharpFixUsings<cr>
		"autocmd FileType cs nnoremap <leader>tt :OmniSharpTypeLookup<cr>
		"autocmd FileType cs nnoremap <leader>dc :OmniSharpDocumentation<cr>
		""navigate up by method/property/field
		"autocmd FileType cs nnoremap <C-K> :OmniSharpNavigateUp<cr>
		""navigate down by method/property/field
			"autocmd FileType cs nnoremap <C-J> :OmniSharpNavigateDown<cr>
		" this setting controls how long to wait (in ms) before fetching type / symbol information.
		set updatetime=500
		" Remove 'Press Enter to continue' message when type information is longer than one line.
		set cmdheight=2

		noremap <leader>oi :OmniSharpFindImplementations<cr>
		noremap <leader>ot :OmniSharpFindType<cr>
		noremap <leader>os :OmniSharpFindSymbol<cr>
		noremap <leader>ou :OmniSharpFindUsages<cr>
		"" Contextual code actions (requires CtrlP or unite.vim)
		"nnoremap <leader><space> :OmniSharpGetCodeActions<cr>
		"" Run code actions with text selected in visual mode to extract method
		"vnoremap <leader><space> :call OmniSharp#GetCodeActions('visual')<cr>

		"" rename with dialog
		nnoremap <leader>or :OmniSharpRename<cr>
		"nnoremap <F2> :OmniSharpRename<cr>
		"" rename without dialog - with cursor on the symbol to rename... ':Rename newname'
		"command! -nargs=1 Rename :call OmniSharp#RenameTo("<args>")

		"" Force OmniSharp to reload the solution. Useful when switching branches etc.
		nnoremap <leader>ol :OmniSharpReloadSolution<cr>
		"nnoremap <leader>cf :OmniSharpCodeFormat<cr>
		"" Load the current .cs file to the nearest project
		"nnoremap <leader>tp :OmniSharpAddToProject<cr>

		"" (Experimental - uses vim-dispatch or vimproc plugin) - Start the omnisharp server for the current solution
		"nnoremap <leader>ss :OmniSharpStartServer<cr>
		"nnoremap <leader>sp :OmniSharpStopServer<cr>
		function! SetCsOptions()
			OmniSharpHighlightTypes
			setlocal omnifunc=OmniSharp#Complete
			" Automatically add new cs files to the nearest project on save
			autocmd BufWritePost *.cs call OmniSharp#AddToProject()

			"show type information automatically when the cursor stops moving
			autocmd CursorHold *.cs call OmniSharp#TypeLookupWithoutDocumentation()
			IndentGuidesToggle
			RainbowParentheses
		endfunction
		let g:OmniSharp_server_type = 'v1'

		"" Add syntax highlighting for types and interfaces
		"nnoremap <leader>th :OmniSharpHighlightTypes<cr>
		"""Don't ask to save when changing buffers (i.e. when jumping to a type definition)

""/////////////////////////////////MISC NOTES/////////////////////////////////////////////
	""Plugin 'scrooloose/syntastic'
		set statusline+=%#warningmsg#
		set statusline+=%{SyntasticStatuslineFlag()}
		set statusline+=%*

		let g:syntastic_always_populate_loc_list = 1
		let g:syntastic_auto_loc_list = 1
		let g:syntastic_check_on_open = 0
		let g:syntastic_check_on_wq = 0
		"let g:syntastic_always_populate_loc_list = 1 " populates list of error so you can use lnext 
"/////////////////////////////////MISC NOTES/////////////////////////////////////////////
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
" use :verbose map <c-i> to understand mappings
" use z. to make current line center of screen
" use c-w+<H,J,K,L> to swap windows around
" Surround stuff:
" 	change(c) surrournd(s): cs<from><to>, i.e: cs("
" 	change(c) surrournd(s) to(t): cst<to>
" 	insert(y) surround: ys<text object>, i.e: ysiw
" 	using opening surrounds, i.e:{,( inserts spaces, closing deletes them
" 	wrap entire line with yss<to>, i.e: yssb or yss( which are the same
" 	delete(d) surrournd(s): ds<surround>, i.e: ds{
" 	Select visual mode line and press:
"		S<p class="important">
" Another important motion is f
" 	df. deletes everything until period
" 	it works with c, v as well 
"
" LUA Installation in windows:
" 	download latest vim from DOWNLOAD VIM in bookmarks
" 	Donwload lua windows binaries from the website for the architecture you
" 	have
" 	Put lua in your path and also lua52.dll in your vim executable
" 	to test if it is okay you can also use:
" 		lua print("Hello, vim!")
" 		this will tell you the error you are getting
" 		last time wih only the lua53.dll fixed it
" 		or just look through the :ver output to see what DLL is expecting
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
"	- Python:
"		- install python-3.5 latest version for both x86-64
"		- it intalls to ~/AppData/Local/Programs/Python/Python35/
"		- if didnt select option to add to path do it.
"		- copy DLL from previous path.
"		- this works on 64 bit systems
"		////////////////
"		- 32 bit: Download and install python 2.7.9 for 32-bit
"		- copy DLL from Windosws/System32/python27.dll
" Installin vim in unix:
"	- Download vim_source_install.sh from drive
"	- run. done
"
" --------------------------


