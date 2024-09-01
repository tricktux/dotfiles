
function! packadds#Set()
  silent! packadd termdebug
  silent! packadd comment
  nmap <bs> gcc
  silent! packadd editorconfig
endfunction
