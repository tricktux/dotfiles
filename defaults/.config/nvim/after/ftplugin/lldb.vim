
" File:					lldb.vim
"	Description:	ftplugin to use with the lldb.vim plugin
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:				0.0.0
" Last Modified: May 21 2017 11:24


" Only do this when not done yet for this buffer
if exists("b:did_lldb_ftplugin")
	finish
endif

" Don't load another plugin for this buffer
let b:did_lldb_ftplugin = 1

setlocal nofoldenable

" TODO.RM-Sun May 21 2017 11:26: Very likely move most of LL mappings here  
let b:undo_ftplugin = "setl foldenable<"
