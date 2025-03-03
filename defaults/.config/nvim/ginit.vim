" File:           ginit.vim
" Description:    Settings applied before gui is loaded.
" Author:         Reinaldo Molina <rmolin88 at gmail dot com>
" Version:        0.0.0
" Last Modified:  Oct 27 2017 08:16
" Created:        Oct 27 2017 08:16

let s:font = "Cascadia Code:h8"

function! s:set_nvim_qt() abort
  execute "GuiFont " . s:font
	GuiTabline 0
	GuiPopupmenu 0
endfunction

function! s:set_gui() abort
  if exists('g:GuiLoaded')
    call s:set_nvim_qt()
    return
  end
	if exists('g:neovide')
    call v:lua.require'plugin.neovide'.setup()
    return
  end

  echomsg "Unrecognized GUI Application..."
endfunction

call s:set_gui()
