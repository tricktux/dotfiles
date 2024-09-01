
function! packadds#Set()
  silent! packadd termdebug
  silent! packadd comment
  nmap <bs> gcc
  xmap <bs> gc
  silent! packadd editorconfig
endfunction
