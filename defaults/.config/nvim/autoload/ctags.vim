let s:cscope_files = g:ctags_output_dir . 'cscope.files'

let s:cs_cmd = (has('nvim') ? 'Cs' : 'cs')
let s:cs_kill = (has('nvim') ? 'Cs db rm' : 'cs kill -1')
let s:cs_add = (has('nvim') ? 'Cs db add' : 'cs add')

function! s:cscope_load_db(db) abort
  try
    execute s:cs_kill
    execute s:cs_add . " " . a:db
  catch
    echoerr 'Failed to add cscope database: ' . a:db
    return 0
  endtry
  if has('nvim')
    echomsg 'Added cscope database: ' . a:db
  endif
  return 1
endfunction

function! s:get_full_path_as_name(folder) abort
  " Create unique tag file name based on cwd
  let l:ret = substitute(a:folder, "\\", '_', 'g')
  let l:ret = substitute(l:ret, ':', '_', 'g')
  let l:ret = substitute(l:ret, ' ', '_', 'g')
  return substitute(l:ret, "/", '_', 'g')
endfunction

function! s:list_files(dir) abort
  let l:directory = globpath(a:dir, '*')
  if empty(l:directory)
    " echohl ErrorMsg | echom a:dir . " is not a valid directory name" | echohl None
    return []
  endif
  return map(split(l:directory,'\n'), "fnamemodify(v:val, ':t')")
endfunction

"	Your current directory should be at the root of you code
function! ctags#NvimSyncCtagsCscope() abort
  let l:cwd = getcwd()
  let response = confirm('Create tags for current folder?: '. l:cwd, "&Jes\n&Lo", 2)
  if response != 1
    return
  endif

  let tag_name = s:get_full_path_as_name(l:cwd)

  if !s:create_tags(tag_name)
    echomsg "Failed to create tags file: " . tag_name
    return
  endif

  call s:create_cscope(tag_name)
endfunction

function! ctags#VimFt2RgFt() abort
  let rg_ft = &filetype
  if rg_ft ==? 'python'
    return 'py'
  endif
  return rg_ft
endfunction

function! s:vim_ft_to_ctags_ft(ft) abort
  if a:ft ==? 'cpp'
    let lang = 'C++'
  elseif a:ft ==? 'vim'
    let lang = 'Vim'
  elseif a:ft ==? 'python'
    let lang = 'Python'
  elseif a:ft ==? 'java'
    let lang = 'Java'
  elseif a:ft ==? 'c'
    let lang = 'C'
  else
    return ''
  endif

  return lang
endfunction

function! s:list_tags_files() abort
  " Obtain full path list of all files in ctags folder
  let potential_tags = map(s:list_files(g:ctags_output_dir), "g:ctags_output_dir . v:val")
  if len(potential_tags) == 0
    " echomsg tags_loc . " is empty"
    return
  endif

  return potential_tags
endfunction

" Creates cscope.files
function! s:create_cscope_files(quote_files) abort
  if executable('fd')
    " Unix command with fd
    let l:ext = s:get_fd_ft_ext()
    let l:files_cmd = 'fd --type file --follow --hidden --absolute-path --exclude ".{sync,git,svn}" ' . l:ext . ' > ' . s:cscope_files
  elseif executable('find')
      " Unix command with find as fallback
      let l:ext = s:get_find_ft_ext()
      let l:cwd = getcwd()
      let l:files_cmd = 'find ' . l:cwd . ' -type f ' . l:ext . ' > ' . s:cscope_files
  elseif has('win32')
    " Windows command using dir
    let l:files_cmd = 'dir /b /s *.java *.cpp *.h *.hpp *.c *.cc *.cs > ' . s:cscope_files
  else
    echomsg string("No suitable file search utility found: fd or find for Unix, dir for Windows")
    return 0
  endif

  if &verbose > 0
    echomsg string(l:files_cmd)
  endif

  let res = system(l:files_cmd)
  if v:shell_error
    echoerr "Failed to create cscope.files: " . l:files_cmd
    echoerr res
    return 0
  endif

  return 1
endfunction

function! s:create_tags(tags_name) abort
  if !executable('ctags')
    echomsg string("Ctags dependens on ctags. duh?!?!!")
    return
  endif

  " Do not quote file names
  if !s:create_cscope_files(1)
    echoerr "Failed to create cscope files"
    return
  endif

  let ctags_lang = s:vim_ft_to_ctags_ft(&filetype)

  let tags_loc = g:ctags_output_dir . a:tags_name

  " Default command
  " Fri Aug 31 2018 16:31: 
  " - See 'tagbsearch' for the enabled sort option 
  " - Also added relative to match vim's 'tagrelative'
  " - NOTE: Keep in mind to leav a space at end of each chunk
  " Tue Jan 29 2019 15:31:
  " - Relative thing doesnt make much sense
  let ctags_cmd = 'ctags -L ' . s:cscope_files . ' -f ' . tags_loc .
        \  ' --sort=yes --recurse=yes --tag-relative=no --output-format=e-ctags '
  
  if ctags_lang ==# 'C++'
    let ctags_cmd .= '--c-kinds=+pl --c++-kinds=+pl --fields=+iaSl --extras=+q '
  endif

  if &verbose > 0
    echomsg 'ctags_cmd = ' . ctags_cmd
  endif

  let res = system(ctags_cmd)
  if v:shell_error
    " We may be dealing with an older ctags version, try a simplified version of
    " the command
    let ctags_cmd = 'ctags -L ' . s:cscope_files . ' -f ' . tags_loc .
          \  ' --sort=yes --recurse=yes --tag-relative=no '

    if ctags_lang ==# 'C++'
      let ctags_cmd .= '--c-kinds=+pl --c++-kinds=+pl --fields=+iaSl '
    endif
    if &verbose > 0
      echomsg 'initial ctags command failed with error: ' . res
      echomsg 'retrying a simpliefied version of the command ctags_cmd = ' . ctags_cmd
    endif
    let res = system(ctags_cmd)
    if v:shell_error
      echoerr "Ctag command failed: " . ctags_cmd
      echoerr res
      return 0
    endif
  endif

  call s:add_tags(a:tags_name)

  return 1
endfunction

function! ctags#LoadCscopeDatabse() abort
  if &modifiable == 0
    return
  endif

  let tag_name = s:get_full_path_as_name(getcwd())

  if s:add_tags(tag_name) != 1
    call s:create_tags(tag_name)
  endif

  " Local cscope.out has priority
  if !empty(glob('cscope.out'))
    try
      cs kill -1
      cs add cscope.out
    catch 
      return -1
    endtry
    return 1
  endif

  if s:load_cscope_db(tag_name . '.out') == 0
    call s:create_cscope(tag_name)
  endif
endfunction

function! s:add_tags(tags_name) abort
  if empty(glob(g:ctags_output_dir . a:tags_name))
    if &verbose > 0
      echomsg 'Tags file doesnt exist: ' . g:ctags_output_dir . a:tags_name
    endif
    return 0
  endif

  execute "set tags=" . g:ctags_output_dir . a:tags_name
  echomsg "Updated tags: " &tags
  return 1
endfunction

function! s:get_cwd() abort
  let cwd_rg = getcwd()
  if !has('unix')
    let cwd_rg = substitute(cwd_rg, "\\", "/", "g") " Fix cwd for the rg command
  endif

  return cwd_rg
endfunction

function! s:create_cscope(tag_name) abort
  if has('nvim') && exists(':Cs') <= 0
    echomsg "nvim doesn't have native support for cscope"
    return
  endif

  if !executable('cscope')
    echomsg string("Ctags dependens on cscope")
    return
  endif

  if !has('unix')
    let choice = confirm('Run cscope?', "&Jes\n&Ko", 2)
    if (choice != 1)
      return
    endif
  endif

  let valid = 0
  for type in g:ctags_use_cscope_for
    if type ==? &filetype
      let valid = 1
      break
    endif
  endfor

  if valid == 0
    if &verbose > 0
      echomsg 'Not creating cscope db for ' . &filetype
    endif
    return
  endif

  " Create cscope db as well
  let cs_db = (has('unix') ? '-f ' . g:ctags_output_dir . a:tag_name . '.out' : '')
  " -b            Build the cross-reference only.
  " -c            Use only ASCII characters in the cross-ref file (don't compress).
  " -q            Build an inverted index for quick symbol searching.
  " -f reffile    Use reffile as cross-ref file name instead of cscope.out.
  " -i namefile   Browse through files listed in namefile, instead of cscope.files
  let cscope_cmd = 'cscope -Rbcq ' . cs_db . ' -i ' . '"' . s:cscope_files . '"'
  if &verbose > 0
    echomsg 'cscope_cmd = ' . cscope_cmd
  endif
  echomsg 'Creating cscope database...'
  let res_cs = system(cscope_cmd)
  if v:shell_error
    echoerr 'Cscope command failed: ' . cscope_cmd
    echoerr res_cs
    return
  endif

  call s:cscope_load_db(cs_db)
endfunction

function! s:load_cscope_db(tag_name) abort
  if !exists('g:ctags_output_dir') || empty('g:ctags_output_dir')
    if &verbose > 0
      echoerr '[load_cscope_db]: Failed to get g:ctags_output_dir path'
    endif
    return -1
  endif

  let cs_db = g:ctags_output_dir . a:tag_name
  if empty(glob(cs_db))
    if &verbose > 0
      echomsg 'No cscope database ' . cs_db
    endif
    return 0
  endif

  return s:cscope_load_db(cs_db)
endfunction

function! s:get_fd_ft_ext() abort
  let l:ft = &filetype

  if l:ft ==# 'cpp' || l:ft ==# 'c'
    return "-e c -e cpp -e c++ -e cc -e h -e hpp -e cxx"
  elseif l:ft ==# 'vim'
    return "-e vim"
    return "\"\.(vim)$\""
  elseif l:ft ==# 'python'
    return "-e py"
  elseif l:ft ==# 'java'
    return "-e java"
  else
    return ""
  endif
endfunction

function! s:get_find_ft_ext() abort
  let l:ft = &filetype

  if l:ft ==# 'cpp' || l:ft ==# 'c'
    return "\\( -name \"*.[ch]\" -o -name \"*.cpp\" -o -name \"*.hpp\" -o -name \"*.cxx\" \\)"
  elseif l:ft ==# 'vim'
    return "-name \"*.vim\""
  elseif l:ft ==# 'python'
    return "-name \"*.vim\""
  elseif l:ft ==# 'java'
    return "-name \"*.java\""
    " Add more filetypes as necessary.
  else
    return ""
  endif
endfunction
