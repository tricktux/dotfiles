
function! packadds#Set()
  silent! packadd comment
  nmap <bs> gcc
  xmap <bs> gc
  silent! packadd editorconfig
endfunction
