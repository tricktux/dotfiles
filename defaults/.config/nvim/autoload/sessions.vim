
let s:session_path = g:sessions_path . '/'

function s:validate_session_path()
  if !isdirectory(s:session_path)
    return mkdir(s:session_path, 'p')
  endif
  return 1
endfunction

function! sessions#Save() abort
  if !s:validate_session_path()
    echoerr 'sessions: Folder "' . s:session_path . '" is invalid'
    return -1
  endif
  " if session name is not provided as function argument ask for it
  silent execute "wall"
  let session_name = input("Enter save session name:", s:session_path, "file")
  if empty(session_name)
    return
  endif

  silent! execute "mksession! " . session_name
endfunction

function! sessions#Browse() abort
  if !s:validate_session_path()
    echoerr 'sessions: Folder "' . s:session_path . '" is invalid'
    return -1
  endif

  silent! execute "Ex " . s:session_path
endfunction

function! sessions#Load() abort
  if !s:validate_session_path()
    echoerr 'sessions: Folder "' . s:session_path . '" is invalid'
    return -1
  endif

  " Save this current session
  if !empty(v:this_session)
    silent execute 'mksession! ' . v:this_session
  endif

  " Delete all buffers. Otherwise they will be added to the new session
  silent execute ':%bdelete!'

  let l:session_name = input('Load session:', s:session_path, 'file')
  if (empty(l:session_name))
    return
  endif
  silent execute 'source ' . l:session_name
endfunction
