" File:					commands.vim
" Description:	Universal commands
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:				0.0.0
" Last Modified: Oct 18 2017 13:52
" Created: Oct 18 2017 13:52

" CUSTOM_COMMANDS
function! commands#Set() abort
	command! UtilsIndentWholeFile execute("normal! mzgg=G`z")
	command! UtilsFileFormat2Dos :e ++ff=dos<CR>

	if !exists('g:loaded_plugins')
		return
	endif

	" Convention: All commands names need to start with the autoload file name.
	" And use camel case. This way is easier to search
	command! -nargs=+ -complete=command UtilsCaptureCmdOutput call utils#CaptureCmdOutput(<f-args>)
	command! UtilsProfile call utils#ProfilePerformance()
	command! UtilsDiffSet call utils#SetDiff()
	command! UtilsDiffOff call utils#UnsetDiff()
	command! UtilsDiffReset call utils#UnsetDiff()<bar>call utils#SetDiff()
	" Remove Trailing Spaces
	command! UtilsRemoveTrailingSpaces call utils#TrimWhiteSpace()
	" Convert fileformat to dos
	command! UtilsNerdComAltDelims execute("normal \<Plug>NERDCommenterAltDelims")
	command! UtilsPdfSearch call utils#SearchPdf()
	command! UtilsTagLoadCurrFolder call ctags#LoadCscopeDatabse()
	command! UtilsTagUpdateCurrFolder call ctags#NvimSyncCtags()
endfunction
