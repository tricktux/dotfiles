" File:svn_debug.vim
"	Description: Wrapper around svn switch/copy/delete commands
" Author:Reinaldo Molina <rmolin88@gmail.com>
" Version:1.0.0
" Last Modified: Mar 29 2017 09:22

" TODO.RM-Thu Feb 23 2017 14:12: Create the svn copy, and delete commands  
" Returns a list where. The first item is the url of the repo
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

	if has('win32')
		let srch_eng = 'findstr'
	else
		let srch_eng = 'grep'
	endif

	" Go to the root dir because we want to list all the branches
	let buf_dir = RootDirFinder()
	if buf_dir == -1
		echomsg 'Failed to detect repo root directory'
		return
	endif

	let svn_info = systemlist('svn info | ' . srch_eng . ' URL')
	" Obtain repo URL from here
	" Now try to obtain the Repo URL
	if v:shell_error
		echomsg 'Failed to get svn info'
		return
	endif

	let svn_info = get(svn_info, 0, "")

	" echomsg 'Repo URL: '.svn_info

	if g:svn_branch_info =~# 'trunk'
		let srch = 'trunk'
	elseif g:svn_branch_info =~# 'branches'
		let srch = 'branches'
	elseif g:svn_branch_info =~# 'tags'
		let srch = 'tags'
	else
		echomsg string('Failed to obtain current branch')
		return
	endif

	let url_idx = stridx(svn_info, 'URL: ')
	let brch_idx = stridx(svn_info, srch)
	if brch_idx == -1 || url_idx == -1
		echomsg 'Failed to match branch to URL'
		return
	else
		let svn_repo_url = svn_info[url_idx+5:brch_idx-1]
		" echomsg 'Repo URL: '.svn_repo_url
	endif

	" Now that we have the repo url. Lets go ahead do ls on the url
	let svn_branches = systemlist('svn ls ' . svn_repo_url)
	if v:shell_error
		echomsg 'Failed to get svn ls'
		cexpr svn_branches
		return
	endif

	let ret_list = [svn_repo_url]
	for item in svn_branches
		if item !~# 'branches' && item !~# 'tags' && item !~# 'trunk'
			echomsg item 'is not a branches/tags/trunk in repo root URL ' svn_repo_url
			break
		endif
		let item = item[:-1-1] " Strip last char
		if item =~# 'trunk'
			let ret_list += [item]
			continue
		endif
		let temp_list = systemlist('svn ls ' . svn_repo_url . item)
		if len(temp_list) > 0
			let ret_list += map(temp_list, 'item . v:val[:-1-1]')
		endif
	endfor

	" echomsg string(ret_list)

	if !empty(buf_dir)
		silent! execute "cd " . buf_dir
	endif
	return ret_list
endfunction

" TODO.RM-Fri Feb 24 2017 05:43: Turn this into a command  
function! SvnSwitchBranchTag() abort
	if !executable('svn')
		echohl ErrorMsg
		echo "SvnSwitchBranchTag(): Please Install svn to use this functionality"
		echohl None
		return
	endif

	if !exists('g:svn_branch_info')
		echomsg 'No svn repo detected'
		return
	endif

	" You dont have to be in a command per say
	let branches_list = GetSvnListOfBranchesTags()
	if len(branches_list) <= 1
		echomsg 'Failed to obtain list of branches'
		return
	endif

	let [url; brch_list] = branches_list
	let qtn = 'Please select a trunk, branch, or tag to switch to from ' . getcwd() . ':'
	let user_idx = SvnSelectBranchTagTrunk(brch_list, qtn)

	if user_idx == -1
		" echomsg string('Failed to obtain user selection')
		return
	endif

	if empty(get(brch_list, user_idx, ""))
		echomsg string('Failed to obtain user selected branch')
		return
	endif

	let res = systemlist('svn switch ' . url . brch_list[user_idx] . ' .')
	if v:shell_error
		echomsg string('Switch Failed')
		cexpr res
	else
		echomsg string('Successful Switch')
		cexpr res
	endif
	" silent! execute "cd " . dir
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
	let user_idx = getchar()  " Get user selection
	" Convert to 0 based index
	let user_idx -= 49
	" Check user input
	if user_idx < 0 || user_idx > len(a:branch_list)
		if user_idx == 27-49 " ESC key
			return -1 " Handle properly cancel
		endif
		echohl ErrorMsg
		echo "SvnSelectBranchTagTrunk(): Invalid Branch/Tag/Trunk Selected"
		echohl None
		return -1
	endif
	return user_idx
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

	let user_idx = SvnSelectBranchTagTrunk(branches_list, 
				\'Please select a trunk, branch, or tag to copy from:')
	if user_idx == -1
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

	echo "Summary: Copying from: <" g:svn_repo_url . branches_list[user_idx] ">"
	echo "         To					 : <" g:svn_repo_url . new_branch_name ">"
	echo "Continue(y), Cancel(any other key)"
	let response = getchar()
	if response != 121 " y
		return
	endif

	" execute "nnoremap <Leader>vb :!svn copy --parents " . g:wings_svn_url . "OneWings/trunk " . g:wings_svn_url . "OneWings/branches/"
	" execute "nnoremap <Leader>vw :!svn switch " . g:wings_svn_url . "OneWings/branches/"
	let svn_copy_cmd = "svn copy --parents " . g:svn_repo_url . branches_list[user_idx] . " " 
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

	if !filereadable(expand('%')) " In case is a dir or something
		unlet! g:svn_branch_info
		return
	endif

	let deb = a:0

	if has('win32')
		let srch_eng = 'findstr'
	else
		let srch_eng = 'grep'
	endif

	let dir_buf = getcwd()
	let file_path = expand('%:p:h')
	if !empty(file_path)
		silent! execute "cd " . file_path
	endif
	try
		let info = systemlist("svn info | " . srch_eng . " URL")
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

	if deb
		echomsg 'info = ' string(info)
	endif

	" The system function returns something like "Relative URL: ^/...."
	" Strip from "^/" forward and put that in status line
	"TODO.RM-Tue Mar 28 2017 15:05: Find a much better way to do this  
	let info = get(info, 1, "")
	let index = stridx(info, "^/")
	if index == -1
		" echon "Couldnt Find needle"
		unlet! g:svn_branch_info
		if deb
			echomsg 'svn info did not return anything useful. info = ' string(info)
		endif
		return
	else
		let pot_display = info[index+1:-1-1] " Again skip last char. Looks ugly
	endif

	if deb
		echomsg 'pot_display = ' string(pot_display)
	endif

	" Truncating trunk
	let trunk_idx = stridx(pot_display, 'trunk')
	if trunk_idx != -1
		let g:svn_branch_info = pot_display[:trunk_idx+4]
		return
	endif

	" Truncating branch/tags
	let branch_idx = stridx(pot_display, 'branches')

	if branch_idx == -1
		if deb
			echomsg string('Didnt find the branches word')
		endif
		let branch_idx = stridx(pot_display, 'tags')
	elseif deb
		echomsg string('Found the branches word')
	endif

	if branch_idx != -1
		let idx = GetIdxTo2ndFSlash(pot_display, branch_idx)
		if deb
			echomsg 'idx = ' idx
		endif
		let g:svn_branch_info = pot_display[:idx]
		return
	endif

	if deb && !exists('g:svn_branch_info')
		echomsg string('No branch/tag/trunk identified')
	endif

	" If there is no trunk/branches/tags just output everything 
	if strlen(pot_display) > 16
		let g:svn_branch_info = pot_display[0:16] . '...'
	else
		let g:svn_branch_info = pot_display
	endif
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
			if num_of_slashes == 2
				return index
			endif
			let index += 1
		endif
	endwhile
	return -1
endfunction
