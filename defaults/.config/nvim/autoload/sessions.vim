
function! sessions#Save() abort
  let session_path = g:sessions_path . '/'
  " if session name is not provided as function argument ask for it
  silent execute "wall"
  let session_name = input("Enter save session name:", session_path, "file")
  if empty(session_name)
    return
  endif

  silent! execute "mksession! " . session_name
endfunction

function! sessions#Load() abort
  let l:session_path = g:sessions_path . '/'

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

  let l:session_name = input('Load session:', l:session_path, 'file')
  if (empty(l:session_name))
    return
  endif
  silent execute 'source ' . l:session_name
endfunction
