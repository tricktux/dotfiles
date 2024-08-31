
function! packadds#Set()
  silent! packadd termdebug
  silent! packadd nohlsearch
  silent! packadd comment
  nmap <bs> gcc
  silent! packadd editorconfig
endfunction
