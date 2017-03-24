" File:						cpp.vim
" Description:		Highlight Classes and Structs for easytags
" Author:					Reinaldo Molina <rmolin88@gmail.com>
" Version:				1.0.0
" Last Modified: Tue Mar 21 2017 12:42
"
" highlight link cMember Special
" highlight cMember gui=italic
" hi default link cMember NONE
" hi clear cMember
" highlight cppEnumTag ctermfg=14 guifg=#00ff00
" highlight cppFunctionTag ctermfg=14 guifg=#00ff00
" highlight cppMemberTag ctermfg=14 guifg=#00ff00
highlight link cppMemberTag Special
highlight link cppFunctionTag Function
