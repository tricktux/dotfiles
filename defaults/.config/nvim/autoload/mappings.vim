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
  nnoremap <c-u> <c-u>zz
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

  " Unified search
  nnoremap <expr> n 'Nn'[v:searchforward] . 'zz'
  xnoremap <expr> n 'Nn'[v:searchforward] . 'zz'
  onoremap <expr> n 'Nn'[v:searchforward] . 'zz'

  nnoremap <expr> N 'nN'[v:searchforward] . 'zz'
  xnoremap <expr> N 'nN'[v:searchforward] . 'zz'
  onoremap <expr> N 'nN'[v:searchforward] . 'zz'

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

  nnoremap <silent> <c-h> :call <SID>refresh_buffer()<cr>
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
  nnoremap <silent> <s-q> :copen 20<bar>normal! <c-w>J<cr>
  nnoremap ]q :cnext<cr>
  nnoremap [q :cprevious<cr>

  nnoremap <silent> <s-u> :lopen 20<bar>normal! <c-w>J<cr>
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

  nnoremap <leader>cd :cd %:p:h<bar>:pwd<cr>
  nnoremap <leader>cu :cd ..<bar>:pwd<cr>
  nnoremap <leader>cc :pwd<cr>

  nnoremap <leader>ts :set invspell<cr>

  " Edit file at location <Leader>e?
  nnoremap <silent> <expr> <leader>ed ':e ~/.' . (has('nvim') ? 'config/nvim' : 'vim') . '/'
  nnoremap <silent> <expr> <leader>ep ':e ' . g:std_data_path . '/lazy'
  nnoremap <silent> <expr> <leader>ev ':e ' . fnameescape($VIMRUNTIME)
  nnoremap <silent> <leader>wj :e ~/Documents/wiki
  nnoremap <leader>ei :e 
  nnoremap <leader>et :e ~/.cache/ 

  " sessions
  nnoremap <leader>ss :call mappings#SaveSession()<cr>
  nnoremap <leader>sl :call mappings#LoadSession()<cr>
endfunction

function! mappings#SaveSession() abort
  let session_path = g:std_data_path . '/sessions/'
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
  silent! execute "mksession! " . session_path . session_name
endfunction

function! mappings#LoadSession() abort
  let l:session_path = g:std_data_path . '/sessions/'

  if empty(finddir('sessions', g:std_data_path))
    if &verbose > 0
      echoerr '[mappings#LoadSession]: Folder ' .
            \ l:session_path . ' does not exists'
    endif
    return -1
  endif

  " Save this current session
  if !empty(v:this_session)
    silent execute 'mksession! ' . v:this_session
  endif
  " Delete all buffers. Otherwise they will be added to the new session
  silent execute ':%bdelete!'

  let l:dir = getcwd()
  execute 'lcd '. l:session_path
  let l:session_name = input('Load session:', "", 'file')
  if (empty(l:session_name))
    return
  endif
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

function! s:toggle_conceal() abort
  let l:cc = &conceallevel

  if l:cc == 0
    set conceallevel=2
  else
    set conceallevel=0
  endif
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
