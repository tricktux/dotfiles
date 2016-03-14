"function! Demo()
  "let curline = getline('.')
  "call inputsave()
  "let name = input('Enter name: ')
  "call inputrestore()
  "call setline('.', curline . ' ' . name)
"endfunction


"let g:SomePath=['~\', 'somestuff','Monospace 8']
""let g:GlobalPath=g:SomePath . "vimrc"
"echo g:SomePath[0]

function! GlobalSearch(type) abort 
	"echomsg string(a:type)  " Debugging purposes
	if a:type == "0" 
		let l:file = inputlist(['Search Filetypes:', '1.Any', '2.Cpp']) 
	else
		let l:file = a:type
	endif
	"echomsg string(l:file)  " Debugging purposes
	if l:file == 1
		let l:file = "**/*"
	elseif l:file == 2
		let l:file = "**/*.cpp **/*.h **/*.c **/*.hpp"
	endif
	exe "vimgrep /" . input("Search in \"" . getcwd() . "\" for:") . "/ " . l:file
	copen 20
endfunction

call GlobalSearch(2)
