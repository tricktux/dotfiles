" File:         options.vim
" Description:  Most of set options are done here.
" Author:       Reinaldo Molina <rmolin88@gmail.com>
" Version:        0.0.0
" Last Modified: Mon Mar 16 2020 13:05
" Created: Sep 14 2017 14:47

function! options#Set() abort
  " SET_OPTIONS
  " Regular stuff
  "set spell spelllang=en_us
  "omnicomplete menu
  " save marks
  if has('nvim-0.4')
    " Cool pseudo-transparency for the popup-menu
    set pumblend=30
    hi PmenuSel blend=0
  endif
  " Tue Feb 25 2020 16:40: From vim-galore minimal vimrc
  set autoindent
  " No tabs in the code. Tabs are expanded to spaces
  set expandtab
  set shiftround
  set display=lastline
  set report=0
  set splitright
  " set splitbelow looks silly
  set list                   " Show non-printable characters.
  if has('multi_byte') && &encoding ==# 'utf-8'
    let &listchars = 'tab:▸ ,extends:❯,precedes:❮,nbsp:±,trail:-'
  else
    let &listchars = 'tab:> ,extends:>,precedes:<,nbsp:.,trail:-'
  endif
  " ------
  if exists('g:neovide')
    let g:neovide_refresh_rate=60
    let g:neovide_no_idle=v:false
    " let g:neovide_fullscreen=v:true
    set guifont=FuraCode_Nerd_Font_Mono:h13.5
  else
    set guifont=consolas:h10
  endif
  " Fri Apr 03 2020 17:07: I cursor blinking really gets on my nerves
  set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
        \,a:blinkon0-Cursor/lCursor
  " Supress messages
  " a - Usefull abbreviations
  " c - Do no show match 1 of 2
  " s - Do not show search hit bottom
  " t - Truncate message if is too long
  set shortmess=acst

  set colorcolumn=+1 " Highlight first column after textwidth
  set guitablabel=%N\ %f
  " Silly, always set cool colors
  set termguicolors
  " Tue Nov 13 2018 22:39: Needed by Shuogo/echodoc.vim
  set noshowmode
  " Useful for the find command
  let &path .='.,,..,../..,./*,./*/*,../*,~/,~/**,/usr/include/*'
  if has('unix')
    set shiftwidth=2 tabstop=2
  else
    set shiftwidth=4 tabstop=4
  endif
  set showtabline=1 " always show tabs in gvim, but not vim"
  set backspace=indent,eol,start
  " allow backspacing over everything in insert mode
  " indents defaults. Custom values are changes in after/indent
  " When 'sts' is negative, the value of 'shiftwidth' is used.
  set softtabstop=-8
  set smarttab      " insert tabs on the start of a line according to
  " shiftwidth, not tabstop

  set showmatch     " set show matching parenthesis
  set showcmd       " Show partial commands in the last lines
  set smartcase     " ignore case if search pattern is all lowercase,
  "    case-sensitive otherwise
  set ignorecase
  set infercase
  set hlsearch      " highlight search terms
  set number
  set relativenumber
  set incsearch     " show search matches as you type
  set history=10000         " remember more commands and search history
  " ignore these files to for completion
  " set completeopt=menuone,longest,preview,noselect,noinsert
  set completeopt=menuone,preview,noselect,noinsert
  " set complete+=kspell " currently not working
  " set wildmenu " Sun Jul 16 2017 20:24. Dont like this way. Its weird
  set wildmode=list:longest
  set wildignore+=*.o,*.obj,*.bak,*.exe,*.py[co],*.swp,*~,*.pyc,.svn,.git
  set title                " change the terminal's title
  set titlelen=0
  let &titleold="Closing " . v:progname . "..."

  " Set a pretty title
  augroup TitleString
    autocmd!
    if (exists('#DirChanged'))
      autocmd BufWinLeave,BufWinEnter,CursorHold,DirChanged,TabEnter *
            \ let &titlestring = <sid>get_titlestring()
    else
      autocmd BufWinLeave,BufWinEnter,CursorHold,TabEnter *
            \ let &titlestring = <sid>get_titlestring()
    endif
  augroup END

  " All backups!
  set backup " backup overwritten files
  set writebackup
  " Do not skip a single backup
  set backupskip=
  let &backupdir= g:std_cache_path . '/backup'
  " Tue May 21 2019 10:28: Swap is very painful
  " Still haven't found a good use for it
  set noswapfile
  " let &directory = g:std_cache_path . '/swap//'

  " Undofiles
  let &undodir= g:std_cache_path . '/undofiles'
  set undofile
  set undolevels=10000      " use many muchos levels of undo

  "set autochdir " working directory is always the same as the file you are
  "editing
  " Took out options from here. Makes the session script too long and annoying
  " Fri Jan 11 2019 21:39 Dont add resize, and winpos. It causes problems in
  " linux
  set sessionoptions=buffers,tabpages,winpos
  " if (exists(':tnoremap'))
  " set sessionoptions+=terminal
  " endif
  set hidden
  " see :h timeout this was done to make use of ' faster and keep the other
  " timeout the same
  set notimeout
  set nottimeout
  " cant remember why I had a timeout len I think it was
  " in order to use <c-j> in cli vim for esc
  " removing it see what happens
  " set ttimeoutlen=0
  set wrapmargin=2
  set nowrapscan        " do not wrap search at EOF
  " will look in current directory for tags

  if has('cscope')
    set cscopetag cscopeverbose
    if has('quickfix')
      set cscopequickfix=s+,c+,d+,i+,t+,e+
    endif
  endif
  " set matchpairs+=<:>
  set linebreak    "Wrap lines at convenient points
  " Open and close folds Automatically
  " global fold indent
  " set foldmethod=indent
  set foldmethod=indent
  set foldnestmax=18      "deepest fold is 18 levels
  set foldlevel=0
  set foldlevelstart=0
  " use this below option to set other markers
  "'foldmarker' 'fmr' string (default: "{{{,}}}")
  " Sat Feb 22 2020 16:05: Save only what is necessary
  set viewoptions=cursor,curdir
  " For conceal markers.
  if has('conceal')
    set conceallevel=2 concealcursor=nv
  endif

  if has('nvim')
    set shada='1024,%,s10000,r/tmp,rE:,rF:
    set inccommand=split
    set scrollback=-1
  else
    set viminfo='1024,%,s10000,r/tmp,rE:,rF:
    let &viminfofile= g:std_data_path .  '/viminfo'
    set ttyscroll=3
    set ttyfast " Had to addit to speed up scrolling
    set noesckeys " No mappings that start with <esc>
  endif

  " no mouse enabled
  set mouse=
  set laststatus=2

  " Thu Oct 26 2017 05:13: On small split screens text goes outside of range
  " Fri Jun 15 2018 14:00: These options are better set on case by case basis
  " Fri Jun 15 2018 15:37: Not really
  set nowrap        " wrap lines
  set textwidth=80

  set nolist " Do not display extra characters
  set scroll=8
  set modeline
  set modelines=1
  " Set omni for all filetypes
  set omnifunc=syntaxcomplete#Complete
  " Mon Jun 05 2017 11:59: Suppose to Fix cd to relative paths in windows
  let &cdpath = ',' . substitute(substitute($CDPATH,
        \ '[, ]', '\\\0', 'g'), ':', ',', 'g')
  " Thu Sep 14 2017 14:45: Security concerns addressed by these options.
  set secure
  set noexrc
  " Wed Oct 18 2017 09:19: Stop annoying bell sound
  " Tue Feb 25 2020 16:52: Updated from vim-galore
  set noerrorbells
  set novisualbell
  " Thu Dec 21 2017 09:56: Properly format comment strings
  if v:version > 703 || v:version == 703 && has('patch541')
    set formatoptions+=jw
  endif

  " Status Line and Colorscheme
  " Set a default bogus colorscheme. If Plugins loaded it will be changed
  colorscheme desert
  if !exists('g:loaded_plugins')
    " If this not and android device and we have no plugins setup "ugly" status
    " line
    set statusline =
    set statusline+=\ [%n]                            " buffernr
    set statusline+=\ %<%F\ %m%r%w                    " File+path
    set statusline+=\ %y\                             " FileType
    set statusline+=\ %{''.(&fenc!=''?&fenc:&enc).''} " Encoding
    " ,BOM\ " :\ " \ " )}\ " Encoding2
    set statusline+=\ %{(&bomb?\
    set statusline+=\ %{&ff}\                         " FileFormat (dos/unix..)
    set statusline+=\ %=\ row:%l/%L\ (%03p%%)\        " Rownumber/total (%)
    set statusline+=\ col:%03c\                       " Colnr
    set statusline+=\ \ %m%r%w\ %P\ \            " Modified? Readonly? Top/bot.
    " If you want to put color to status line needs to be after command
    " colorscheme. Otherwise this commands clears it the color
  endif

  " Performance Settings
  " see :h slow-terminal
  set scrolljump=5
  set sidescroll=15 " see help for sidescroll
  set lazyredraw " Had to addit to speed up scrolling
  " Mon May 01 2017 11:21: This breaks split window highliting
  " Tue Jun 13 2017 20:55: Giving it another try
  " Fri Jun 05 2020 16:17: You knew that it breaks highliting with a low number 
  " since 2017 and still went ahead and had this issue for years :/. Please do 
  " not make it lowe than 180
  set synmaxcol=180 " Will not highlight passed this column #
  " Mon Oct 16 2017 15:22: This speed ups a lot of plugin. Those that have to
  " do with highliting.
  set regexpengine=1
  " Fri May 19 2017 11:38 Having a lot of hang ups with the function!
  " s:Highlight_Matching_Pair()
  " on the file C:\Program
  " Files\nvim\Neovim\share\nvim\runtime\plugin\matchparen.vim
  " This value is suppose to help with it. The default value is 300ms
  " DoMatchParen, and NoMatchParen are commands that enable and disable the
  " command
  let g:matchparen_timeout = 80
  let g:matchparen_insert_timeout = 30

  " TODO-[RM]-(Tue Aug 22 2017 10:43): Move this function calls to init#vim or
  " options.vim
  " Grep
  " Fri Mar 23 2018 18:10: Substituted by vim-gprepper plugin
  " Mon Jun 25 2018 14:08: vim-gprepper not working well on windows with
  " neovim-qt
  call s:set_grep()

  " Tags
  set tags=./.tags;,.tags;
  set tagbsearch
  set tagrelative
  set tagcase=smart

  " Diff options
  let &diffopt='vertical'
  try
    set diffopt+=internal,filler,algorithm:patience
  catch
    let g:no_cool_diffopt_available = 1
  endtry

  call s:set_syntax()

  call s:vim_cli()
endfunction

" Called from augroup function s:on_vim_enter
function! options#SetCli() abort
  " Detect one of the many gui types
  if has('gui_running')
    " echomsg 'Detected Gvim GUI. Nothing to do here'
    return
  elseif exists('g:GuiLoaded') && g:GuiLoaded == 1
    " echomsg 'Detected Neovim-qt GUI. Nothing to do here'
    return
  elseif exists('g:gui_oni') && g:gui_oni == 1
    " In addition disable status bar
    set laststatus = 0
    " echomsg 'Detected Oni GUI. Nothing to do here'
    return
  elseif exists('g:eovim_running') && g:eovim_running == 1
    " echomsg 'Detected Eovim GUI. Nothing to do here'
    return
  endif
endfunction

" CLI
function! s:vim_cli() abort
  " Thu May 07 2020 14:22:
  "   Neovim doesn't need any of these options
  " Vim terminal options

  if has('nvim')
    return
  endif

  set t_vb=
  " Trying to get termguicolors to work on vim
  let &t_8f = "\<Esc>[38:2:%lu:%lu:%lum"
  let &t_8b = "\<Esc>[48:2:%lu:%lu:%lum"
  if $TERM ==? 'linux'
    set t_Co=8
  else
    set t_Co=256
  endif

  " fixes colorscheme not filling entire backgroud
  set t_ut=

  " Tue Sep 12 2017 18:18: These are in order to map Alt in vim terminal
  " under linux. Obtained but going into insert mode, pressing <c-v> and
  " then some alt+key combination
  nnoremap <silent> l <C-w>l
  nnoremap <silent> h <C-w>h
  nnoremap <silent> k <C-w>k
  nnoremap <silent> j <C-w>j

  if !has('clipboard') || !has('xterm_clipboard')
    echomsg 'options#Set(): vim wasnt compiled with clipboard support.'
    echomsg 'Remove vim and install gvim'
  else
    set clipboard=unnamedplus
  endif

  if exists('g:system_name') && g:system_name ==# 'cygwin'
    set term=$TERM
    " Fixes cursor shape in mintty/cygwin
    let &t_ti.="\e[1 q"
    let &t_SI.="\e[5 q"
    let &t_EI.="\e[1 q"
    let &t_te.="\e[0 q"
  endif

  " Set blinking cursor shape everywhere
  if exists('$TMUX')
      let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
      let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"

      " Fixes broken nmap <c-h> inside of tmux
      nnoremap <BS> :noh<CR>
  elseif has('unix') " Cursors settings for neo(vim) under linux
      " Start insert mode (bar cursor shape)
      let &t_SI = "\<Esc>[5 q"
      " End insert or replace mode (block cursor shape)
      let &t_EI = "\<Esc>[1 q"
  endif

  if !has('unix') && !has('nvim')
      set term=xterm
      let &t_AB="\e[48;5;%dm"
      let &t_AF="\e[38;5;%dm"
  endif
endfunction

" Support here for rg, ucg, ag in that order
function! s:set_grep() abort
  if executable('rg')
    " use option --list-file-types if in doubt
    " rg = ripgrep
    " Use the -t option to search all text files; -a to search all files; and -u
    " to search all,
    " including hidden files.
    let rg_flags = "rg $* --vimgrep --smart-case " .
          \ "--follow --fixed-strings --hidden --iglob "
    let rg_unix_iglob = "'!.{git,svn}'"
    let rg_win_iglob = "!.{git,svn}"
    let &grepprg= rg_flags . (has('unix') ? rg_unix_iglob : rg_win_iglob)
    set grepformat=%f:%l:%c:%m
  elseif executable('ucg')
    " Add the --type-set=markdown:ext:md option to ucg for it to recognize
    " md files
    set grepprg=ucg\ --nocolor\ --noenv
  elseif executable('ag')
    " ctrlp with ag
    " see :Man ag for help
    " to specify a type of file just do `--cpp`
    let ag_flags = "ag --nogroup --nocolor --smart-case --vimgrep " .
          \ "--glob !.{git,svn} $*"
    let &grepprg= ag_flags
    set grepformat=%f:%l:%c:%m
  endif
endfunction

function! s:set_syntax() abort
  " SYNTAX_OPTIONS

  " ft-sh-syntax
  let g:sh_fold_enabled= 4

  " ft-java-syntax
  let g:java_highlight_java_lang_ids=1
  let g:java_highlight_functions='indent'
  let g:java_highlight_debug=1
  let g:java_space_errors=1
  let g:java_comment_strings=1
  hi javaParen ctermfg=blue guifg=#0000ff

  " ft-c-syntax
  let g:c_minlines = 800
  if !has('unix')
    let g:c_no_if0 = 1
    " let g:c_no_c99 = 1
    " let g:c_no_c11 = 1
    let g:c_no_bsd = 1
  else
    let g:c_space_errors = 1
    let g:c_gnu = 1
    let g:c_curly_error = 1
  endif

  " Automatically highlight doxygen when doing c, c++
  let g:load_doxygen_syntax=1
  let g:doxygen_enhanced_colour=1

  " ft-markdown-syntax
  let g:markdown_fenced_languages= [ 'cpp', 'vim', 'dosini', 'wings_syntax' ]
  " This is handled now by Plug 'plasticboy/vim-markdown'
  let g:markdown_folding= 0

  " ft-python-syntax
  " This option also highlights erroneous whitespaces
  let g:python_highlight_all = 1

  " Man
  " let g:no_man_maps = 1
  let g:ft_man_folding_enable = 1

  " Never load netrw
  let g:loaded_netrw       = 1
  let g:loaded_netrwPlugin = 1

  " VIM
  let g:vimsyn_embed = 'lPr'  " support embedded lua, python and ruby
  let g:vimsyn_folding = 'afp' "fold augroups functions and python script

  " Latex
  let g:tex_fold_enabled=1
  let g:tex_comment_nospell= 1
  let g:tex_verbspell= 0
  let g:tex_conceal=''
endfunction

function! s:get_titlestring() abort
  return (exists('g:valid_device') && has('unix') ? "\uf02d" : '') .
        \ getcwd() . '->%f%m%r'
endfunction
