" File:         augroup.vim
" Description:  All autogroup should be group here. Unless it makes more sense
"               with some plugin
" Author:       Reinaldo Molina <rmolin88@gmail.com>
" Version:        0.0.0
" Last Modified: Aug 24 2017 16:25
" Created: Aug 24 2017 16:25

function! augroup#Set() abort
  " ALL_AUTOGROUP_STUFF
  " All of these options contain performance drawbacks but the most important
  " is foldmethod=syntax
  if !has('nvim-0.7')
    augroup Filetypes
      autocmd!

      autocmd FileType markdown,mkd setlocal conceallevel=0 wrap
            \ foldenable complete+=kspell ts=2 sw=2 sts=2
            \ comments+=b:-,b:* spelllang=en_us tw=0 wrap

      " formatoptions do not autowrap text
      autocmd FileType tex setlocal conceallevel=0 nowrap
            \ foldenable complete+=kspell ts=2 sw=2 sts=2
            \ spelllang=en_us tw=0 formatoptions-=tc colorcolumn=+1 wrap

      autocmd FileType mail setlocal wrap textwidth=72

      " autocmd FileType vim setlocal tabstop=2 shiftwidth=2 softtabstop=2 nospell

      " if has('nvim-0.5.0') && get(g:, 'ncm2_supports_lsp', 0)
      " autocmd FileType c,cpp set omnifunc=v:lua.vim.lsp.omnifunc
      " endif
      if has('unix')
        autocmd FileType c,cpp setlocal nowrap ts=2 sw=2 sts=2
      else
        autocmd FileType c,cpp setlocal nowrap ts=4 sw=4 sts=4
      endif
      autocmd FileType c,cpp setlocal nowrap fen
            \ fdn=88 define=^\\(#\\s*define\\|[a-z]*\\s*const\\s*[a-z]*\\)

      " Python
      autocmd FileType python setlocal
            \ textwidth=79
            \ shiftwidth=4
            \ tabstop=4
            \ softtabstop=4
            \ define=^\s*\\(def\\\\|class\\)

      autocmd FileType vim,lua setlocal
            \ textwidth=79
            \ shiftwidth=2
            \ tabstop=2
            \ softtabstop=2

      autocmd FileType fzf inoremap <buffer> <c-j> <down>
      autocmd FileType fzf inoremap <buffer> <c-n> <down>
      autocmd FileType json syntax match Comment +\/\/.\+$+
      " Set spell for who?
      autocmd FileType
            \ mail,markdown,gitcommit,tex,svnj_bwindow,fugitive
            \ setlocal spell spelllang=en,es
      autocmd FileType terminal setlocal nonumber norelativenumber bufhidden=hide
    augroup END

    augroup VimType
      autocmd!
      " Sessions
      " Note: Fri Mar 03 2017 14:13 - This never works.
      " autocmd VimEnter * call utils#LoadSession('default.vim')
      " Thu Oct 05 2017 22:22: Special settings that are only detected after vim
      " is loaded
      autocmd VimEnter * nested call s:on_vim_enter()
      " Keep splits normalize
      " autocmd VimResized * execute "normal! \<c-w>="
    augroup END
    augroup CmdWin
      autocmd!
      autocmd CmdWinEnter * nnoremap <buffer> q i" <cr>
      autocmd CmdWinEnter * nnoremap <buffer> <cr> i<cr>
    augroup END
    if !has('nvim')
      augroup Terminal
        autocmd!
        autocmd TerminalOpen * setlocal bufhidden=hide filetype=terminal
      augroup END
    endif

    " Autosave
    " Wed May 12 2021 11:42: Save less often
    autocmd CursorHold * silent! update
    " Depends on autoread being set
    augroup AutoRead
      autocmd!
      autocmd CursorHold * silent! checktime
    augroup END

    autocmd BufRead,BufNewFile * call s:determine_buf_type()
    " Do not save sessions on VimLeave, it deletes the tabs
    " autocmd BufEnter,BufWipeout * call mappings#SaveSession(has('nvim') ?
    " \ 'default_nvim.vim' : 'default_vim.vim')
  endif


  " To improve syntax highlight speed. If something breaks with highlight
  " increase these number below
  " augroup vimrc
  " autocmd!
  " autocmd BufWinEnter,Syntax * syn sync minlines=80 maxlines=80
  " augroup END

  augroup BuffTypes
    autocmd!
    autocmd BufReadPost *
          \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit' |
          \   exe "normal! g`\"" |
          \ endif

    " Sat May 16 2020 12:04: Trying out gen_tags
    " autocmd BufWinEnter * call ctags#LoadCscopeDatabse()
    " Tue Feb 25 2020 14:00: Really slows down vim
    " autocmd BufWinEnter * call status_line#SetVerControl()
  augroup END

endfunction

" Things to do after everything has being loaded
function! s:on_vim_enter() abort
  " This function needs to be here since most of the variables it checks are not
  " populated until vim init is done
  call options#SetCli()
  call plugin#AfterConfig()
  " if (argc() == 0) " If no arguments are passed load default session
  " call mappings#LoadSession(has('nvim') ?
  " \ 'default_nvim.vim' : 'default_vim.vim')
  " endif
endfunction

function! s:determine_buf_type() abort
  let l:ext = expand('%:e')
  if &verbose > 0
    echomsg 'Detecting buf type: ' l:ext
  endif
  if l:ext ==? 'ino' || l:ext ==? 'pde'
    set filetype=arduino
  elseif l:ext ==? 'csv'
    set filetype=csv
  elseif l:ext ==? 'bat'
    set filetype=dosbatch
  elseif l:ext ==? 'scp'
    set filetype=wings_syntax
    " elseif ext ==? 'log'
    " setfiletype unreal-log
  elseif l:ext ==? 'set' || l:ext ==? 'sum' || l:ext ==? 'ini'
    set filetype=dosini
  elseif l:ext ==? 'bin' || l:ext ==? 'pdf' || l:ext ==? 'hsr'
    if &verbose > 0
      echomsg 'Binary file detected'
    endif
    call s:set_bin_file_type()
  endif

endfunction

function! s:set_bin_file_type() abort
  let &l:bin=1
  %!xxd
  setlocal ft=xxd
  %!xxd -r
  setlocal nomodified
endfunction

function! s:normalize_window_size() abort
  execute "normal \<c-w>="
endfunction

" Thu Apr 26 2018 18:08: Never have being able to get this to work
function! s:restore_last_file() abort
  while !v:vim_did_enter
    execute ':sleep 1m'
  endwhile

  execute "normal \<c-o>\<c-o>"
endfunction

function! s:update_root_dir() abort
  if !exists('*FindRootDirectory')
    return -1
  endif

  let g:root_dir = FindRootDirectory()
endfunction
