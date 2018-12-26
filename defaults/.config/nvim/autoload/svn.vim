" File:						svn.vim
"	Description:		SVN plugin that gives you current branch in status line. As
"									well as allowing you to Switch, Copy, and Delete branches intellengtly
" Author:					Reinaldo Molina <rmolin88@gmail.com>
" Version:				1.0.0
" Last Modified: Sat Feb 25 2017 05:44
" Created:				Feb 23 2017 14:09
"
" Plugin Configuration variables:
"		g:svn_repo_url
"		g:svn_repo_name
"		Used to update the status line
"			g:svn_branch_info
"   g:svn_update_statusline && executable('svn')
" let g:lightline = {
" \   'svn': '%{svn#GetSvnBranchInfo()}', 
" \   'svn': '(!empty(svn#GetSvnBranchInfo()))', 


" Called by statusline
function! svn#GetSvnBranchInfo() abort
	if exists('g:svn_branch_info')
		return '[' . g:svn_branch_info . '] '
	endif
	return ''
endfunction

" vim:tw=78:ts=2:sts=2:sw=2:
