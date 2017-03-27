" TODO.RM-Thu Feb 23 2017 14:12: Create the svn copy, and delete commands  
function! GetSvnListOfBranchesTags() abort
	if !exists('g:svn_branch_info')
		echomsg 'No svn repo detected'
		return
	endif

	if !executable('svn')
		echomsg 'No svn executable detected'
		return
	endif

	if !executable('grep')
		echomsg 'No grep executable detected'
		return
	endif

	let buf_dir = RootDirFinder()
	if buf_dir == -1
		echomsg 'Failed to detect repo root directory'
		return
	endif

	let svn_info = systemlist('svn info | grep URL')
	" Obtain repo URL from here
	" Now try to obtain the Repo URL
	let url = get(svn_info, 1, "")
	if empty(url)
		echomsg 'Failed to get svn info'
		return
	endif

	" Get branch idx
	" TODO.RM-Mon Mar 27 2017 17:22: Figure out why its not truncating properly  
	let brch_idx = stridx(url, g:svn_branch_info[1:])
	if brch_idx == -1
		echomsg 'Failed to match branch to URL'
	else
		let svn_repo_url = strpart(url, 5, brch_idx)
		echomsg 'Branch len = '. strlen(svn_repo_url)
		echomsg 'Branch idx = '. brch_idx
		echomsg 'Repo URL: '.svn_repo_url
	endif

	if !empty(buf_dir)
		silent! execute "cd " . buf_dir
	endif
endfunction

" TODO.RM-Fri Feb 24 2017 05:43: Turn this into a command  
function! SvnSwitchBranchTag() abort
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

	" You dont have to be in a command per say
	let branches_list = GetSvnListOfBranchesTags(g:svn_repo_name)
	if len(branches_list) == 0
		return
	endif

	let user_index = SvnSelectBranchTagTrunk(branches_list, 
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

" TODO.RM-Fri Feb 24 2017 05:44: Make command out of this  
function! SvnCopy() abort
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

	let branches_list = GetSvnListOfBranchesTags(g:svn_repo_name)
	if len(branches_list) == 0
		return
	endif

	let user_index = SvnSelectBranchTagTrunk(branches_list, 
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

" TODO.RM-Thu Mar 16 2017 08:36: Update this function to make it async. Maybe the whole plugin be async  
" This function gets called on BufEnter
" Call the function from cli with any argument to obtain debugging output
function! UpdateSvnBranchInfo(...) abort
	if !executable('svn') && !exists('s:svn_not_exec')
		echohl WarningMsg
		echomsg "utils#UpdateSvnBranchInfo(): Please Install svn to use this functionality"
		echohl None
		let s:svn_not_exec = 1
		return
	endif

	if !executable('grep') && !exists('s:svn_not_exec')
		echohl WarningMsg
		echomsg "utils#UpdateSvnBranchInfo(): Please Install grep to use this functionality"
		echohl None
		let s:svn_not_exec = 1
		return
	endif

	if !filereadable(expand('%')) " In case is a dir or something
		unlet! g:svn_branch_info
		return
	endif

	let dir_buf = getcwd()
	let file_path = expand('%:p:h')
	if !empty(file_path)
		silent! execute "cd " . file_path
	endif
	try
		let info = systemlist("svn info | grep URL")
	catch
		if !empty(file_path)
			silent! execute "cd " . dir_buf
		endif
		unlet! g:svn_branch_info
		return
	endtry
	if !empty(file_path)
		silent! execute "cd " . dir_buf
	endif

	" The system function returns something like "Relative URL: ^/...."
	" Strip from "^/" forward and put that in status line
	let branches = get(info, 2, "")
	let index = stridx(branches, "^/")
	if index == -1
		" echon "Couldnt Find needle"
		unlet! g:svn_branch_info
		if a:0 > 0
			echomsg 'svn info did not return anything useful'
		endif
		return
	else
		" let g:svn_branch_info = strpart(branches, index+1, strlen(branches)-3) " Strip out the '^' from '^/'
		let pot_display = branches[index+1:]
		" echomsg 'Original Brch Info: "'g:svn_branch_info
	endif

	" Truncating trunk
	let trunk_idx = stridx(pot_display, 'trunk')
	if trunk_idx != -1
		" let g:svn_branch_info = strpart(pot_display, 0, trunk_idx+5)
		let g:svn_branch_info = pot_display[:trunk_idx+4]
		return
	endif

	" Truncating branch/tags
	let branch_idx = stridx(pot_display, 'branches')
	if branch_idx == -1
		let branch_idx = stridx(pot_display, 'tags')
	endif

	if branch_idx != -1
		let idx = GetIdxTo2ndFSlash(pot_display, branch_idx)
		if idx == -1
			let g:svn_branch_info = pot_display
			return
		else
			let g:svn_branch_info = pot_display[:idx]
			return
		endif
	endif

	" If there is no trunk/branches/tags just output everything 
	if strlen(pot_display) > 16
		let g:svn_branch_info = pot_display[0:16] . '...'
	else
		let g:svn_branch_info = pot_display
	endif
	" echo strpart(g:svn_branch_info, 0, index)
	" if num_of_slashes > 2
		" let g:svn_branch_info = strpart(g:svn_branch_info, 0, index)
	" endif
	" let g:svn_branch_info += " "
endfunction

" Cds to root dir if there is one and returns prev dir
" if there is no root dir returns empty and doesnt do anything
function! RootDirFinder() abort
	if exists('*FindRootDirectory()') " If vim-rooter present try it
		let dir_buf = getcwd()
		let file_path = FindRootDirectory()
		if file_path ==# dir_buf
			return
		elseif empty(file_path)
			return -1
		else
			silent! execute "cd " . file_path
			return dir_buf
		endif
	else
		echomsg 'vim-rooter not present'
	endif	
endfunction

" str - Haystack on which to search for the forward slashes
" start_idx - At what position of the Haystack to start searching
function! GetIdxTo2ndFSlash(str, start_idx)
	" Strip string if there are more than 2 '/'
	let index = a:start_idx
	let num_of_slashes = 0
	" Count the number of slashes
	while 1
		let index = stridx(a:str, '/', index)
		if index == -1
			break
		else
			let num_of_slashes += 1
			if num_of_slashes == 3
				return index
			endif
			let index += 1
		endif
	endwhile
	return -1
endfunction
