" File:           sessions.vim
" Description:    Plugin to handle saving and loading sessions
" Author:		    Reinaldo Molina
" Email:          rmolin88 at gmail dot com
" Revision:	    1.0.0
" Created:        Thu Jan 17 2019 10:39
" Last Modified:  Fri Mar 13 2020 14:19


if exists('g:loaded_sessions')
  finish
endif

let g:loaded_sessions = 1

" BUG: 
"   Fri Apr 17 2020 18:06:
"     Using FZF to load sessions does not really work
"     Ergo the 100 value for fuzzy_over
"   
" fuzzy_over: When there are more than this number of sessions, use fuzzies to 
"     select a session
let s:sessions = {
      \ 'path' : g:std_data_path . '/sessions/',
      \ 'fuzz_over' : 100,
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
      echoerr '[sessions.existing_save]: Folder ' . 
            \ self.path . ' does not exists'
    endif
    return -1
  endif

  if empty(v:this_session)
    if &verbose > 0
      echoerr '[sessions.existing_save]: There is no existing session'
    endif
    return -2
  endif

  let l:cmd = 'mksession!'
  if exists(':' . self.helper_plugin.cmd)
    " If helper plugin available use it
    let l:cmd = self.helper_plugin.cmd
    " Current helper plugin has the option to be in pause mode. Where no changes 
    " are saved. If we are in that mode do not save anything just return

    if self.helper_plugin.status_fn() ==#
          \ self.helper_plugin.status_fn_ongoing_session
      if &verbose > 0
        echomsg '[sessions.existing_save]: Obsession is paused. So no saving'
      endif
      return
    endif
  endif

  if &verbose > 0
    echomsg '[sessions.existing_save]: Saving existing session: ' v:this_session
  endif
  silent execute l:cmd .  ' ' . v:this_session
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

  let l:name = self.get_new_name()
  if empty(l:name)
    return
  endif

  if filereadable(l:name)
    echoerr "Session already exists: " l:name
    return
  endif

  let l:cmd = 'mksession!'
  if exists(':' . self.helper_plugin.cmd)
    " If helper plugin available use it
    let l:cmd = self.helper_plugin.cmd
  endif

  if &verbose > 0
    echomsg '[sessions.existing_save]: Saving new session: ' l:name
  endif
  silent execute l:cmd .  ' ' . l:name
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
  if empty(l:name)
    return
  endif

  if &verbose > 0
    echomsg "[session.load]: Session name is: " l:name
  endif
  if !filereadable(l:name)
    echoerr "[sessions.load]: Session does not exists: " l:name
    return
  endif
  execute 'source ' . l:name
endfunction

function! s:sessions.get_existing_name() abort
  if (empty(glob(self.path)))
    if &verbose > 0
      echoerr '[session.save]: Folder ' . 
            \ self.path . ' does not exists'
    endif
    return ''
  endif

  " If there are more than 10 sessions, use fanzy fuzzers
  let l:fuzzers = 0
  let l:sessions = glob(self.path . '*.vim', 0, 1)
  if len(l:sessions) > self.fuzz_over 
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
  return self.path . l:session_name
endfunction

command! SessionsLoad call s:sessions.load()
command! SessionsNew call s:sessions.new()
command! SessionsSaveAs call s:sessions.new_save()
command! SessionsSave call s:sessions.existing_save()
