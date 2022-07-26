" File:                 commands.vim
" Description:  Universal commands
" Author:               Reinaldo Molina <rmolin88@gmail.com>
" Version:              0.0.0
" Last Modified: Oct 18 2017 13:52
" Created: Oct 18 2017 13:52

" CUSTOM_COMMANDS
function! commands#Set() abort
  if !has("nvim")
    command! UtilsEditJournal call s:scratchpad_journal()
  endif
  command! UtilsRemoveTrailingWhiteSpaces call s:trim_trailing_white_spaces()

  command! -nargs=? UtilsPasswdGenerate call s:generate_random_pass(<f-args>)
  command! UtilsBuffersDeleteNoName call s:delete_empty_buffers()
  command! UtilsWeekGetNumber :echomsg strftime('%V')

  command! UtilsIndentWholeFile execute("normal! mzgg=G`z")
  command! UtilsFileFormat2Dos :e ++ff=dos<cr>
  command! UtilsFileFormat2Unix call s:convert_line_ending_to_unix()
  command! UtilsDiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
        \ | wincmd p | diffthis
  command! -nargs=+ -complete=command UtilsCaptureCmdOutput
        \ call s:capture_cmd_out(<f-args>)
  command! UtilsProfile call s:profile_performance()
  command! UtilsDiffSet call s:set_diff()
  command! UtilsDiffOff call s:unset_diff()
  command! UtilsDiffReset call s:unset_diff()<bar>call s:set_diff()
  " Convert fileformat to dos
  command! UtilsNerdComAltDelims
        \ execute("normal \<Plug>NERDCommenterAltDelims")
  command! UtilsPdfSearch call s:search_pdf()
  command! UtilsFindBraceInComment call s:find_brace_in_comment()

  " These used to be ]F [F mappings but they are not so popular so moving them
  " to commands
  command! UtilsFontZoomIn call s:adjust_gui_font('+')
  command! UtilsFontZoomOut call s:adjust_gui_font('-')

  command! UtilsFileSize call s:get_file_info()

  if has('unix')
    " This mapping will load the journal from the most recent boot and highlight
    " it for you
    command! UtilsLinuxReadJournal
          \ execute("read !journalctl -b<CR><bar>:setf messages<CR>")
    " Give execute permissions to current file
    command! UtilsLinuxExecReadPermissions execute("!chmod a+x %")
    " Save file with sudo permissions
    command! UtilsLinuxSudoPermissions execute("w !sudo tee % > /dev/null")
    command! UtilsLinuxExecuteCurrFile execute("silent !./%")
  else
    command! UtilsTermOpen :term cmd.exe /k c:\tools\cmder\vendor\init.bat<cr>
  endif

  " Convention: All commands names need to start with the autoload file name.
  " And use camel case. This way is easier to search
  command! UtilsTagLoadCurrFolder call ctags#LoadCscopeDatabse()
  command! UtilsTagUpdateCurrFolder call ctags#NvimSyncCtags()
  command! UtilsTagLoadCCTree call ctags#LoadCctreeDb()

endfunction

function! s:capture_cmd_out(...) abort
  " this function output the result of the Ex command into a split scratch
  " buffer
  if a:0 == 0
    return
  endif
  let cmd = join(a:000, ' ')
  if cmd[0] == '!'
    vnew
    setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted
    execute "read " . cmd
    return
  endif
  redir => l:output
  execute cmd
  redir END
  if empty(output)
    echoerr "No output from: " . cmd
  else
    vnew
    setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted
    put! =output
  endif
endfunction

function! s:profile_performance() abort
  if exists('*stdpath')
    execute 'profile start ' . stdpath('cache') . '/profile_' .
          \ strftime("%m%d%y-%H.%M.%S") . '.log'
  else
    execute 'profile start ~/.cache/profile_' .
          \ strftime("%m%d%y-%H.%M.%S") . '.log'
  endif
  execute 'profile func *'
  execute 'profile file *'
endfunction

function! s:set_diff() abort
  " Make sure you run diffget and diffput from left window
  if !executable('diff')
    echoerr 'diff is not executable. Please install it'
    return
  endif

  try
    windo diffthis
  catch
    echoerr 'diff command failed. Make sure it is installed correctly'
    echoerr v:exception
    diffoff!
    return
  endtry
  nnoremap <C-j> ]c
  nnoremap <C-k> [c
  nnoremap <C-h> :diffget<CR>
  nnoremap <C-l> :diffput<CR>
endfunction

function! s:unset_diff() abort
  nnoremap <C-j> zj
  nnoremap <C-k> zk
  nnoremap <C-h> :noh<CR>
  nunmap <C-l>
  diffoff!
endfunction

function! s:search_pdf() abort
  if !executable('pdfgrep')
    echoe 'Please install "pdfgrep"'
    return
  endif

  if exists(':Grepper')
    execute ':Grepper -tool pdfgrep'
    return
  endif

  let grep_buf = &grepprg

  let &l:grepprg="pdfgrep --ignore-case --page-number --recursive --context 1"
  return utils#FileTypeSearch(8, 8)

  let &l:grepprg = grep_buf
endfunction

function! s:adjust_gui_font(zoom) abort
  " lkkajsdflkkajsdflkj
  if has('nvim') && exists('g:GuiLoaded') && exists('g:GuiFont')
    " Substitute last number with a plus or minus value depending on input
    let new_cmd = substitute(g:GuiFont,
          \ ':h\zs\d\+','\=eval(submatch(0)'.a:zoom.'1)','')
    echomsg new_cmd
    call GuiFont(new_cmd, 1)
  else " gvim
    let sub = has('win32') ? ':h\zs\d\+' : '\ \zs\d\+'
    let &guifont = substitute(&guifont, sub,
          \ '\=eval(submatch(0)'.a:zoom.'1)','')
  endif
endfunction

function! s:convert_line_ending_to_unix() abort
  edit ++ff=dos
  setlocal fileformat=unix
  write
endfunction

function! s:get_file_info() abort
  let file = expand('%')
  let bytes = getfsize(file)

  if bytes < 0
    echomsg 'Error getting size of file: ' . file
    return bytes
  elseif bytes == 0
    echomsg 'Size of file: ' . file . 'is zero.'
    return
  endif

  let mb = bytes * 0.000001
  let ret = printf('Size of file "%s" = %f MBytes - %d Bytes', file, mb, bytes)
  echomsg ret
  return
endfunction

function! s:find_brace_in_comment() abort
  let l:lines = getline(0, line('$'))

  for l:line in l:lines
    let l:idx = stridx(l:line, '//')
    if l:idx < 0
      continue
    endif

    let l:brace_idx = stridx(l:line, '{', l:idx)
    let l:brace2_idx = stridx(l:line, '}', l:idx)

    if l:brace_idx >= 0 || l:brace2_idx >= 0
      echomsg string(l:line)
    endif
  endfor
endfunction

function! s:scratchpad_journal() abort
  if (!exists('g:wiki_path'))
    echomsg 'No wiki found'
    return
  endif

  execute('edit ' . g:wiki_path . '/notes.org')
endfunction

function! s:delete_empty_buffers()
  let [i, n; empty] = [1, bufnr('$')]
  while i <= n
    if bufexists(i) && bufname(i) == ''
      call add(empty, i)
    endif
    let i += 1
  endwhile
  if len(empty) > 0
    exe 'bdelete' join(empty)
  endif
endfunction

function! s:rand(x,y) abort " random uniform between x and y
  return luaeval('(_A.y-_A.x)*math.random()+_A.x', {'x':a:x,'y':a:y})
endfunction

function! s:generate_random_pass(...) abort
  let l:num_chars = 16
  if a:0 != 0
    let l:num_chars = a:1
  endif
  " Create a loop until num_chars
  let l:pass = ''
  let l:idx = 1
  while (l:idx != l:num_chars)
    let l:pass .= nr2char(float2nr(s:rand(33,127)))
    let l:idx += 1
  endwhile
  let @+ = l:pass
  let @* = l:pass
  echo l:pass
endfunction

function! s:trim_trailing_white_spaces() abort
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
  endfunction
