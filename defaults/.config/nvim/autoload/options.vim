" File:         options.vim
" Description:  Most of set options are done here.
" Author:       Reinaldo Molina <rmolin88@gmail.com>
" Version:        0.0.0
" Last Modified: Mon Mar 16 2020 13:05
" Created: Sep 14 2017 14:47

function! s:vim8_options() abort
  if v:version < 800
    return
  endif

  set softtabstop=-8  " Use shiftwidth
  set sessionoptions+=skiprtp
  set shortmess+=F
  set completeopt+=noselect
  set termguicolors " True color support
  set wildmode+=lastused
  set wildoptions+=fuzzy,pum
  set tagcase=followscs
  set diffopt+=algorithm:patience,linematch:40
endfunction

function! s:vim74_options() abort
  if v:version < 704
    return
  endif

  set breakindent
  set relativenumber
  set shortmess+=c
  set formatoptions+=j

  " Ensure folder exists
  let &undodir= (has('nvim') ? stdpath('cache') : g:std_cache_path) . '/undo//'
  silent! call mkdir(&undodir, "p")
  set undofile
  set conceallevel=0
  " Mon Oct 16 2017 15:22: This speed ups a lot of plugin. Those that have to
  " do with highliting.
  set regexpengine=1
  set colorcolumn=""
endfunction

function! options#Set() abort
  " Some global variables
  let g:sessions_path = g:std_data_path . '/sessions'
  silent! call mkdir(g:sessions_path, "p")

  " Default options that work across all the different version are set here
  " Options specific to nvim are set in options.lua
  " Options specific to vim8 and set in vim8_options()
  set hidden
  set timeout
  set timeoutlen=2000
  " Tab management
  " No tabs in the code. Tabs are expanded to spaces
  set shiftround
  set softtabstop=4
  set shiftwidth=4  " Always set this two values to the same
  set tabstop=4
  " Title
  set title
  set titlelen=90 " Percent of columns
  set updatetime=100
  set display=uhex
  set sessionoptions=buffers,tabpages,curdir,globals
  set foldlevel=99 "" Do not fold code at startup
  set foldmethod=syntax
  set mouse=a
  set background=light " This forces lualine to use the right theme
  set cmdheight=1
  set nospell
  set spelllang=en_us
  set nowrapscan
  set showtabline=1
  set number
  set numberwidth=1
  " Supress messages
  " a - Usefull abbreviations
  " c - Do no show match 1 of 2
  " o and O no enter when openning files
  " s - Do not show search hit bottom
  " t - Truncate message if is too long
  set shortmess=aoOst
  set clipboard=unnamedplus " Sync with system clipboard
  set autowrite " Enable auto write
  set completeopt=menu,menuone
  set formatoptions=croqlnt " tcqj
  set ignorecase " Ignore case
  set pumheight=16 " Maximum number of entries in a popup
  set scrolloff=16 " Lines of context
  set sidescrolloff=16 " Columns of context
  set smartindent " Insert indents automatically
  set wildmode=full,list:full " Command-line completion mode
  set wildoptions=tagfile " Command-line completion mode
  set splitright
  set nosplitbelow
  " Show which line your cursor is on
  set cursorline

  " Sets how neovim will display certain whitespace characters in the editor.
  "  See `:help 'list'`
  "  and `:help 'listchars'`
  set list
  set listchars=tab:>-,trail:-,nbsp:+

  " Fri Apr 03 2020 17:07: Cursor blinking really gets on my nerves
  set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
        \,a:blinkon0-Cursor/lCursor

  set expandtab
  " Tue Nov 13 2018 22:39: Needed by Shuogo/echodoc.vim
  set noshowmode
  " Useful for the find command
  let &path .='.,,,/usr/include/*,/usr/local/include/*,**'
  set backspace=indent,eol,start

  set showmatch     " set show matching parenthesis
  set showcmd       " Show partial commands in the last lines
  set smartcase     " ignore case if search pattern is all lowercase,
  "    case-sensitive otherwise
  set infercase
  set hlsearch      " highlight search terms
  set incsearch     " show search matches as you type
  set history=10000         " remember more commands and search history
  " set complete+=kspell " currently not working
  " Mon Aug 31 2020 00:22:
  " For some crazy reason this disables nvim-lsp
  " set wildignore+=*.o,*.obj,*.bak,*.exe,*.py[co],*.swp,*~,*.pyc,.svn,.git
  " All backups!
  set backup " backup overwritten files
  set writebackup
  " Do not skip a single backup
  set backupskip=
  let &backupdir= (has('nvim') ? stdpath('cache') : g:std_cache_path) . '/backup//'
  silent! call mkdir(&backupdir, "p")
  let &backupext='_bkp'
  " Tue May 21 2019 10:28: Swap is very painful
  " Still haven't found a good use for it
  set noswapfile
  let &directory = (has('nvim') ? stdpath('cache') : g:std_cache_path) . '/swap//'
  silent! call mkdir(&directory, "p")

  " Undofiles
  set undolevels=10000      " use many muchos levels of undo

  "set autochdir " working directory is always the same as the file you are
  "editing
  " Took out options from here. Makes the session script too long and annoying
  " Fri Jan 11 2019 21:39 Dont add resize, and winpos. It causes problems in
  " linux
  " cant remember why I had a timeout len I think it was
  " in order to use <c-j> in cli vim for esc
  " removing it see what happens
  " set ttimeoutlen=0
  " will look in current directory for tags

  if has('cscope')
    set cscopetag cscopeverbose
    if has('quickfix')
      set cscopequickfix=s+,c+,d+,i+,t+,e+
    endif
  endif
  " set matchpairs+=<:>
  set linebreak    "Wrap lines at convenient points
  " Sat Feb 22 2020 16:05: Save only what is necessary
  set viewoptions=cursor,curdir

  " Thu Oct 26 2017 05:13: On small split screens text goes outside of range
  " Fri Jun 15 2018 14:00: These options are better set on case by case basis
  " Fri Jun 15 2018 15:37: Not really
  set nowrap        " wrap lines
  set textwidth=80

  set scroll=8
  set modeline
  set modelines=1
  " Set omni for all filetypes
  " Sun Aug 30 2020 23:58: Damn thing 
  " set omnifunc=syntaxcomplete#Complete
  " Mon Jun 05 2017 11:59: Suppose to Fix cd to relative paths in windows
  let &cdpath = ',' . substitute(substitute($CDPATH,
        \ '[, ]', '\\\0', 'g'), ':', ',', 'g')

  " Status Line
  " If this not and android device and we have no plugins setup "ugly" status
  " line
  set statusline=\ [%n]\                             " buffernr
  set statusline+=\ %<%{StlCwd()}\ %f\ %m%r%w                    " File+path
  set statusline+=\ %y\                             " FileType
  set statusline+=\ %{''.(&fenc!=''?&fenc:&enc).''} " Encoding
  " ,BOM\ " :\ " \ " )}\ " Encoding2
  " set statusline+=\ %{(&bomb?\
  set statusline+=\ %{&ff}\                         " FileFormat (dos/unix..)
  set statusline+=\ %{StlGitBranch()}\                             " gitbranch
  set statusline+=\%=\    " section division
  set statusline+=\ %{StlPomoTime()}\ 
  set statusline+=\ %{StlSession()}\ 
  set statusline+=\ \ row:%l/%L\        " Rownumber/total (%)
  set statusline+=\ col:%03c\                       " Colnr
  set statusline+=\ \ %m%r%w\ %P\ \            " Modified? Readonly? Top/bot.
  set laststatus=2
  " If you want to put color to status line needs to be after command
  " colorscheme. Otherwise this commands clears it the color

  " Performance Settings
  " see :h slow-terminal
  set nocursorcolumn
  set scrolljump=5
  set sidescroll=15 " see help for sidescroll
  " Mon May 01 2017 11:21: This breaks split window highliting
  " Tue Jun 13 2017 20:55: Giving it another try
  " Fri Jun 05 2020 16:17: You knew that it breaks highliting with a low number 
  " since 2017 and still went ahead and had this issue for years :/. Please do 
  " not make it lowe than 180
  set synmaxcol=180 " Will not highlight passed this column #
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

  " Netrw options
  " Tree style
  let g:netrw_liststyle = 3
  augroup NetrwCustoms
    autocmd!
    autocmd FileType netrw
          \ set nonumber |
          \ set relativenumber |
          \ nnoremap <buffer> q :bp<cr>
  augroup END

  " Diff options
  set diffopt=vertical

  augroup BuffTypes
    autocmd!
    autocmd BufReadPost *
          \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit' |
          \   exe "normal! g`\"" |
          \ endif
    if version >= 702
      autocmd BufWinLeave * call clearmatches()
    endif
  augroup END
  augroup Colorscheme
    autocmd!
    autocmd ColorScheme *
          \ hi StatusLine ctermfg=white ctermbg=black guifg=white guibg=black gui=bold |
          \ hi StatusLineNC ctermfg=white ctermbg=black guifg=white guibg=black gui=bold
  augroup END

  if !has('nvim')
    set guitablabel=%N\ %f
    call s:set_colorscheme_by_time()
  endif

  call s:vim8_options()
  call s:vim74_options()
  call s:set_syntax()
  call s:vim_cli()
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
  if v:version >= 802
    let &t_8f = "\<Esc>[38:2:%lu:%lu:%lum"
    let &t_8b = "\<Esc>[48:2:%lu:%lu:%lum"
  endif
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

  if !has('unix')
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
    let &grepprg = "rg $* --vimgrep --smart-case " .
          \ "--follow --fixed-strings --hidden " .
          \ "--glob \"!tags\" --glob \"!cscope.*\" --glob \"!.git/\""
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
  let g:c_space_errors = 1

  " ft-markdown-syntax
  let g:markdown_fenced_languages= [ 'cpp', 'vim', 'dosini' ]
  " This is handled now by Plug 'plasticboy/vim-markdown'
  let g:markdown_folding= 0

  " ft-python-syntax
  " This option also highlights erroneous whitespaces
  let g:python_highlight_all = 1

  " Man
  " let g:no_man_maps = 1
  let g:ft_man_folding_enable = 1

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

function! StlCwd() abort
  if !utils#is_buffer_valid()
    return ''
  endif
  return getcwd() . ' >'
endfunction

function! StlSession() abort
  if !utils#is_buffer_valid()
    return ''
  endif

  if empty(v:this_session)
    return ''
  endif
  return 's:' . fnamemodify(v:this_session, ':t')  " Return just the filename
endfunction

function! StlGitBranch() abort
  if exists("b:gitsigns_head")
    return 'b:' . b:gitsigns_head . ' ' . b:gitsigns_status
  endif
  return '' " Return empty if not in git repo
endfunction

function! StlPomoTime() abort
  if !exists(":PomodoroToggle")
    return '' " Return empty if not in git repo
  endif
  if !has('nvim')
    return '' " Return empty if not in git repo
  endif
  let l:r = v:lua.require'plugin.pomodoro'.get_session_info()
  if empty(l:r)
    return ''
  endif
  return 'p:' . l:r.name . ' ['. l:r.remaining_time_m . ']'
endfunction


function! s:set_colorscheme_by_time() abort
  let period = flux#Check()

  if period == 'night'
    colorscheme morning
  else
    colorscheme desert
  endif
endfunction
