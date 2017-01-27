" File:unreal-log.vim
" Description: Syntax for Unreal Engine 4 log files
" Author:Reinaldo Molina <rmolin88@gmail.com>
" Version:1.0.0
" Last Modified: Jan 27 2017 06:45
" Created: Jan 27 2017 06:45
" 

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn keyword UE4LogTodo NOTE TODO XXX contained

syn case ignore

" Directives
syn match UE4LogIdentifier 	"[a-z_$][a-z0-9_$]*"

syn match UE4LogLabel      	"_^:[A-Z]_$"

syn match decNumber		"0\+[1-7]\=[\t\n$,; ]"
syn match decNumber		"[1-9]\d*"
syn match decNumber		"0.\d*"
syn match octNumber		"0[oO][0-7]\+"
syn match octNumber		"0[0-7][0-7]\+"
syn match hexNumber		"0[xX][0-9A-Fa-f]\+"
syn match hexNumber     	"\$[0-9A-Fa-f]\+\>"
syn match binNumber		"0[bB][0-1]*"

syn region UE4LogString    	start=+"+ end=+"+
syn region UE4LogChar    	start=+'+ end=+'+

" Log Names
syn match UE4LogOk             "LogTemp"

syn match UE4LogFail           "Error.*$"
syn match UE4LogFlgas           "Warning.*$"

" Colors red
" syn match UE4LogOpcode  		"LogTemp"

syn case match

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_UE4Log_syntax_inits")
  if version < 508
    let did_UE4Log_syntax_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink UE4LogTodo		Todo
  HiLink UE4LogComment		Comment
  HiLink UE4LogLabel		Type
  HiLink UE4LogString		String
  HiLink UE4LogChar		String
  HiLink UE4LogOpcode		Statement
  HiLink UE4LogCommands		Statement
  HiLink UE4LogRegister		StorageClass
  HiLink hexNumber		Number
  HiLink decNumber		Number
  HiLink octNumber		Number
  HiLink binNumber		Number
  HiLink UE4LogIdentifier	Identifier
  HiLink UE4LogFlgas		Special
  HiLink UE4LogLog		Identifier
  HiLink UE4LogOk		PreProc
  HiLink UE4LogFail		Error

  delcommand HiLink
endif

let b:current_syntax = "UE4Log_syntax"

" vim: ts=8
