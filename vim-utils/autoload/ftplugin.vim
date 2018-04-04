
" File:					ftplugin.vim
"	Description:	Functions that set settings that are common for different
"								environments. Like c, python, java, .etc
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:				1.0.0
" Last Modified: Sun Jun 04 2017 15:59
" Created:			Jun 02 2017 10:19
" Wed Oct 18 2017 13:52: Decided to change many of these from mappings to commands. Most of these mappings
" are rarely used. It makes more sense to free up these mappings and make them mappings.

function! ftplugin#AutoHighlight() abort
	if exists("*utils#AutoHighlightToggle") && !exists('g:highlight')
		silent call utils#AutoHighlightToggle()
		command! UtilsAutoHighlightToggle call utils#AutoHighlightToggle()
	endif
endfunction

function! ftplugin#TagMappings() abort
	" Cscope and tag jumping mappings
	" nnoremap <buffer> <Leader>tk :cs kill -1<CR>
	command! UtilsTagKill :cs kill -1<CR>
	" nnoremap <buffer> <Leader>tv :vs<CR>:exec("tag ".expand("<cword>"))<CR>
	" ReLoad cscope database
	" nnoremap <buffer> <Leader>tl :call ctags#LoadCscopeDatabse()<CR>
	command! UtilsTagLoadCurrFolder call ctags#LoadCscopeDatabse()
	" Find functions calling this function
	" nnoremap <buffer> <Leader>tc :cs find c <C-R>=expand("<cword>")<CR><CR>
	" Find functions definition
	" nnoremap <buffer> <Leader>tg :cs find g <c-r>=expand("<cword>")<cr><cr>
	" Find functions called by this function not being used
	" nnoremap <Leader>td :cs find d <C-R>=expand("<cword>")<CR><CR>
	" nnoremap <buffer> <Leader>ts :cs show<CR>
	command! UtilsTagShow :cs show<CR>
	" nnoremap <buffer> <Leader>tu :call ctags#NvimSyncCtags(0)<CR>
	command! UtilsTagUpdateCurrFolder call ctags#NvimSyncCtags(0)
endfunction

" For cpp use '/\/\/'
" For vim use '/"'
" For python use '/#'
function! ftplugin#Align(comment) abort
	if exists(":Tabularize")
		execute "vnoremap <buffer> <Leader>oa :Tabularize " . a:comment . "<CR>"
	endif
endfunction

function! ftplugin#Syntastic(mode, checkers) abort
	if exists(":SyntasticCheck")
		" nnoremap <buffer> <unique> <Leader>lo :SyntasticToggleMode<CR>
		nnoremap <buffer> <LocalLeader>c :SyntasticCheck<CR>
	endif
	if !empty(a:checkers)
		let b:syntastic_checkers=a:checkers
	endif
	let b:syntastic_mode =a:mode
endfunction

function! ftplugin#SetCompilersAndOther() abort
	if exists('b:current_compiler')
		return
	endif

	if has('unix')
		setlocal foldmethod=syntax

		if exists('g:LanguageClient_serverCommands')
			setlocal completefunc=LanguageClient#complete
			setlocal formatexpr=LanguageClient_textDocument_rangeFormatting()

			" TODO-[RM]-(Sat Jan 27 2018 11:23): Figure out these mappings
			" nnoremap <buffer> <silent> gh :call LanguageClient_textDocument_hover()<CR>
			" nnoremap <buffer> <silent> gd :call LanguageClient_textDocument_definition()<CR>
			" nnoremap <buffer> <silent> gr :call LanguageClient_textDocument_references()<CR>
			" nnoremap <buffer> <silent> gs :call LanguageClient_textDocument_documentSymbol()<CR>
			" nnoremap <buffer> <silent> <F2> :call LanguageClient_textDocument_rename()<CR>
		endif
		return 1
	endif

	" Commands for windows
	command! -buffer UtilsCompilerGcc execute("compiler gcc<bar>:setlocal makeprg=mingw32-make")
	command! -buffer UtilsCompilerBorland call <SID>compiler_borland()
	command! -buffer UtilsCompilerMsbuild call <SID>compiler_msbuild(expand('%:p:h'))
	command! -buffer UtilsCompilerClangNeomake call <SID>compiler_clang()

	if exists(':Dispatch')
		" Time runtime of a specific program. Pass as Argument executable with arguments. Pass as Argument executable with
		" arguments. Example sep_calc.exe seprc.
		command! -nargs=+ -buffer UtilsTimeExec execute('Dispatch powershell -command "& {&'Measure-Command' {.\<f-args>}}"<cr>')
	endif

	" Set compiler now depending on folder and system. Auto set the compiler
	let folder_name = expand('%:p:h')

	" Note: inside the '' is a pat which is a regex. That is why \\
	if folder_name =~? 'Onewings\\Source'
		call <SID>compiler_borland()
	elseif folder_name =~# 'OneWings' || folder_name =~# 'UnrealProjects'
		call <SID>compiler_msbuild(folder_name)
	endif
endfunction

function! s:update_borland_makefile() abort
	" If compiler is not borland(set by SetupCompiler) fail.
	if !exists('b:current_compiler') || b:current_compiler !=# 'borland'
		echomsg 'Error, not in WINGS folder'
		return -1
	endif

	if empty(glob('WINGS.bpr')) " We may be in a different folder
		echomsg 'Failed to locate WINGS.bpr'
		return -2
	endif

	if !executable('bpr2mak')
		echomsg 'bpr2mak	is not executable'
		return -3
	endif

	call job_start(['bpr2mak', '-omakefile', 'WINGS.bpr'])
endfunction

function! s:compiler_clang() abort
	let b:neomake_cpp_enabled_makers = executable('clang') ? ['clangtidy', 'clangcheck'] : ['']
	let b:neomake_cpp_enabled_makers += executable('cppcheck') ? ['cppcheck'] : ['']
	let b:neomake_clang_args = '-target x86_64-pc-windows-gnu -std=c++1z -stdlib=libc++ -Wall -pedantic'
endfunction

function! s:compiler_borland() abort
	command! -buffer UtilsUpdateBorlandMakefile call <SID>update_borland_makefile()
	augroup Borland
		autocmd! * <buffer>
		autocmd BufWritePre <buffer=abuf> call <SID>update_borland_makefile()
	augroup end

	compiler borland
	" For Borland use only make
	let b:neomake_cpp_enabled_makers = ['make']
	let b:neomake_cpp_make_args = ['%:r.obj']
	let b:neomake_cpp_make_append_file = 0
endfunction

function! s:compiler_msbuild(curr_folder) abort
	compiler msbuild
	let &l:errorformat='%f(%l): %t%*[^ ] C%n: %m'


	" Compose VS project name base on the root folder of the current file
	let proj_name = utils#GetPathFolderName(a:curr_folder)
	if empty(proj_name)
		return
	endif

	" Compose solution name
	let proj_name .= filereadable(proj_name . '.sln') ? '.sln' : '.vcxproj'
	" Fix make_program
	let &l:makeprg='msbuild ' . proj_name . ' /nologo /v:q /property:GenerateFullPaths=true'

	let b:neomake_cpp_enabled_makers = ['msbuild']
	let b:neomake_cpp_msbuild_args = [
				\ proj_name,
				\ '/nologo',
				\ '/verbosity:quiet',
				\ '/property:GenerateFullPaths=true',
				\ '/property:SelectedFiles=%' ]
	let b:neomake_cpp_msbuild_append_file = 0
endfunction
