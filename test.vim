"function! Demo()
  "let curline = getline('.')
  "call inputsave()
  "let name = input('Enter name: ')
  "call inputrestore()
  "call setline('.', curline . ' ' . name)
"endfunction


let g:SomePath='~\'
let g:GlobalPath=g:SomePath . "vimrc"
echo g:GlobalPath
