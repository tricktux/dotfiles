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

setlocal wrap
setlocal spell spelllang=es,en
setlocal formatoptions+=aw
" setlocal omnifunc=muttaliases#CompleteMuttAliases

" if !exists('no_plugin_maps') && !exists('no_mail_maps')
" endif
