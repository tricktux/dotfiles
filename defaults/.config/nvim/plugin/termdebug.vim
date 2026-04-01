
if exists(':packadd') == 0
  finish
endif

if exists('g:loaded_my_debug')
  finish
endif

let g:loaded_my_debug = 1

" Termdebug config
let g:termdebug_config = {}
let g:termdebug_config["disasm_window"] = 0

silent! packadd! termdebug

nnoremap <leader>dL :packadd termdebug<cr>
nnoremap <leader>dl :Termdebug 
nnoremap <leader>dr :Run<cr>
nnoremap <leader>db :Break<cr>
nnoremap <leader>dd :Clear<cr>
nnoremap <leader>dc :Continue<cr>
nnoremap <leader>df :Finish<cr>
nnoremap <leader>ds :Step<cr>
nnoremap <leader>dn :Over<cr>
nnoremap <leader>du :Until<cr>
nnoremap <leader>dS :call TermDebugSendCommand('frame')<cr>
nnoremap <leader>dw :call TermDebugSendCommand('where')<cr>
nnoremap <leader>dt :call TermDebugSendCommand('bt')<cr>
nnoremap <leader>dg :Gdb<cr>
nnoremap <leader>da :Asm<cr>
nnoremap <leader>dq :call TermDebugSendCommand('quit')<cr>

" Others
silent! packadd! comment
nmap <bs> gcc
xmap <bs> gc
silent! packadd! editorconfig
