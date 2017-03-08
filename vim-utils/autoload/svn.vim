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

" TODO.RM-Thu Feb 23 2017 14:12: Create the svn copy, and delete commands  
function! svn#GetSvnListOfBranchesTags(repo_name) abort
	if empty(a:repo_name)
		echohl ErrorMsg
		echo "GetSvnListOfBranchesTags(): Invalid Input"
		echohl None
		return []
	endif

	" TODO.RM-Thu Feb 23 2017 16:08: Do not ASSUME there are branches, tags, and
	" trunk rather first `svn ls a:repo_name` to see whats there and then `svn
	" ls` recursively. Until you find only tags, branches, and trunk
	" Get branches
	" No reason to cd into svn root folder since we have full repo link
	" Pseudo: 
		" svn ls just repo name
		" search for branches, tags, and trunk
		" If branches, or tags is found then use that as your branches list
		" If none is found. 
			" Check the len of the list. If more than 3. No way there are that many
			" repos. Just ignore and assume there are no brances/tags
			" else
			" Repeat operation but from the name of the first folder
	let branches_list = systemlist("svn ls " . g:svn_repo_url . a:repo_name . "/branches")
	" echo branches_list
	if v:shell_error
		cexpr branches_list
		" TODO.RM-Thu Feb 23 2017 11:52: Insert option here to open or not the qf
		" window  
		copen 10
		return []
	endif
	" Insert branch in front of each element
	call map(branches_list, 'a:repo_name . "/branches/" . v:val')

	" Get tags
	let brch = systemlist("svn ls " . g:svn_repo_url . a:repo_name . "/tags")
	" Insert tags in front of each
	call map(brch, 'a:repo_name . "/tags/" . v:val')

	let branches_list += brch
	let branches_list += [ a:repo_name. '/trunk' ]

	return branches_list
endfunction

" TODO.RM-Fri Feb 24 2017 05:43: Turn this into a command  
function! svn#SvnSwitchBranchTag() abort
	if !executable('svn')
		echohl ErrorMsg
		echo "SvnSwitchBranchTag(): Please Install svn to use this functionality"
		echohl None
		return
	endif

	if !exists('g:svn_repo_name')
		echohl ErrorMsg
		echo "SvnSwitchBranchTag(): Please set g:svn_repo_name variable"
		echohl None
		return
	endif

	if !exists('g:svn_repo_url')
		echohl ErrorMsg
		echo "SvnSwitchBranchTag(): Please set g:svn_repo_url variable"
		echohl None
		return
	endif

	let branches_list = svn#GetSvnListOfBranchesTags(g:svn_repo_name)
	if len(branches_list) == 0
		return
	endif

	let user_index = svn#SvnSelectBranchTagTrunk(branches_list, 
				\'Please select a trunk, branch, or tag to switch to:')
	if user_index == -1
		return
	endif

	let dir = getcwd()
	if exists('*FindRootDirectory()') " If vim-rooter present try it
		let file_path = FindRootDirectory()
		if file_path ==# getcwd()
			let file_path = ""
		else
			silent! execute "cd " . file_path
		endif
	endif	

	cexpr systemlist("svn switch " . g:svn_repo_url . branches_list[user_index])
	silent! execute "cd " . dir
	" Update Status Line with New Branch information
	call svn#UpdateSvnBranchInfo()
endfunction

function! svn#SvnSelectBranchTagTrunk(branch_list, question) abort
	if empty(a:branch_list) || empty(a:question)
		echohl ErrorMsg
		echo "SvnSelectBranchTagTrunk(): Invalid Input(s)"
		echohl None
		return
	endif

	" Display question
	echo a:question
	" Insert numbers in front of branches/tags for user selection
	let index = 0
	for item in a:branch_list
		echo printf("%u. %s", index+1, a:branch_list[index] )
		let index += 1
	endfor

	" TODO.RM-Thu Feb 23 2017 00:06: Swith to input function. to prevent cases
	" where you have more than 9 tags/branches  
	let user_index = getchar()  " Get user selection
	" Convert to 0 based index
	let user_index -= 49
	" Check user input
	if user_index < 0 || user_index > len(a:branch_list)
		if user_index == 27-49 " ESC key
			return -1 " Handle properly cancel
		endif
		echohl ErrorMsg
		echo "SvnSelectBranchTagTrunk(): Invalid Branch/Tag/Trunk Selected"
		echohl None
		return -1
	endif
	return user_index
endfunction

" TODO.RM-Fri Feb 24 2017 05:44: Make command out of this  
function! svn#SvnCopy() abort
	if !executable('svn')
		echohl ErrorMsg
		echo "SvnCopy(): Please Install svn to use this functionality"
		echohl None
		return
	endif
	
	if !exists('g:svn_repo_name')
		echohl ErrorMsg
		echo "SvnCopy(): Please set g:svn_repo_name variable"
		echohl None
		return
	endif

	if !exists('g:svn_repo_url')
		echohl ErrorMsg
		echo "SvnCopy(): Please set g:svn_repo_url variable"
		echohl None
		return
	endif

	let branches_list = svn#GetSvnListOfBranchesTags(g:svn_repo_name)
	if len(branches_list) == 0
		return
	endif

	let user_index = svn#SvnSelectBranchTagTrunk(branches_list, 
				\'Please select a trunk, branch, or tag to copy from:')
	if user_index == -1
		return
	endif

	let new_branch_name = input("Please enter new branch/tag name:", g:svn_repo_name . "/branches/")
	if empty(new_branch_name)
		return
	endif

	let svn_commit_msg = input("Please enter an optional comment for the commit:", "Creating branch ")
	if !empty(svn_commit_msg)
		let svn_commit_msg = " -m " . svn_commit_msg
	endif

	echo "Summary: Copying from: <" g:svn_repo_url . branches_list[user_index] ">"
	echo "         To					 : <" g:svn_repo_url . new_branch_name ">"
	echo "Continue(y), Cancel(any other key)"
	let response = getchar()
	if response != 121 " y
		return
	endif

	" execute "nnoremap <Leader>vb :!svn copy --parents " . g:wings_svn_url . "OneWings/trunk " . g:wings_svn_url . "OneWings/branches/"
	" execute "nnoremap <Leader>vw :!svn switch " . g:wings_svn_url . "OneWings/branches/"
	let svn_copy_cmd = "svn copy --parents " . g:svn_repo_url . branches_list[user_index] . " " 
				\. g:svn_repo_url . new_branch_name . svn_commit_msg
	cexpr systemlist(svn_copy_cmd)
	if !empty(file_path)
		silent! cd - " Restore CWD
	endif
endfunction

" This function gets called on BufEnter
function! svn#UpdateSvnBranchInfo() abort
	if !executable('svn')
		echohl WarningMsg
		echo "utils#UpdateSvnBranchInfo(): Please Install svn to use this functionality"
		echohl None
		return
	endif

	if !filereadable(expand('%'))
		unlet! g:svn_branch_info
		return
	endif

	if exists('*FindRootDirectory()') " If vim-rooter present try it
		let file_path = FindRootDirectory()
		if file_path ==# getcwd()
			let file_path = ""
		endif
	else
		let file_path = expand('%:p:h')
	endif	

	if !empty(file_path)
		silent! execute "cd " . file_path
	endif
	try
		let info = system("svn info | findstr URL")
	catch
		if !empty(file_path)
			silent! cd - " Restore CWD
		endif
		unlet! g:svn_branch_info
		return
	endtry
	if !empty(file_path)
		silent! cd - " Restore CWD
	endif

	" The system function returns something like "Relative URL: ^/...."
	" Strip from "^/" forward and put that in status line
	let index = stridx(info, "^/")
	if index == -1
		" echon "Couldnt Find needle"
		unlet! g:svn_branch_info
		return
	else
		let g:svn_branch_info = strpart(info, index+1) " Strip out the '^' from '^/'
	endif
	" Strip string if there are more than 2 '/'
	let index = 0
	let num_of_slashes = 0
	" Count the number of slashes
	while 1
		let index = stridx(g:svn_branch_info, '/', index)
		if index == -1
			break
		else
			let num_of_slashes += 1
			if num_of_slashes == 3
				break
			endif
			let index += 1
		endif
	endw
	" echo strpart(g:svn_branch_info, 0, index)
	if num_of_slashes > 2
		let g:svn_branch_info = strpart(g:svn_branch_info, 0, index)
	endif
endfunction

" Called by statusline
function! svn#GetSvnBranchInfo() abort
	if exists('g:svn_branch_info')
		return g:svn_branch_info
	endif
	return ""
endfunction

" vim:tw=78:ts=2:sts=2:sw=2:
