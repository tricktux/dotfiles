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
"function! GitCommit() abort
	"if CheckFileOrDir(1, ".git") > 0
		"silent !git add .
		"exe "silent !git commit -m \"" . input("Commit comment:") . "\""
		"!git push origin master 
	"else
		"echo "No .git directory was found"
	"endif
"endfunction
"call GitCommit()
"function! CheckFileOrDir(type,name) abort
	"if !has('file_in_path')  " sanity check 
		"echo "CheckFileOrDir(): This vim install has no support for +find_in_path"
		"return -10
	"endif
	"(a:type)?let l:func = finddir(a:name,",,"):let l:func = findfile(a:name,",,")  
	""if a:type == 0  " use 0 for file, 1 for dir
		""let l:func = findfile(a:name,",,")  " see :h cd for ,, 
	""else
		""let l:func = finddir(a:name,",,") 
	""endif
	"if !empty((a:type)?let l:func = finddir(a:name,",,"): findfile(a:name,",,"))
		"return 1
	"else
		"return -1
	"endif
"endfunction
function! Mygetchar() abort
	echo "Search Filetypes:\n\t1.Any\n\t2.Cpp\n" 
	let casa = nr2char(getchar())
	echo casa
endfunction
function! GlobalSearch(type) abort 
	"echomsg string(a:type)  " Debugging purposes
	if a:type == "0" 
		echo "Search Filetypes:\n\t1.Any\n\t2.Cpp\n" 
		let l:file = nr2char(getchar())
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
"call Mygetchar()
function! s:YankFrom() abort
	exe "normal :" . input("Yank From Line:") . "y\<CR>p"
endfunction

function! s:DeleteLine() abort
	exe "normal :" . input("Delete Line:") . "d\<CR>``"
endfunction
"echo CheckFileOrDir(1, "_vimrc")
"let l:k1 = 0
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
"
" The mystery of faith
" What is the meaning of being alive?
" Being alive means looking into your eyes and seeing tenderness, passion, love, respect, happiness, comfort,
" respect, truth. It truly gives meaning to the phrase The eyes are the mirror of the soul. 
" What does it mean to love and to be loved?
" Does God exists?
" Where does he exists?
" Who was Jesus?
" What does it mean to follow your dreams?
" What does it mean to be happy?
" What does a full and rich live means?
" Where does happiness lies?
" What does it mean to be happy?
" All of these questions have only one answer
" You
" I will truly wait forever
" The 
" Do every single mistake in my life 
" 88 times again 
" just to get to you
" It seems impossible that we have
" being together for less than a year
" I've learned so much by your side
"
"
"
"if(lakjsdlfkjadsljfa)
	"{

	"}// ""if(lakjsdlfkjadsljfa)"
"else
	"{

	"}  // End of ""else"
function! s:EndOfIfComment() abort
	" search Current line for "}"
	if match(getline("."), "}") > -1
		" search current line and next for "else"
		" search initial { line and before for "else"
		let l:end = "  // End of \""
		let l:noend = "  // \""
		if match(getline(".", line(".")+1), "else") > -1
			" insert // ", jump to matchin {, copy that line, jump back
			execute "normal a//\<Space>\"\<Esc>F}%k^yW`."
			"execute "normal a//\<Space>\"\<Esc>F}%k^yWj%W"
		else
			execute "normal a" . l:end . "\<Esc>F}%k^yW`."
		endif
		" truncate comment line in case too long
		if strchars(@0)>26
			let l:com = strpart(@0,0,26)
			execute "normal a" . @0 . "...\""
		else
			execute "normal a" . @0 . "\""
		endif
	else
		echo "EndOfIfComment(): Closing brace } needs to be present at the line"
	endif
endfunction
call <SID>EndOfIfComment()
