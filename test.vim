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

"function! GlobalSearch(type) abort 
	""echomsg string(a:type)  " Debugging purposes
	"if a:type == "0" 
		"let l:file = inputlist(['Search Filetypes:', '1.Any', '2.Cpp']) 
	"else
		"let l:file = a:type
	"endif
	""echomsg string(l:file)  " Debugging purposes
	"if l:file == 1
		"let l:file = "**/*"
	"elseif l:file == 2
		"let l:file = "**/*.cpp **/*.h **/*.c **/*.hpp"
	"endif
	"exe "vimgrep /" . input("Search in \"" . getcwd() . "\" for:") . "/ " . l:file
	"copen 20
"endfunction

"call GlobalSearch(2)
"
"exe("!start cmd /k \"WINGS.exe 3 . " . input("Config file:") . "\" & exit")

"let &undodir= g:PersonalPath . 'undodir'
"" Create undo dir if it doesnt exist
"if !isdirectory(&undodir) 
"if exists("*mkdir") 
"call mkdir(&undodir, "p")
"else
"echo "Failed to create undodir"
"endif
"endif
"set undofile
"endif
" record undo history in this path
"if has('pelkkajsdfl;kkajsdf
"{
"}  // End of "if has('pelkkajsdfl;kkajsdf..."

"function! EndOfIfComment() abort
	"let l:end = "  // End of \""
	"execute "normal a" . l:end . "\<Esc>^%kyWj%W"
	"let l:com = @0
	"if strchars(l:com)>26
		"let l:com = strpart(l:com,0,26)
		"execute "normal a" . l:com . "...\""
	"else
		"execute "normal a" . l:com . "\""
	"endif
"endfunction
" Input can be folder or file
function! GitCommit() abort
	if CheckFileOrDir(1, ".git") > 0
		silent !git add .
		exe "silent !git commit -m \"" . input("Commit comment:") . "\""
		!git push origin master 
	else
		echo "No .git directory was found"
	endif
endfunction
call GitCommit()
function! CheckFileOrDir(type,name) abort
	if !has('file_in_path')  " sanity check 
		echo "CheckFileOrDir(): This vim install has no support for +find_in_path"
		return -10
	endif
	if a:type == 0  " use 0 for file, 1 for dir
		let l:func = findfile(a:name,",,")  " see :h cd for ,, 
	else
		let l:func = finddir(a:name,",,") 
	endif
	if !empty(l:func)
		return 1
	else
		return -1
	endif
endfunction
echo CheckFileOrDir(1, "_vimrc")
"function! CheckCurrentDirForFile(folder) abort
	"let l:folder_list = split(globpath('.', '*'), '\n')
	"let l:k1 = 0
	"for item in l:folder_list
		""echo l:folder_list[k1]
		"if match(l:folder_list[k1], a:folder, 1)>-1
			"return 1
		"endif
		"let k1 += 1
	"endfor
	"return -1
"endfunction
"echo CheckCurrentDirForFile("_vimrc")
