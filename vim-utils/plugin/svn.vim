" File:						svn.vim
"	Description:		SVN plugin that gives you current branch in status line. As
"									well as allowing you to Switch, Copy, and Delete branches intellengtly
" Author:					Reinaldo Molina <rmolin88@gmail.com>
" Version:				1.0.0
" Last Modified: Sat Feb 25 2017 05:40
" Created:			 Sat Feb 25 2017 05:40
"
" Plugin Configuration variables:
"		g:svn_repo_url
"		g:svn_repo_name
"		Used to update the status line
"			g:svn_branch_info
"   g:svn_update_statusline
"		g:loaded_vim_svn

if exists('g:loaded_vim_svn')
	finish
endif
let g:loaded_vim_svn = 1

augroup svn_update_status_line
	autocmd!
	autocmd BufEnter * call UpdateSvnBranchInfo()
augroup END

" TODO.RM-Sat Feb 25 2017 06:14: Make autocomplete functions for these
" commands  
command! -register -bar SVNSwitch call SvnSwitchBranchTag()
command! -register -bar SVNCopy call SvnCopy()

" vim:tw=78:ts=2:sts=2:sw=2:
