
function! utils#is_buffer_valid() abort
  let l:ro = !&readonly && !&modified
  let l:bu = &buftype == "nofile" || &buftype == "prompt" || &buftype == "terminal"
  if l:ro && !l:bu && filereadable(expand('%'))
    return 1
  endif
  return 0
endfunction

