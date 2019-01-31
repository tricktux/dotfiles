" File:           mail.vim
" Description:    Options for writing emails
" Author:		    Reinaldo Molina
" Email:          rmolin88 at gmail dot com
" Revision:	    0.0.0
" Created:        Mon Jan 15 2018 05:56
" Last Modified:  Mon Jan 15 2018 05:56


" Only do this when not done yet for this buffer
if exists('b:did_mail_ftplugin')
	finish
endif

" Don't load another plugin for this buffer
let b:did_mail_ftplugin = 1

if !exists("no_plugin_maps") && !exists("no_mail_maps")
	nnoremap <buffer> <localleader>s :call <sid>insert_signature()<cr>
endif

function! s:insert_signature() abort
	let signature = "Thanks,\nReinaldo Molina"
	execute "normal! i" . signature . "\<esc>"
endfunction
