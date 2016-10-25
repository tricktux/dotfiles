" Vim compiler file
" Compiler:	Borland C and Pascal
" Maintainer:	Thorsten Maerz <info@netztorte.de>
" Last Change:	2001 Okt 03
" $Revision: 1.1 $

" Hint: Borlands grep.exe has a non-standard output format, even with
" unix-compatibility flag set. I have not yet found a global 'grepformat'. 
" I propose renaming Borlands copy and use grep.exe from the cygwin 
" distribution instead, which works with Vims default settings.
" Hint: Watch the order of the errorformat parts (between ,), to prevent 
" misinterpretations. This current order seems to work :
" - cbuilder, delphi/kylix, fpk, tp7, borland c

if exists("current_compiler")
  finish
endif
let current_compiler = "borland"

" uncomment to automatically save buffer before :make
"setlocal autowrite

setlocal makeprg=make 
setlocal errorformat=%*[^0-9]\ %t%n\ %f\ %l:\ %m,%*\\r%f(%l)\ %m,%f(%l\\,%c)\ %m,%A%f(%l):\ %*[^\ ]\ %n:\ %m,%-Z%p^,%+C%.%#,%*[^\ ]\ %f\ %l:\ %m

" turbo c 2.0 (tcc), borland c 3.1 (bcc), 5.2 (bcc, bcc32)
"setlocal errorformat=%*[^\ ]\ %f\ %l:\ %m
"setlocal makeprg=tcc
"setlocal makeprg=bcc
"setlocal makeprg=bcc32
"let $PATH='d:\bc31\bin;'.$PATH

" cbuilder 4, 5
"setlocal errorformat=%*[^0-9]\ %t%n\ %f\ %l:\ %m
"setlocal makeprg=bcc32
"let $PATH='d:\borland\cbuilder4\bin;'.$PATH

" free pascal 1.0.4
"setlocal errorformat=%f(%l\\,%c)\ %*[^:]:\ %m
"setlocal makeprg=ppc386
"let $PATH='d:\prg\fpk\bin\go32v2;'.$PATH

" turbo pascal 7.0
"setlocal errorformat=%A%f(%l):\ %*[^\ ]\ %n:\ %m,%-Z%p^,%+C%.%#
"setlocal makeprg=tpc\ -Q
"let $PATH='d:\prg\tp7\bin;'.$PATH

" delphi 5, 6 (dcc32), kylix (dcc)
"setlocal errorformat=%*\\r%f(%l)\ %m
"setlocal makeprg=dcc32\ -Q
"setlocal makeprg=dcc\ -Q
"let $PATH='d:\borland\delphi5\bin;'.$PATH

