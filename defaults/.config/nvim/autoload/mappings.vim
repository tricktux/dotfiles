" File:         mappings.vim
" Description:  Function that sets all the mappings that are not related to
"               plugins
" Author:       Reinaldo Molina <rmolin88@gmail.com>
" Version:        0.0.0
" Last Modified: Aug 22 2017 12:33
" Created: Aug 22 2017 12:33

function! mappings#Set()
  let g:esc = ['jk', 'kj']
  " Terminal mappings

  " Sun Jun 07 2020 11:23 
  " Auto center screen mappings. There some above as well
  " Folding
  " Folding select text then S-f to fold or just S-f to toggle folding
  nnoremap <c-d> <c-d>zz
  nnoremap * *zz
  nnoremap # #zz
  nnoremap ]c ]czz
  nnoremap [c [czz
  nnoremap <C-z> zzze
  nnoremap <C-c> zMzz
  nnoremap <C-n> zRzz
  nnoremap <C-x> zazz
  " dont use <C-a> it conflicts with tmux prefix
  nnoremap <C-j> zjzz
  nnoremap <C-k> zkzz
  " Mon Jun 08 2020 13:27: It's annoying 
  " inoremap <ENTER> <ENTER><ESC>zzi
  nnoremap <S-CR> O<Esc>zz
  nnoremap G Gzz
  nnoremap x xzz

  " Sun Dec 09 2018 17:15: 
  " This extends p in visual mode (note the noremap), so that if you paste from 
  " the unnamed (ie. default) register, that register content is not replaced by 
  " the visual selection you just pasted over–which is the default behavior. 
  " This enables the user to yank some text and paste it over several places in 
  " a row, without using a named
  " Obtained from: https://vimways.org/2018/for-mappings-and-a-tutorial/
  xnoremap <silent> p p:if v:register == '"'<bar>let @@=@0<bar>endif<cr>

  " j and k
  " Display line movements unless preceded by a count and
  " Save movements larger than 5 lines to the jumplist. Use Ctrl-o/Ctrl-i.
  " Added also to center screen on cursor
  nnoremap <expr> j v:count ?
        \ (v:count > 5 ? "m'" . v:count : '') . 'jzz' : 'gjzz'
  nnoremap <expr> k v:count ?
        \ (v:count > 5 ? "m'" . v:count : '') . 'kzz' : 'gkzz'

  nnoremap g; g;zz
  nnoremap g, g,zz

  nnoremap <c-o> <c-o>zz
  nnoremap <c-i> <c-i>zz

  " File mappings <leader>f
  nmap <leader>fj <plug>file_browser
  nnoremap <plug>file_browser :e .<cr>

  nmap <leader>W <plug>get_passwd
  nnoremap <plug>get_passwd :silent call passwd#SelectPasswdFile()<cr>

  " Don't paste the deleted word, paste the last copied word, hopefully
  nnoremap <s-p> :normal! "0p<cr>

  nnoremap <c-h> :nohlsearch<cr>
  " Automatically insert date
  nnoremap <silent> <F5> a<Space><c-r>=strftime("%a %b %d %Y %H:%M")<cr><esc>
  " Designed this way to be used with snippet md header
  vnoremap <silent> <F5> s<c-r>=strftime("%a %b %d %Y %H:%M")<cr>
  inoremap <silent> <F5> <c-r>=strftime("%a %b %d %Y %H:%M")<cr>
  inoremap <silent> <F6> <c-r>=strftime("%V")<cr>
  inoremap <silent> <F7> <c-r>=strftime("%B")<cr>
  " Auto indent pasted text
  nnoremap p :normal! p=`]<cr>

  " Vim-unimpaired similar mappings
  " Do not overwrite [s, [c, [f

  nnoremap <silent> ]y :call <SID>yank_from('+')<cr>
  nnoremap <silent> [y :call <SID>yank_from('-')<cr>

  nnoremap <silent> ]d :call <SID>delete_line('+')<cr>
  nnoremap <silent> [d :call <SID>delete_line('-')<cr>

  nnoremap <silent> ]o :call <SID>comment_line('+')<cr>
  nnoremap <silent> [o :call <SID>comment_line('-')<cr>

  nnoremap <silent> ]m :m +1<cr>
  nnoremap <silent> [m :m -2<cr>

  " Quickfix and Location stuff
  " nnoremap <silent> <s-q> :call quickfix#ToggleList("Quickfix List", 'c')<cr>
  nnoremap ]q :cnext<cr>
  nnoremap [q :cprevious<cr>

  " nnoremap <silent> <s-u> :call quickfix#ToggleList("Location List", 'l')<cr>
  nnoremap ]l :lnext<cr>
  nnoremap [l :lprevious<cr>

  nnoremap ]t :exec 'tjump ' . expand('<cword>')<cr>
  nnoremap [t :pop<cr>

  " Capital F because [f is go to file and this is rarely used
  " ]f native go into file.
  " [f return from file
  nnoremap [f <c-o>

  " Scroll to the sides z{l,h} and up and down
  nnoremap ]z 10zl
  nnoremap ]Z 10<c-e>
  nnoremap [z 10zh
  nnoremap [Z 10<c-y>

  nnoremap <a-s> :vs<cr>
  nnoremap <a-]> gt
  nnoremap <a-[> gT
  for l:idx in [1,2,3,4,5,6,7,8,9]
    execute 'nnoremap <silent> <leader>' . l:idx . ' :call <SID>switch_or_set_tab(' . l:idx. ')<cr>'
  endfor

  " Create an undo break point. Mark current possition. Go to word. Fix and come back.
  nnoremap ]S :call <sid>fix_next_word()<cr>
  nnoremap [S :call <sid>fix_previous_word()<cr>

  " These are mappings for Insert, Command-line, and Lang-Arg
  " insert in the middle of whole word search
  cnoremap <a-w> \<\><Left><Left>
  " insert visual selection search
  cnoremap <c-u> <c-r>=expand("<cword>")<cr>
  cnoremap <c-s> %s/
  cnoremap <c-j> <cr>
  cnoremap <c-p> <up>

  cnoremap <silent> <expr> <cr> <sid>center_search()
  inoremap <c-f> <right>
  noremap! <c-b> <left>
  " Sun Sep 17 2017 14:21: this will not work in vim
  noremap! <a-b> <s-left>
  noremap! <a-f> <s-right>
  inoremap <c-d> <c-g>u<del>
  cnoremap <c-d> <del>
  inoremap <a-t> <c-d>

  " Fri Sep 29 2017 14:20: Break up long text into smaller, better undo
  " chunks. See :undojoin
  " For normal text typing
  inoremap . .<c-g>u
  inoremap , ,<c-g>u
  inoremap ? ?<c-g>u
  inoremap ! !<c-g>u
  inoremap <c-h> <c-g>u<c-h>

  " For cpp
  inoremap ; ;<c-g>u
  inoremap = =<c-g>u

  nmap <leader>ag <plug>tags_generate
  nnoremap <silent> <plug>tags_generate :call ctags#NvimSyncCtagsCscope()<cr>
  nmap <leader>al <plug>tags_load
  nnoremap <silent> <plug>tags_load :call ctags#LoadCscopeDatabse()<cr>

  " Window movement
  " move between windows
  if !has('nvim')

    if has('terminal') || has('nvim')
      " See plugin.vim - neoterm
      " There are more mappins in the [,] section
      nmap <M-`> <plug>terminal_toggle
      nnoremap <plug>terminal_toggle :vs<cr><bar>:term<cr>
      nmap <localleader>e <plug>terminal_send_line
      xmap <localleader>e <plug>terminal_send
      nmap <localleader>E <plug>terminal_send_file
    endif


   if exists('*Focus') && executable('i3-vim-nav')
      " i3 integration
      nnoremap <A-l> :call Focus('right', 'l')<cr>
      nnoremap <A-h> :call Focus('left', 'h')<cr>
      nnoremap <A-k> :call Focus('up', 'k')<cr>
      nnoremap <A-j> :call Focus('down', 'j')<cr>
    elseif has('unix') && executable('tmux') && exists('$TMUX')
      nnoremap <silent> <A-h> :call <SID>tmux_move('h')<cr>
      nnoremap <silent> <A-j> :call <SID>tmux_move('j')<cr>
      nnoremap <silent> <A-k> :call <SID>tmux_move('k')<cr>
      nnoremap <silent> <A-l> :call <SID>tmux_move('l')<cr>
    else
      nnoremap <silent> <A-l> <C-w>lzz
      nnoremap <silent> <A-h> <C-w>hzz
      nnoremap <silent> <A-k> <C-w>kzz
      nnoremap <silent> <A-j> <C-w>jzz
    endif
    nnoremap <silent> <A-S-l> <C-w>>
    nnoremap <silent> <A-S-h> <C-w><
    nnoremap <silent> <A-S-k> <C-w>-
    nnoremap <silent> <A-S-j> <C-w>+
  endif

  inoremap <silent> <c-s> <c-r>=<SID>fix_previous_word()<cr>

  " Search <Leader>S
  " Tried ack.vim. Discovered that nothing is better than grep with ag.
  " search all type of files
  " Search visual selection text
  xnoremap // y/<C-R>"<cr>

  nmap <c-p> <plug>current_folder_file_browser
  nnoremap <plug>current_folder_file_browser :find<space>
  " Buffers Stuff <Leader>b?
  nmap <s-k> <plug>buffer_browser
  nnoremap <plug>buffer_browser :buffers<cr>:buffer<Space>
  nnoremap <leader>bs :buffers<cr>:buffer<Space>
  nnoremap <leader>bd :bp\|bw #\|bd #<cr>
  nnoremap <S-j> :b#<cr>
  " deletes all buffers
  nnoremap <leader>bl :%bd<cr>

  " Version Control <Leader>v?
  " For all this commands you should be in the svn root folder
  " Add all files
  " nnoremap <silent> <leader>vs :call <SID>version_control_command('status')<CR>
  " nnoremap <silent> <leader>vl :call <SID>version_control_command('alog')<CR>
  " nnoremap <silent> <leader>vL :call <SID>version_control_command('clog')<CR>
  " nnoremap <silent> <leader>vc :call <SID>version_control_command('commit')<CR>
  " nnoremap <silent> <leader>vd :call <SID>version_control_command('diff')<CR>

  " nnoremap <Leader>vA :!svn add . --force<cr>
  " Add specific files
  " nnoremap <Leader>va :!svn add --force
  " Commit using typed message
  " nnoremap <Leader>vc :call <SID>svn_commit()<cr>
  " Commit using File for commit content
  " nnoremap <Leader>vC :!svn commit --force-log -F %<cr>
  " nnoremap <Leader>vd :!svn rm --force
  " revert previous commit
  "nnoremap <Leader>vr :!svn revert -R .<cr>
  " nnoremap <Leader>vl :!svn cleanup .<cr>
  " use this command line to delete unrevisioned or "?" svn files
  " nnoremap <Leader>vL :!for /f "tokens=2*" %i in ('svn status ^| find "?"') do
  " del %i<cr>
  " nnoremap <Leader>vs :!svn status .<cr>
  " nnoremap <Leader>vu :!svn update .<cr>
  " Overwritten from plugin.vim
  " nnoremap <Leader>vo :!svn log .<cr>
  " nnoremap <Leader>vi :!svn info<cr>

  " Comments <Leader>o
  nnoremap <leader>oI :call utils#CommentReduceIndent()<cr>
  " mapping ol conflicts with mapping o to new line
  nnoremap <leader>oe :call utils#EndOfIfComment()<cr>
  nnoremap <leader>ou :call utils#UpdateHeader()<cr>
  nnoremap <leader>ot :call utils#TodoAdd()<cr>
  nnoremap <leader>od :call utils#CommentDelete()<cr>
  " Comment Indent Increase/Reduce
  nnoremap <leader>oi :call utils#CommentIndent()<cr>

  " Edit file at location <Leader>e?
if !has('nvim-0.5')
  nnoremap <leader>ea :call <sid>add_file(getcwd())<cr>
  nnoremap <leader>tc :call <sid>toggle_conceal<cr>
  " Wiki mappings <Leader>w?
  nnoremap <silent> <leader>wo :call <SID>wiki_open()<cr>
  nnoremap <silent> <leader>wa :call <SID>wiki_add()<cr>
  nnoremap <silent> <leader>ws :call utils#WikiSearch()<cr>
  nnoremap <silent> <leader>wi :call <sid>wiki_open('index.md')<cr>
  nnoremap <silent> <leader>wb :call <sid>wiki_open('brain_dump.md')<cr>
  nnoremap <silent> <leader>wr :call <sid>wiki_open('random.md')<cr>
  nnoremap <silent> <leader>ww :call <sid>wiki_open('weekly_log_' .
  \ strftime('%Y') . '.md')<cr>
  nnoremap <silent> <leader>wm :call <sid>wiki_open('monthly_log_' .
  \ strftime('%Y') . '.md')<cr>
  " Edit plugin
  nnoremap <leader>ep :call utils#PathFileFuzzer(g:vim_plugins_path)<cr>
  " Edit Vimruntime
  nnoremap <leader>ev :call utils#PathFileFuzzer(fnameescape($VIMRUNTIME))<cr>
  nnoremap <leader>ed :call utils#PathFileFuzzer(g:dotfiles)<cr>
  nnoremap <leader>eh :call utils#PathFileFuzzer($HOME)<cr>
  if (!has('unix'))
    nnoremap <leader>eC :call utils#PathFileFuzzer('C:\')<cr>
    nnoremap <leader>eD :call utils#PathFileFuzzer('D:\')<cr>
    nnoremap <leader>eP :e +<cr>
    endif
    nnoremap <leader>ec :call utils#PathFileFuzzer(getcwd())<cr>
    nnoremap <leader>el :call utils#PathFileFuzzer(input
    \ ('Folder to recurse: ', "", "file"))<cr>
  endif
  nnoremap <Leader>ei :e

  " mnemonic space bar
  vnoremap <leader>l y:call writefile([@"], '/tmp/todo.txt')<cr>
  nnoremap <leader>la :call <sid>todo_add()<cr>
  nnoremap <leader>ld :call <sid>todo_remove()<cr>
  " nmap <leader>et <plug>edit_todo
  " if !hasmapto('<plug>edit_todo')
  " nnoremap <silent> <plug>edit_todo :execute
  " \ ('edit ' . g:dotfiles . '/TODO.md')<cr>
  " endif

endfunction

function! mappings#SaveSession(...) abort
  let session_path = stdpath('data') . '/sessions/'
  " if session name is not provided as function argument ask for it
  silent execute "wall"
  let dir = getcwd()
  silent execute "lcd ". session_path
  let session_name = input("Enter save session name:", "", "file")
  if empty(session_name)
    return
  endif
  " Ensure session_name ends in .vim
  if match(session_name, '.vim', -4) < 0
    " Append extention if was not provided
    let session_name .= '.vim'
  endif
  " Restore current dir
  silent! execute "lcd " . dir
  execute "Obsession " . session_path . session_name
  " return
  " endif

  " " If this a session we have saved before. Auto save it
  " if (empty(v:this_session))
  " return
  " endif
  " silent! execute "mksession! " . v:this_session
endfunction

function! mappings#LoadSession(...) abort
  let l:session_path = stdpath('data') . '/sessions/'

  if empty(finddir('sessions', stdpath('data')))
    if &verbose > 0
      echoerr '[mappings#LoadSession]: Folder ' .
            \ l:session_path . ' does not exists'
    endif
    return -1
  endif

  " Save this current session
  if exists(':Obsession')
    " Check if there is an ongoing session
    if ObsessionStatus() ==# '[$]'
      " If there is save it before leaving
      silent execute 'Obsession ' . v:this_session
    endif
  else
    silent execute 'mksession! ' . v:this_session
  endif
  " Delete all buffers. Otherwise they will be added to the new session
  silent execute ':%bdelete!'

  " If there are more than 10 sessions, use fanzy fuzzers
  let l:fuzzers = 0
  let l:sessions = glob(l:session_path . '*.vim', 0, 1)
  if len(l:sessions) > 10
    let l:fuzzers = 1
  endif

  " Logic path when not called at startup
  if a:0 >= 1
    let l:session_name = l:session_path . a:1
    if !filereadable(l:session_name)
      if &verbose > 0
        echoerr '[mappings#LoadSession]: File ' .
              \ l:session_name . ' not readabale'
      endif
      return -1
    endif
    if &verbose > 0
      echomsg '[mappings#LoadSession]: Loading session: ' .
            \ l:session_name . '...'
    endif
    silent execute 'source ' . l:session_name
    return
  endif

  if l:fuzzers && exists(':FZF')
    call fzf#run(fzf#wrap({
          \ 'source': l:sessions,
          \ 'sink': 'source',
          \ }))
    return
  endif

  if l:fuzzers && exists(':Denite')
    let l:session_name = utils#DeniteYank(l:session_path)
    if !filereadable(l:session_path . l:session_name)
      return
    endif
    silent execute 'source ' . l:session_path . l:session_name
    return
  endif

  let l:dir = getcwd()
  execute 'lcd '. l:session_path
  let l:session_name = input('Load session:', "", 'file')
  silent execute 'source ' . l:session_path . l:session_name
  silent execute 'lcd ' . l:dir
endfunction

" Tue May 15 2018 09:07: Forced to make it global. <expr> would not work with s:
" function
function! s:center_search() abort
  let cmdtype = getcmdtype()
  if cmdtype ==# '/' || cmdtype ==# '?'
    return "\<cr>zz"
  endif
  return "\<cr>"
endfunction

function! s:yank_from(sign) abort
  let in = s:parse_line_mod_input('Yank',  a:sign)
  execute "normal! :" . in . "y\<CR>p"
endfunction

" msg - {Comment, Delete, Paste, Yank}
" sign - {+,-}
" Returns: Modified input
function! s:parse_line_mod_input(msg, sign) abort
  let in = a:sign . input(a:msg . " Line:")
  let comma = stridx(in, ',')
  if comma > -1
    return strcharpart(in, 0,comma+1) . a:sign . strcharpart(in, comma+1)
  endif

  return in
endfunction

function! s:delete_line(sign) abort
  let in = s:parse_line_mod_input('Delete',  a:sign)
  execute "normal! :" . in . "d\<CR>``"
endfunction

function! s:comment_line(sign) abort
  if !exists("*NERDComment")
    echo "Please install NERDCommenter"
    return
  endif

  let in = s:parse_line_mod_input('Comment',  a:sign)
  execute "normal! mm:" . in . "\<CR>"
  execute "normal! :call NERDComment(\"n\", \"Toggle\")\<CR>`m"
endfunction

function! s:next_match_and_center() abort
  execute 'nN' . v:searchforward
  execute 'normal! zz'
endfunction

function! s:tmux_move(direction) abort
  let wnr = winnr()
  silent! execute 'wincmd ' . a:direction
  " If the winnr is still the same after we moved, it is the last pane
  if wnr == winnr()
    call system('tmux select-pane -' . tr(a:direction, 'phjkl', 'lLDUR'))
  endif
endfunction

function! s:fix_previous_word() abort
  let save_cursor = getcurpos()
  normal! [s1z=
  call setpos('.', save_cursor)
  return ''
endfunction

function! s:fix_next_word() abort
  let save_cursor = getcurpos()
  normal! ]s1z=
  call setpos('.', save_cursor)
  return ''
endfunction

" Should be performed on root .svn folder
function! s:svn_commit() abort
  execute "!svn commit -m \"" . input("Commit comment:") . "\""
endfunction

function! s:wiki_open(...) abort
  if !exists('g:wiki_path') || empty(glob(g:wiki_path))
    echoerr 'Variable g:wiki_path not set or path doesnt exist'
    return
  endif

  if a:0 > 0
    execute "e " . g:wiki_path . '/'.  a:1
    return
  endif

  if has('nvim-0.5')
    lua require('utils.utils').file_fuzzer(vim.g.wiki_path)
  else
    call utils#PathFileFuzzer(g:wiki_path)
  endif
endfunction

function! s:wiki_add() abort
  if !exists('g:wiki_path') || empty(glob(g:wiki_path))
    echoerr 'Variable g:wiki_path not set or path doesnt exist'
    return
  endif

  return s:add_file(g:wiki_path)
endfunction

" Use current 'grepprg' to search files for text
"   filteype - Possible values: 1 - Search only files of type 'filetype'. Any
"               other value search all types of values
"   word - Possible values: 1 - Search word under the cursor. Otherwise prompt
"   for search word
function! s:filetype_search(filetype, word) abort
  let grep_engine = &grepprg

  if a:word == 1
    let search = expand("<cword>")
  else
    let search = input("Please enter search word:")
  endif

  if grep_engine =~# 'rg'
    let file_type_search = '-t ' . ctags#VimFt2RgFt()
  elseif grep_engine =~# 'ag'
    let file_type_search = '--' . &filetype
  else
    " If it is not a recognized engine do not do file type search
    exe ":grep! " . search
    if &verbose > 0
      echomsg printf("grepprg = %s", grep_engine)
      echomsg printf("filetype search = %d", a:filetype)
      echomsg printf("file_type_search = %s", file_type_search)
      echomsg printf("search word = %s", search)
      echomsg printf("cwd = %s", getcwd())
    endif
    copen 20
    return
  endif

  if a:filetype == 1
    exe ":silent grep! " . file_type_search . ' ' . search
  else
    exe ":silent grep! " . search
  endif

  copen 20
  if &verbose > 0
    echomsg printf("grepprg = %s", grep_engine)
    echomsg printf("filetype search = %d", a:filetype)
    echomsg printf("file_type_search = %s", file_type_search)
    echomsg printf("search word = %s", search)
    echomsg printf("cwd = %s", getcwd())
  endif
endfunction

function! s:grep() abort
  let msg = 'Searching inside "' . getcwd() . '". Choose:'
  let choice = "&J<cword>/". &ft . "\n&K<any>/". &ft .
        \ "\n&L<cword>/all_files\n&;<any>/all_files"
  let c = confirm(msg, choice, 1)

  if c == 1
    " Search '&filetype' type of files, and word under the cursor
    call s:filetype_search(1, 1)
  elseif c == 2
    " Search '&filetype' type of files, and prompt for search word
    call s:filetype_search(1, 8)
  elseif c == 3
    " Search all type of files, and word under the cursor
    call s:filetype_search(8, 1)
  else
    " Search all type of files, and prompt for search word
    call s:filetype_search(8, 8)
  endif
endfunction

function! s:switch_or_set_tab(tab_num) abort
  let l:tabs_num = len(gettabinfo())

  if &verbose > 0
    echomsg string(l:tabs_num)
  endif

  if l:tabs_num < a:tab_num
    execute 'tabnew'
    return
  endif

  execute 'normal! ' . a:tab_num . 'gt'
endfunction

function! s:add_file(path) abort
  if empty(a:path) || empty(glob(a:path))
    echoerr 'Input path doesnt exist'
    return
  endif

  let l:cwd = getcwd()
  execute 'lcd ' . a:path
  let l:new_file = input('Please enter name for new wiki:', '', 'file')

  if empty(l:new_file)
    return
  endif

  let l:splitter = has('unix') ? '/' : '\'

  " Normalize unix splitters in case we are in windows
  let l:new_file = substitute(l:new_file, '/', l:splitter, "g")

  if l:new_file[0] !=# l:splitter
    let l:new_file = l:splitter . l:new_file
  endif

  let l:new_file = a:path . l:new_file
  if &verbose > 0
    echomsg printf('[add_file]: l:new_file = "%s"', l:new_file)
  endif

  " Find passed dir
  let l:last_folder = strridx(l:new_file, l:splitter)
  let l:new_folder = l:new_file[0:l:last_folder-1]
  if &verbose > 0
    echomsg printf('[wiki_add]: l:new_folder = "%s"', l:new_folder)
  endif

  if !isdirectory(l:new_folder)
    if &verbose > 0
      echomsg printf('[wiki_add]: Created new folder = "%s"', l:new_folder)
    endif
    call mkdir(l:new_folder, 'p')
  endif

  execute 'lcd ' . l:cwd
  execute 'edit ' . l:new_file
endfunction

function! mappings#SetWhichKeyMap() abort
  " Define prefix dictionary
  let g:which_key_leader_map =  {}

  let g:which_key_leader_map.t = {
        \ 'name' : '+toggle',
        \ 'j' : 'file_browser',
        \ 'f' : 'focus_plugin',
        \ 'e' : 'terminal',
        \ 't' : 'tagbar',
        \ 's' : 'spelling',
        \ 'o' : 'alternative_commenter',
        \ }

  let g:which_key_leader_map.c = {
        \ 'name' : '+cd',
        \ 'r' : 'root',
        \ 'd' : 'current_file',
        \ 'u' : 'one_folder_up',
        \ 'c' : 'display_curr_work_dir',
        \ }

  let l:wings = {
        \ 'name' : '+wings',
        \ '1' : 'OneWins1',
        \ '2' : 'OneWins2',
        \ 'a' : 'wings-dev',
        \ 's' : 'SupportFiles',
        \ }
  let l:edit_random_file_type = {
        \ 'name' : '+random_file_type',
        \ 'c' : ['UtilsEditTmpFileCpp', 'cpp'],
        \ 'p' : ['UtilsEditTmpFilePython', 'python'],
        \ 'm' : ['UtilsEditTmpFileMarkdown', 'markdown'],
        \ 'v' : ['UtilsEditTmpFileVim', 'vim'],
        \ 'l' : ['UtilsEditTmpFileLua', 'lua'],
        \ 'g' : ['UtilsEditTmpFileGen', 'general_enter_extension'],
        \ }

  let g:which_key_leader_map.e = {
        \ 'name' : '+edit',
        \ 'd' : 'dotfiles',
        \ 'c' : 'current_dir',
        \ 'l' : 'specific_location',
        \ 't' : l:edit_random_file_type,
        \ 'p' : 'plugins_path',
        \ 'v' : 'vimruntime',
        \ 'w' : l:wings,
        \ 'a' : 'add folder/file',
        \ }

  let l:sessions = {
        \ 'name' : '+sessions',
        \ 's' : 'save',
        \ 'l' : 'load',
        \ 'e' : 'load_default',
        \ }
  let g:which_key_leader_map.j = {
        \ 'name' : '+misc',
        \ '2' : '2_char_indent',
        \ '4' : '4_char_indent',
        \ '8' : '8_char_indent',
        \ 'w' : 'wings_syntax',
        \ '.' : 'repeat_last_command',
        \ 's' : 'sync_from_start',
        \ 'c' : 'count_last_search',
        \ '-' : ['UtilsFontZoomOut', 'font_decrease'],
        \ '=' : ['UtilsFontZoomIn', 'font_increase'],
        \ 'e' : l:sessions,
        \ }

  let g:which_key_leader_map.b = {
        \ 'name' : '+buffers/Bookmarks',
        \ 'd' : 'delete_current',
        \ 'l' : 'delete_all',
        \ }

  let g:which_key_leader_map.n = {
        \ 'name' : '+num_representation',
        \ 'h' : 'ascii_to_hex',
        \ 'c' : 'hex_to_ascii',
        \ 'r' : 'radical_viewer',
        \ 'a' : 'get_ascii_cursor',
        \ }

  let g:which_key_leader_map.v = {
        \ 'name' : '+version_control',
        \ 's' : 'status',
        \ 'a' : 'add',
        \ 'c' : 'commit',
        \ 'p' : 'push',
        \ 'u' : 'pull/update',
        \ 'l' : 'log',
        \ 'S' : ['SignifyToggle' ,'signify_toggle'],
        \ 'd' : ['SignifyDiff' ,'signify_diff'],
        \ }

  let g:which_key_leader_map.w = {
        \ 'name' : '+wiki',
        \ 'o' : 'open',
        \ 'a' : 'add',
        \ 's' : 'search',
        \ }

  let g:which_key_leader_map.o = {
        \ 'name' : '+comments',
        \ 'I' : 'reduce_indent',
        \ 'i' : 'increase_indent',
        \ 'a' : 'append',
        \ 'u' : 'update_header_date',
        \ 'e' : 'end_of_if_comment',
        \ 't' : 'add_todo',
        \ 'd' : 'delete',
        \ }

  let g:which_key_leader_map.P = {
        \ 'name' : '+plugins',
        \ 'i' : ['PlugInstall', 'install'],
        \ 'u' : ['PlugUpdate', 'update'],
        \ 'r' : ['UpdateRemotePlugins', 'update_remote_plugins'],
        \ 'g' : ['PlugUpgrade', 'upgrade_vim_plug'],
        \ 's' : ['PlugSearch', 'search'],
        \ 'l' : ['PlugClean', 'clean'],
        \ }

  " Thu Oct 01 2020 16:50: These are telescope alternatives.
  " However, let's have best of both worlds.
  " Let's leave telescope for buffer and mru and fzf for these other useful
  nnoremap <leader>; :lua require('telescope.builtin').commands()<cr>
  nnoremap <leader>: :lua require('telescope.builtin').command_history()<cr>
  nnoremap <leader>fh :lua require('telescope.builtin').help_tags()<cr>
  " nnoremap <leader>? :lua require('telescope.builtin').live_grep()<cr>
  " nnoremap <leader>f; :lua require('telescope.builtin').commands()<cr>
  " nnoremap <leader>f/ :lua require('telescope.builtin').commands_history()<cr>
  " let g:which_key_leader_map.f = {
        " \ 'name' : '+fuzzers',
        " \ 'b' : ['lua require("telescope.builtin").buffers()', 'buffers'],
        " \ 'f' : ['lua require("telescope.builtin").find_files()', 'files'],
        " \ 'l' : ['lua require("telescope.builtin").current_buffer_fuzzy_find()', 'lines_all_buffers'],
        " \ ';' : 'command_history',
        " \ '/' : 'search_history',
        " \ 'h' : ['lua require("telescope.builtin").help_tags()', 'helptags'],
        " \ 'c' : ['lua require("telescope.builtin").commands()', 'commands'],
        " \ 'C' : ['lua require("telescope.builtin").commands_history()', 'commands_history'],
        " \ }
  " These funky command names do not work when mapped directly in dictionary
  " nnoremap <leader>; :Commands<cr>
  " nnoremap <leader>: :History:<cr>
  nnoremap <leader>? :Rg<cr>
  nnoremap <leader>f; :History:<cr>
  nnoremap <leader>f/ :History/<cr>
  nnoremap <leader>fg :GFiles?<cr>
  let g:which_key_leader_map.f = {
        \ 'name' : '+fuzzers',
        \ 'b' : ['Buffers', 'buffers'],
        \ 'f' : ['Files', 'files'],
        \ 'g' : 'git_files_status',
        \ 'G' : ['GFiles', 'git_files'],
        \ 'o' : ['Colors', 'colorschemes'],
        \ 'l' : ['Lines', 'lines_all_buffers'],
        \ 'L' : ['BLines', 'lines_current_buffer'],
        \ 't' : ['BTags', 'tags_current_buffer'],
        \ 'T' : ['Tags', 'tags_all_buffers'],
        \ ';' : 'command_history',
        \ '/' : 'search_history',
        \ 'F' : ['History', 'files_history'],
        \ 's' : ['Snippets', 'ultisnippets'],
        \ 'h' : 'helptags',
        \ 'y' : ['Filetypes', 'filetypes'],
        \ 'm' : ['Maps', 'maps'],
        \ 'c' : ['Commands', 'commands'],
        \ 'p' : ['BCommits', 'git_commits_current_buffer'],
        \ 'P' : ['Commits', 'git_commits'],
        \ 'W' : ['Windows', 'windows'],
        \ }

  let g:which_key_leader_map.d = 'duplicate_char'
  let g:which_key_leader_map.p = 'paste_from_system'
  let g:which_key_leader_map.y = 'yank_to_system'
  let g:which_key_leader_map.C = ['Calendar', 'calendar']

  " This mappings are needed so that you can use it
  nnoremap gg gg
  xnoremap gg gg
  nnoremap gd gd
  nnoremap gD gD
  nnoremap gq gq
  xnoremap gq gq
  nnoremap gv gv
  nnoremap gu gu
  nnoremap gU gU
  nnoremap g8 g8
  nnoremap g< g<
  nnoremap g? g?
  xnoremap g? g?

  " {Dec,Inc}rease list of number
  xnoremap gA g<c-a>
  xnoremap gX g<c-x>

  let g:which_key_localleader_map = {}
  let g:which_key_localleader_map.g = 'which_key_ignore'
  let g:which_key_localleader_map.d = 'which_key_ignore'
  let g:which_key_localleader_map.D = 'which_key_ignore'
  let g:which_key_localleader_map[';'] = 'which_key_ignore'
  let g:which_key_localleader_map.q = 'which_key_ignore'
  let g:which_key_localleader_map['%'] = 'which_key_ignore'
  let g:which_key_localleader_map.C = 'which_key_ignore'
  let g:which_key_localleader_map.v = 'which_key_ignore'
  let g:which_key_localleader_map['8'] = 'print_hex'
  let g:which_key_localleader_map['<'] = 'print_prev_command_output'
  let g:which_key_localleader_map['?'] = 'rot13_encode_motion'
  let g:which_key_localleader_map['q'] = 'format_motion'
  let g:which_key_localleader_map['~'] = 'swap_case_motion'

  " Note: Do not add localleader mappings to the which_key_localleader_map
  " As they will show up for all buffers. Unless they are global of course

  nnoremap ]] ]]
  nnoremap ]) ])
  nnoremap ]} ]}
  nnoremap [[ [[
  nnoremap [( [(
  nnoremap [{ [{
  nnoremap [/ [/
  nnoremap ]/ ]/
  nnoremap ]c ]c
  nnoremap [c [c
  nnoremap ]# ]#
  nnoremap [# [#
  nnoremap ]f gf
  xnoremap ]f gf
  nnoremap ]i [<c-i>
  nnoremap [i [<c-i>
  nnoremap ]I <c-w>i<c-w>L
  nnoremap [I <c-w>i<c-w>H
  nnoremap ]e [<c-d>
  nnoremap [e [<c-d>
  nnoremap ]E <c-w>d<c-w>L
  nnoremap [E <c-w>d<c-w>H
  nnoremap ]s ]s
  nnoremap [s [s
  let g:which_key_right_bracket_map = {}
  let g:which_key_right_bracket_map.c = 'next_diff'
  let g:which_key_right_bracket_map.p = ['diffput', 'diffput']
  let g:which_key_right_bracket_map.g = ['diffget', 'diffget']
  let g:which_key_right_bracket_map.y = 'yank_from_next_lines'
  let g:which_key_right_bracket_map.d = 'delete_next_lines'
  let g:which_key_right_bracket_map.o = 'comment_next_lines'
  let g:which_key_right_bracket_map.m = 'move_line_below'
  let g:which_key_right_bracket_map.q = 'next_quickfix_item'
  let g:which_key_right_bracket_map.l = 'next_location_list_item'
  let g:which_key_right_bracket_map.t = 'goto_tag_under_cursor'
  let g:which_key_right_bracket_map.T = 'goto_tag_under_cursor_on_right_win'
  let g:which_key_right_bracket_map.f = 'goto_file_under_cursor'
  let g:which_key_right_bracket_map.F = 'goto_file_under_cursor_on_right_win'
  let g:which_key_right_bracket_map.i = 'goto_include_under_cursor'
  let g:which_key_right_bracket_map.I = 'goto_include_under_cursor_on_right_win'
  let g:which_key_right_bracket_map.e = 'goto_define_under_cursor'
  let g:which_key_right_bracket_map.E = 'goto_define_under_cursor_on_right_win'
  let g:which_key_right_bracket_map.z = 'scroll_right'
  let g:which_key_right_bracket_map.Z = 'scroll_up'
  let g:which_key_right_bracket_map.s = 'goto_next_spell_error'
  let g:which_key_right_bracket_map.S = 'fix_next_spell_error'
  let g:which_key_right_bracket_map[']'] = 'goto_next_function'
  let g:which_key_right_bracket_map[')'] = 'goto_next_unmatched_parenthesis'
  let g:which_key_right_bracket_map['}'] = 'goto_next_unmatched_brace'
  let g:which_key_right_bracket_map['/'] = 'goto_next_comment'
  let g:which_key_right_bracket_map['#'] = 'goto_next_unmatched_defined_if'
  let g:which_key_right_bracket_map['"'] = 'which_key_ignore'
  let g:which_key_right_bracket_map['['] = 'which_key_ignore'
  let g:which_key_right_bracket_map['%'] = 'which_key_ignore'

  let g:which_key_left_bracket_map = {}
  let g:which_key_left_bracket_map.c = 'prev_diff'
  let g:which_key_left_bracket_map.p = ['diffput', 'diffput']
  let g:which_key_left_bracket_map.g = ['diffget', 'diffget']
  let g:which_key_left_bracket_map.y = 'yank_from_prev_lines'
  let g:which_key_left_bracket_map.d = 'delete_prev_lines'
  let g:which_key_left_bracket_map.o = 'comment_prev_lines'
  let g:which_key_left_bracket_map.m = 'move_line_up'
  let g:which_key_left_bracket_map.q = 'prev_quickfix_item'
  let g:which_key_left_bracket_map.l = 'prev_location_list_item'
  let g:which_key_left_bracket_map.t = 'pop_tag_stack'
  let g:which_key_left_bracket_map.T = 'goto_tag_under_cursor_on_left_win'
  let g:which_key_left_bracket_map.f = 'go_back_one_file'
  let g:which_key_left_bracket_map.F = 'goto_file_under_cursor_on_left_win'
  let g:which_key_left_bracket_map.i = 'goto_include_under_cursor'
  let g:which_key_left_bracket_map.I = 'goto_include_under_cursor_on_left_win'
  let g:which_key_left_bracket_map.e = 'goto_define_under_cursor'
  let g:which_key_left_bracket_map.E = 'goto_define_under_cursor_on_left_win'
  let g:which_key_left_bracket_map.z = 'scroll_left'
  let g:which_key_left_bracket_map.Z = 'scroll_down'
  let g:which_key_left_bracket_map.s = 'goto_prev_spell_error'
  let g:which_key_left_bracket_map.S = 'fix_prev_spell_error'
  let g:which_key_left_bracket_map['['] = 'goto_prev_function'
  let g:which_key_left_bracket_map['('] = 'goto_prev_unmatched_parenthesis'
  let g:which_key_left_bracket_map['{'] = 'goto_prev_unmatched_brace'
  let g:which_key_left_bracket_map['#'] = 'goto_prev_unmatched_defined_if'
  let g:which_key_left_bracket_map['/'] = 'goto_prev_comment'
  let g:which_key_left_bracket_map['"'] = 'which_key_ignore'
  let g:which_key_left_bracket_map[']'] = 'which_key_ignore'
  let g:which_key_left_bracket_map['%'] = 'which_key_ignore'

  " TODO mappings for debuggers lldb
  " TODO mappings for CCTree
  " TODO mappings for surround (d,y,c)
endfunction

function! s:version_control_command(cmd) abort
  if empty(a:cmd)
    echoerr '[version_control_command]: Please provide a command'
    return
  endif

  let l:git = !empty(glob('.git', v:true, v:true))
  let l:svn = !empty(glob('.svn', v:true, v:true))

  if !l:git && !l:svn
    " If both empty, assume it's git
    let l:git = 1
  endif

  if a:cmd ==? 'status'
    if l:git
      " nmap here is needed for the <C-n> to work. Otherwise it doesnt know what
      " it means. This below is if you want it horizontal
      " nmap <leader>gs :Gstatus<CR><C-w>L<C-n>
      if exists(':LazyGit') > 0
        LazyGit
      elseif executable('lazygit')
        lua require('utils.utils').exec_float_term('term lazygit', true, true)
      else
        execute ':Git status'
      endif
    elseif l:svn
      execute ':SVNStatus q'
    else
      echoerr '[version_control_command]: Please provide a command for status'
      return
    endif
  elseif a:cmd ==? 'diff'
    if l:git
      execute ':DiffviewOpen'
    else
      echoerr '[version_control_command]: Please provide a command for log'
      return
    endif
  elseif a:cmd ==? 'clog'
    if l:git
      execute ':DiffviewFileHistory %'
    else
      echoerr '[version_control_command]: Please provide a command for log'
      return
    endif
  elseif a:cmd ==? 'alog'
    if l:git
      execute ':DiffviewFileHistory'
    elseif l:svn
      execute ':SVNLog .'
    else
      echoerr '[version_control_command]: Please provide a command for log'
      return
    endif
  elseif a:cmd ==? 'commit'
    if l:git
      execute ':!git commit'
      " silent execute ':Git write'
      " execute ':Git commit'
    elseif l:svn
      execute ':SVNCommit'
    else
      echoerr '[version_control_command]: Please provide a command for commit'
      return
    endif
  else
    echoerr '[version_control_command]: Please provide support this command'
    return
  endif
endfunction

function! s:toggle_conceal() abort
  let l:cc = &conceallevel

  if l:cc == 0
    set conceallevel=2
  else
    set conceallevel=0
  endif
endfunction

function! mappings#SetCscope() abort
  if !has('cscope')
    echoerr '[mappings#SetCscope]: cscope not available'
    return -1
  endif

  " kill all cscope connections
  nnoremap <buffer> <localleader>sk :cscope kill -1<cr>
  nnoremap <buffer> <localleader>sr :cscope reset<cr>
  nnoremap <buffer> <localleader>sh :cscope show<cr>
  " 0 or s: Find this C symbol
  nnoremap <buffer> <localleader>ss :exec 'cscope find s ' .
        \ expand('<cword>')<cr>
  " 1 or g: Find this definition
  nnoremap <buffer> <localleader>sg :exec 'cscope find g ' .
        \ expand('<cword>')<cr>
  " 2 or d: Find functions called by this function
  nnoremap <buffer> <localleader>sd :exec 'cscope find d ' .
        \ expand('<cword>')<cr>
  " 3 or c: Find functions calling this function
  nnoremap <buffer> <localleader>sc :exec 'cscope find c ' .
        \ expand('<cword>')<cr>
  " 4 or t: Find this text string
  nnoremap <buffer> <localleader>st :exec 'cscope find t ' .
        \ expand('<cword>')<cr>
  " 6 or e: Find this egrep pattern
  nnoremap <buffer> <localleader>se :exec 'cscope find e ' .
        \ expand('<cword>')<cr>
  " 7 or f: Find this file
  nnoremap <buffer> <localleader>sf :exec 'cscope find f ' .
        \ expand('<cword>')<cr>
  " 8 or i: Find files #including this file
  nnoremap <buffer> <localleader>si :exec 'cscope find i ' .
        \ expand('<cword>')<cr>
  " 9 or a: Find places where this symbol is assigned a value
  nnoremap <buffer> <localleader>sa :exec 'cscope find a ' .
        \ expand('<cword>')<cr>

  if !exists(':CCTreeLoadDB')
    return
  endif

  nnoremap <buffer> <localleader>el :call <SID>cctree_load_db()<cr>
  nnoremap <buffer> <localleader>es :call <SID>cctree_save_xrefdb()<cr>
  nnoremap <buffer> <localleader>ef :exec 'CCTreeTraceForward ' .
        \ expand('<cword>')<cr>
  nnoremap <buffer> <localleader>er :exec 'CCTreeTraceReverse ' .
        \ expand('<cword>')<cr>
  nnoremap <buffer> <localleader>et :CCTreeWindowToggle<cr>
endfunction

" Creates a terminal and toggles it zoom
function! s:toggle_zoom_terminal(cmd) abort
  if (!exists('g:loaded_zoom'))
    echoerr 'Please the dhruvasagar/vim-zoom plugin'
    return -1
  endif

  if (!exists(':' . a:cmd))
    echoerr 'Please the kassio/neoterm plugin'
    return -2
  endif

  if (!empty(zoom#statusline()))
    " We are in zoom mode
    call zoom#toggle()
    normal! ZZ
    return
  endif

  execute ':' . a:cmd
  call zoom#toggle()
endfunction

function! s:todo_add() abort
  let todo = input('Please enter new item: ')
  if empty(todo)
    return
  endif

  call writefile([todo], '/tmp/todo.txt')
endfunction

function! s:todo_remove() abort
  return delete('/tmp/todo.txt')
endfunction

function! s:refresh_buffer() abort
  nohlsearch
  diffupdate
  mode
  syntax sync fromstart
  edit
  normal! zz<cr>
  if exists(':SignifyRefresh')
    SignifyRefresh
  endif
endfunction
