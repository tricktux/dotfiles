if has('nvim') == 1
  finish
endif

function! s:getcommentstring() abort
  " Manual filetype to comment mapping for older Vim versions
  if &filetype == 'c' || &filetype == 'cpp' || &filetype == 'java' || &filetype == 'javascript'
    return '//'
  elseif &filetype == 'python' || &filetype == 'sh' || &filetype == 'bash' || &filetype == 'perl' || &filetype == 'ruby'
    return '#'
  elseif &filetype == 'vim'
    return '"'
  elseif &filetype == 'lua' || &filetype == 'sql'
    return '--'
  elseif &filetype == 'tex' || &filetype == 'matlab'
    return '%'
  elseif &filetype == 'lisp' || &filetype == 'scheme'
    return ';'
  else
    " Default fallback
    return '#'
  endif
endfunction

function! s:togglecomment() abort
  let l:cs = &commentstring
  if l:cs == ''
    let l:cs = s:getcommentstring()
  endif

  " Extract comment prefix (everything before %s)
  let l:prefix = substitute(l:cs, '\s*%s.*$', '', '')
  let l:prefix = substitute(l:prefix, '^\s*\|\s*$', '', 'g')

  let l:line = getline('.')
  let l:prefix_escaped = escape(l:prefix, '.*[]^$\')

  " Check if line is already commented
  if match(l:line, '^\s*' . l:prefix_escaped) >= 0
    " Remove comment - preserve original indentation
    let l:new_line = substitute(l:line, '^\(\s*\)' . l:prefix_escaped . '\s*', '\1', '')
  else
    " Add comment - preserve indentation
    let l:indent = matchstr(l:line, '^\s*')
    let l:content = substitute(l:line, '^\s*', '', '')
    if l:content != ''
      let l:new_line = l:indent . l:prefix . ' ' . l:content
    else
      let l:new_line = l:line
    endif
  endif

  call setline('.', l:new_line)
endfunction

function! s:togglecommentrange() range abort
  let l:cs = &commentstring
  if l:cs == ''
    let l:cs = s:getcommentstring()
  endif

  " Extract comment prefix
  let l:prefix = substitute(l:cs, '\s*%s.*$', '', '')
  let l:prefix = substitute(l:prefix, '^\s*\|\s*$', '', 'g')
  let l:prefix_escaped = escape(l:prefix, '.*[]^$\')

  " Process each line in the visual selection
  for l:lnum in range(a:firstline, a:lastline)
    let l:line = getline(l:lnum)

    " Skip empty lines
    if l:line =~ '^\s*$'
      continue
    endif

    " Toggle comment for this line
    if match(l:line, '^\s*' . l:prefix_escaped) >= 0
      " Remove comment
      let l:new_line = substitute(l:line, '^\(\s*\)' . l:prefix_escaped . '\s*', '\1', '')
    else
      " Add comment
      let l:indent = matchstr(l:line, '^\s*')
      let l:content = substitute(l:line, '^\s*', '', '')
      let l:new_line = l:indent . l:prefix . ' ' . l:content
    endif

    call setline(l:lnum, l:new_line)
  endfor
endfunction

" Key mappings
nnoremap <silent> <BS> :call <sid>togglecomment()<CR>
vnoremap <silent> <BS> :call <sid>togglecommentrange()<CR>
