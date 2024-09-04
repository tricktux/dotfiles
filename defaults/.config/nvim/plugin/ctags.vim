" File:ctags.vim
"	Description: All functions related to creation/deletion/update/loading of ctags and cscope
" Author:Reinaldo Molina
" Version:1.0.0
" Last Modified: Fri Aug 30 2024 09:46
" Created: Sat Apr 01 2017 17:04

if exists('g:loaded_my_ctags')
	finish
endif

let g:loaded_my_ctags = 1

if !exists('g:ctags_use_cscope_for')
	let g:ctags_use_cscope_for = ['c', 'cpp', 'java']
endif

if !exists('g:ctags_output_dir')
	let g:ctags_output_dir =
				\ (has('unix') ? '/tmp/' : expand($TMP) . '\ctags\' )
endif

if !exists('g:ctags_rg_use_ft')
	let g:ctags_rg_use_ft = 1
endif

" cscope mappings
nmap <leader>pa <plug>cs_assignment_to_symbol
nnoremap <silent> <expr> <plug>cs_assignment_to_symbol (has('nvim') ? ':Cs' : ':cs') . ' find a <c-r><c-w><cr>'
nmap <leader>pc <plug>cs_funtions_calling_func
nnoremap <silent> <expr> <plug>cs_funtions_calling_func (has('nvim') ? ':Cs' : ':cs') . ' find c <c-r><c-w><cr>'
nmap <leader>pd <plug>cs_functions_called_by_func
nnoremap <silent> <expr> <plug>cs_functions_called_by_func (has('nvim') ? ':Cs' : ':cs') . ' find d <c-r><c-w><cr>'
nmap <leader>pe <plug>cs_egrep_pattern
nnoremap <silent> <expr> <plug>cs_egrep_pattern (has('nvim') ? ':Cs' : ':cs') . ' find e <c-r><c-w><cr>'
nmap <leader>pf <plug>cs_this_file
nnoremap <silent> <expr> <plug>cs_this_file (has('nvim') ? ':Cs find f<cr>' : ':cs f f<cr>')
nmap <leader>pg <plug>cs_definition
nnoremap <silent> <expr> <plug>cs_definition (has('nvim') ? ':Cs' : ':cs') . ' find g <c-r><c-w><cr>'
nmap <leader>pi <plug>cs_files_including_this_file
nnoremap <silent> <expr> <plug>cs_files_including_this_file (has('nvim') ? ':Cs' : ':cs') . ' find i <c-r><c-w><cr>'
nmap <leader>ps <plug>cs_c_symbol
nnoremap <silent> <expr> <plug>cs_c_symbol (has('nvim') ? ':Cs' : ':cs') . ' find s <c-r><c-w><cr>'
nmap <leader>pt <plug>cs_text_string
nnoremap <silent> <expr> <plug>cs_text_string (has('nvim') ? ':Cs' : ':cs') . ' find t <c-r><c-w><cr>'
nmap <leader>pk <plug>cs_kill_database
nnoremap <silent> <expr> <plug>cs_kill_database (has('nvim') ? ':Cs db rm<cr>' : ':cs kill -1<cr>')
nmap <leader>pn <plug>cs_add_database
nnoremap <silent> <expr> <plug>cs_add_database (has('nvim') ? ':Cs db add ' : ':cs add ') . ' add '
nmap <leader>ph <plug>cs_show_database
nnoremap <silent> <expr> <plug>cs_show_database (has('nvim') ? ':Cs db' : ':cs') . ' show<cr>'
nmap <leader>pj <plug>cs_ctags_generate
nnoremap <silent> <plug>cs_ctags_generate :call ctags#NvimSyncCtagsCscope()<cr>
nmap <leader>pl <plug>cs_ctags_load
nnoremap <silent> <plug>cs_ctags_load :call ctags#LoadCscopeDatabse()<cr>

" ctag mappings
nnoremap <c-]> g<c-]>
nnoremap <c-w><c-]> <c-w>g<c-]><c-w>L
if has('nvim')
	nmap <leader>pvu <plug>cstack_view_up
	nnoremap <silent> <plug>cstack_view_up :CsStackView open up<cr>
	nmap <leader>pvd <plug>cstack_view_down
	nnoremap <silent> <plug>cstack_view_down :CsStackView open down<cr>
	nmap <leader>pvt <plug>cstack_view_toggle
	nnoremap <silent> <plug>cstack_view_toggle :CsStackView toggle<cr>
endif

