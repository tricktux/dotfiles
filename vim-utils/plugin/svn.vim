" File:						svn.vim
"	Description:		SVN plugin that gives you current branch in status line. As
"									well as allowing you to Switch, Copy, and Delete branches intellengtly
" Author:					Reinaldo Molina <rmolin88@gmail.com>
" Version:				1.0.0
" Last Modified: Thu Feb 23 2017 14:11
" Created:				Feb 23 2017 14:09

" TODO.RM-Thu Feb 23 2017 14:12: Create the svn copy, and delete commands  
function! GetSvnListOfBranchesTags(repo_name) abort
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

function! SvnSwitchBranchTag() abort
	" TODO.RM-Wed Feb 22 2017 16:43: Turn 'OneWings' into a g: like varible  
	if !executable('svn')
		echohl ErrorMsg
		echo "SvnSelectBranchTagTrunk(): Please Install svn to use this functionality"
		echohl None
		return
	endif

	let branches_list = GetSvnListOfBranchesTags('OneWings')
	if len(branches_list) == 0
		return
	endif

	let user_index = SvnSelectBranchTagTrunk(branches_list, 
				\'Please select a trunk, branch, or tag to switch to:')
	if user_index == -1
		return
	endif

	if exists(':Rooter') " If vim-rooter present try it
		silent! Rooter
	endif	
	cexpr systemlist("svn switch " . g:svn_repo_url . branches_list[user_index])
	silent! cd - " Restore CWD
	" Update Status Line with New Branch information
	call UpdateSvnBranchInfo()
endfunction

function! SvnSelectBranchTagTrunk(branch_list, question) abort
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

function! SvnCopy() abort
	if !executable('svn')
		echohl ErrorMsg
		echo "SvnCopy(): Please Install svn to use this functionality"
		echohl None
		return
	endif
	
	let branches_list = GetSvnListOfBranchesTags('OneWings')
	if len(branches_list) == 0
		return
	endif

	let user_index = SvnSelectBranchTagTrunk(branches_list, 
				\'Please select a trunk, branch, or tag to copy from:')
	if user_index == -1
		return
	endif

	let new_branch_name = input("Please enter new branch/tag name:", "OneWings/branches/")
	if empty(new_branch_name)
		return
	endif

	let svn_commit_msg = input("Please enter an optional comment for the commit:", "Creating branch ")
	if !empty(svn_commit_msg)
		let svn_commit_msg = " -m " . svn_commit_msg
	endif

	echo "Summary: Copying from: <" g:wings_svn_url . branches_list[user_index] ">"
	echo "         To					 : <" g:wings_svn_url . new_branch_name ">"
	echo "Continue(y), Cancel(any other key)"
	let response = getchar()
	if response != 121 " y
		return
	endif

	let svn_copy_cmd = "svn copy --parents " . g:wings_svn_url . branches_list[user_index] . " " 
				\. g:wings_svn_url . new_branch_name . svn_commit_msg
	if exists(':Rooter') " If vim-rooter present try it
		silent! Rooter
	endif	
	cexpr systemlist(svn_copy_cmd)
	silent! cd - " Restore CWD
endfunction

" vim:tw=78:ts=2:sts=2:sw=2:
