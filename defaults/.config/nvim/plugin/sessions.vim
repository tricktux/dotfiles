" File:           sessions.vim
" Description:    Plugin to handle saving and loading sessions
" Author:		    Reinaldo Molina
" Email:          rmolin88 at gmail dot com
" Revision:	    1.0.0
" Created:        Thu Jan 17 2019 10:39
" Last Modified:  Fri Mar 13 2020 14:19


" if exists('g:loaded_sessions')
	" finish
" endif

let g:loaded_sessions = 1

let s:sessions = {
      \ 'path' : g:std_data_path . '/sessions/',
      \ 'helper_plugin' : 
      \   {
      \     'cmd' :  'Obsession',
      \     'status_fn': function('ObsessionStatus'),
      \     'status_fn_ongoing_session': '[$]',
      \   },
      \ }

function! s:sessions.existing_save() abort
  if (empty(glob(self.path)))
    if &verbose > 0
      echoerr '[sessions.save]: Folder ' . 
            \ self.path . ' does not exists'
    endif
    return -1
  endif

  if empty(v:this_session)
    if &verbose > 0
      echoerr '[sessions.save]: There is no existing session'
    endif
    return -2
  endif

  " Save this current session
  if exists(':' . self.helper_plugin.cmd)
    " Check if there is an ongoing session
    if self.helper_plugin_status_fn() ==# '[$]'
      " If there is save it before leaving
      silent execute self.helper_plugin.cmd .  ' ' . v:this_session
    endif
  else
    silent execute 'mksession! ' . v:this_session
  endif
endfunction

function! s:sessions.get_new_name() abort
  if (empty(glob(self.path)))
    if &verbose > 0
      echoerr '[session.save]: Folder ' . 
            \ self.path . ' does not exists'
    endif
    return ''
  endif

  silent execute "wall"
  let dir = getcwd()
  silent execute "lcd ". self.path
  let session_name = input("Enter save session name:", "", "file")
  " Restore current dir
  silent execute "lcd " . dir
  if empty(session_name)
    return ''
  endif

  " Ensure session_name ends in .vim
  if match(session_name, '.vim', -4) < 0
    " Append extention if was not provided
    let session_name .= '.vim'
  endif
  return session_name
endfunction

function! s:sessions.new() abort
  if (empty(glob(self.path)))
    if &verbose > 0
      echoerr '[session.save]: Folder ' . 
            \ self.path . ' does not exists'
    endif
    return -1
  endif

  " Save current session
  let l:rc = self.existing_save()
  if (l:rc >= 0)
    " Pause this current session
    execute self.helper_plugin.cmd
  endif

  " Delete all buffers. Otherwise they will be added to the new session
  silent execute ':%bdelete!'

  " Give this new session a name
  let name = self.get_new_name()
  if empty(name)
    return
  endif

  " Pause this current session
  execute self.helper_plugin.cmd . ' ' . self.path . name
endfunction

function! s:sessions.new_save() abort
  if (empty(glob(self.path)))
    if &verbose > 0
      echoerr '[session.save]: Folder ' . 
            \ self.path . ' does not exists'
    endif
    return -1
  endif

  let name = self.get_new_name()
  if empty(name)
    return
  endif

  " Save this current session
  if exists(':' . self.helper_plugin.cmd)
    " Check if there is an ongoing session
    if self.helper_plugin.status_fn() ==#
          \ self.helper_plugin.status_fn_ongoing_session
      " If there is save it before leaving
      silent execute self.helper_plugin.cmd .  ' ' . name
    endif
  else
    silent execute 'mksession! ' . name
  endif
endfunction

function! s:sessions.load() abort
  if (empty(glob(self.path)))
    if &verbose > 0
      echoerr '[session.save]: Folder ' . 
            \ self.path . ' does not exists'
    endif
    return -1
  endif

  " Save current session
  let l:rc = self.existing_save()
  if (l:rc >= 0)
    " Pause this current session
    execute self.helper_plugin.cmd
  endif

  " Delete all buffers. Otherwise they will be added to the new session
  silent execute ':%bdelete!'

  " Get name
  let l:name = self.get_existing_name()
  if !filereadable(self.path . l:name)
    return
  endif
  execute 'source ' . self.path . l:name
endfunction

function! s:sessions.get_existing_name() abort
  if (empty(glob(self.path)))
    if &verbose > 0
      echoerr '[session.save]: Folder ' . 
            \ self.path . ' does not exists'
    endif
    return -1
  endif

  " If there are more than 10 sessions, use fanzy fuzzers
  let l:fuzzers = 0
  let l:sessions = glob(self.path . '*.vim', 0, 1)
  if len(l:sessions) > 10
    let l:fuzzers = 1
  endif

  if l:fuzzers && exists(':FZF')
    call fzf#run(fzf#wrap({ 
          \ 'source': l:sessions, 
          \ 'sink': {line -> setreg('*', line)},
          \ }))
    return getreg('*')
  endif

  if l:fuzzers && exists(':Denite')
    return utils#DeniteYank(self.path)
  endif

  let l:dir = getcwd()
  execute 'lcd '. self.path
  let l:session_name = input('Load session:', "", 'file')
  silent execute 'lcd ' . l:dir
  return l:session_name
endfunction

command! SessionsLoad call s:sessions.load()
command! SessionsNew call s:sessions.new()
command! SessionsSaveAs call s:sessions.new_save()
command! SessionsSave call s:sessions.existing_save()
