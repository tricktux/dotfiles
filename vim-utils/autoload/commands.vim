

function commands#Set() abort
	" CUSTOM_COMMANDS
	" TODO.RM-Fri Jun 02 2017 16:10: Keep doing this. Until you Substitute
	" all rarely used <Leader>j mappings for commands

	" Convention: All commands names need to start with the autoload file name.
	" And use camel case. This way is easier to search
	command! -nargs=+ -complete=command UtilsCaptureCmdOutput call utils#CaptureCmdOutput(<f-args>)
	command! UtilsProfile call utils#ProfilePerformance()
	command! UtilsDiffSet call utils#SetDiff()
	command! UtilsDiffOff call utils#UnsetDiff()
	command! UtilsDiffReset call utils#UnsetDiff()<bar>call utils#SetDiff()
	command! UtilsIndentWholeFile execute("normal! mzgg=G`z")
	" Remove Trailing Spaces
	command! UtilsRemoveTrailingSpaces execute('let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>')
	" Convert fileformat to dos
	command! UtilsFileFormat2Dos :e ++ff=dos<CR>
endfunction

" vim:tw=78:ts=2:sts=2:sw=2:
