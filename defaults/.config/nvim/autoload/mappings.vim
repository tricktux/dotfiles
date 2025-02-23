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
  nmap <leader>fa <plug>file_ranger_native
  nmap <leader>fs <plug>file_ranger_nvim
  nmap <leader>fj <plug>file_browser
  nmap <leader>fv <plug>file_browse_new_vertical_win
  nmap <leader>fo <plug>file_browse_oldfiles
  nnoremap <silent> <leader>fo :browse oldfiles<cr>
  nnoremap <plug>file_browser :Ex<cr>
  nnoremap <plug>file_browse_new_vertical_win :Vex<cr>

  nmap <leader>W <plug>get_passwd
  nnoremap <plug>get_passwd :silent call passwd#SelectPasswdFile()<cr>

  " Don't paste the deleted word, paste the last copied word, hopefully
  nnoremap <s-p> :normal! "0p<cr>

  nnoremap <silent> <c-h> :nohlsearch<cr><bar>:diffupdate<cr>
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
  nnoremap <silent> <s-q> :call <sid>qf_loclist_toggle("Quickfix List", 'c')<cr>
  nnoremap ]q :cnext<cr>
  nnoremap [q :cprevious<cr>

  nnoremap <silent> <s-u> :call <sid>qf_loclist_toggle("Location List", 'l')<cr>
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
  set cedit=<esc>
  cnoremap <a-w> \<\><Left><Left>
  " insert visual selection search
  cnoremap <c-u> <c-r>=expand("<cword>")<cr>
  cnoremap <c-s> %s/
  cnoremap <c-j> <cr>
  cnoremap <c-n> <down>
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

  " terminal
  nmap <localleader>j <plug>make 
  nnoremap <plug>make :make!<cr>
  nmap <M-`> <plug>terminal_toggle
  nmap <localleader>e <plug>terminal_send_line

  " Search
  nmap <leader>; <plug>cmd_hist_browser
  nnoremap <plug>cmd_hist_browser q:
  nmap <leader>, <plug>grep_cword
  nnoremap <plug>grep_cword :grep <c-r><c-w><cr>
  nmap <leader>/ <plug>grep
  nnoremap <plug>grep :grep 

  " Custom command :F for searching and opening files using fd
  command! -nargs=1 -complete=customlist,s:FComplete F execute 'edit' <q-args>

  " Window movement
  " move between windows
  if !has('nvim')

    if has('terminal')
      nnoremap <leader>vs :term ++close lazygit<cr>
      nnoremap <plug>file_ranger_native :term ++close ranger<cr>
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
  if executable('fd')
    nnoremap <plug>current_folder_file_browser :F<space>
  endif
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
  nnoremap <silent> <leader>ed :e ~/.config/
  nnoremap <silent> <expr> <leader>ep ':e ' . g:std_data_path . '/lazy/'
  nnoremap <silent> <expr> <leader>ev ':e ' . fnameescape($VIMRUNTIME) . '/'
  nnoremap <silent> <leader>wj :e ~/Documents/wiki/
  nnoremap <leader>ei :e 
  nnoremap <leader>et :e ~/.cache/

  " sessions
  nnoremap <silent> <leader>ss :call sessions#Save()<cr>
  nnoremap <silent> <leader>sl :call sessions#Load()<cr>
  nnoremap <silent> <leader>sb :call sessions#Browse()<cr>
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

" Function to generate file completion using fd
function! s:FComplete(lead, cmdline, pos)
  " Construct the fd command
  let l:cmd = 'fd --type f --color=never --hidden --follow --full-path ' . a:lead

  " Execute fd and store the results
  let l:results = split(system(l:cmd), "\n")

  " Filter out empty lines and return
  return filter(l:results, 'v:val != ""')
endfunction

function! s:qf_get_buffer_list() abort
  redir =>buflist
  silent! ls!
  redir END
  return buflist
endfunction

function! s:qf_loclist_toggle(bufname, pfx) abort
  let buflist = <sid>qf_get_buffer_list()
  for bufnum in map(filter(split(buflist, '\n'), 'v:val =~ "'.a:bufname.'"'), 'str2nr(matchstr(v:val, "\\d\\+"))')
    if bufwinnr(bufnum) != -1
      exec(a:pfx.'close')
      return
    endif
  endfor
  if a:pfx == 'l' && len(getloclist(0)) == 0
    echohl ErrorMsg
    echo "Location List is Empty."
    return
  endif
  let winnr = winnr()
  exec(a:pfx.'open')
  " Move quickfix to bottom of screen
  wincmd J
  " Restore cursor to previous window
  " if winnr() != winnr
  " wincmd p
  " endif
endfunction
