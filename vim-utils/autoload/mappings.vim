" File:					mappings.vim
" Description:	Function that sets all the mappings that are not related to plugins
" Author:				Reinaldo Molina <rmolin88@gmail.com>
" Version:				0.0.0
" Last Modified: Aug 22 2017 12:33
" Created: Aug 22 2017 12:33

function! mappings#Set() abort
	" CUSTOM MAPPINGS
	" List of super useful mappings
	" = fixes indentantion
	" gq formats code
	" Free keys: <Leader>fnzxkiy;h
	" Taken keys: <Leader>qwertasdjcvgp<space>mbolu
	let g:esc = '<C-j>'

	" FileType Specific mappings use <Leader>l
	" Refer to ~/.dotfiles/vim-utils/after/ftplugin to find these

	" j and k
	" Display line movements unless preceded by a count and
	" Save movements larger than 5 lines to the jumplist. Use Ctrl-o/Ctrl-i.
	nnoremap <expr> j v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj'
	nnoremap <expr> k v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk'

	" Miscelaneous Mappings <Leader>j?
	" nnoremap <Leader>Ma :Man
	" Most used misc get jk, jj, jl, j;
	" TODO.RM-Fri Apr 28 2017 14:25: Go through mappings and figure out the
	" language specific ones so that you can move them into ftplugin
	" nnoremap <Leader>jk :call utils#Make()<cr>
	" ga " prints ascii of char under cursor
	" gA " prints radix of number under cursor
	" Untouchable g mappings:
	" - gd, gD, g;, gq, gs, gl, gA, gT, gg, G, gG, gh, gv
	" Toggle mappings:
	" - tj, te, ta, tt, tf, ts, to, tn
	nmap <Leader>tj <Plug>file_browser
	nmap <s-k> <plug>buffer_browser
	nmap <c-p> <plug>mru_browser
	" terminal-emulator mappings
	if has('terminal') || has('nvim')
		nmap <Leader>te <Plug>terminal_toggle
		vmap <LocalLeader>s <Plug>terminal_selection_send
		execute "tnoremap " . g:esc . " <C-\\><C-n>"
		tnoremap <A-h> <C-\><C-n><C-w>h
		tnoremap <A-j> <C-\><C-n><C-w>j
		tnoremap <A-k> <C-\><C-n><C-w>k
		tnoremap <A-l> <C-\><C-n><C-w>l

		tnoremap <C-p> <Up>
	endif
	nmap <LocalLeader>m <Plug>MakeProject
	nmap <LocalLeader>M <Plug>MakeFile
	nmap <LocalLeader>p <Plug>Preview

	nmap <Leader>cr <plug>cd_root

	" UtilsTagUpdateCurrFolder
	nnoremap <silent> <LocalLeader>t :call ctags#NvimSyncCtags()<cr>

	nnoremap <Leader>tt :TagbarToggle<cr>
	nnoremap <Leader>ts :setlocal spell! spelllang=en_us<cr>

	" Global settings for all ftplugins
	nnoremap <LocalLeader>f :Neoformat<cr>

	" Refactor word under the cursor
	nnoremap <Leader>r :%s/\<<c-r>=expand("<cword>")<cr>\>//gc<Left><Left><Left>
	vnoremap <Leader>r "hy:%s/<C-r>h//gc<left><left><left>
	" duplicate current char
	nnoremap <Leader>d ylp
	" Reload syntax
	nnoremap <Leader>js <Esc>:syntax sync fromstart<cr>
	" Sessions
	nnoremap <Leader>jes :call s:save_session()<cr>
	nnoremap <Leader>jel :call s:load_session()<cr>
	nnoremap <Leader>jee :call s:load_session('default.vim')<cr>
	" Count occurrances of last search
	nnoremap <Leader>jc :%s///gn<cr>
	" Indenting
	nnoremap <Leader>2 :setlocal ts=2 sw=2 sts=2<cr>
	nnoremap <Leader>4 :setlocal ts=4 sw=4 sts=4<cr>
	nnoremap <Leader>8 :setlocal ts=8 sw=8 sts=8<cr>
	" not paste the deleted word
	nnoremap P "0p
	vnoremap P "0p
	" Force wings_syntax on a file
	nnoremap <Leader>jw :set filetype=wings_syntax<cr>
	" Create file with name under the cursor
	" Diff Sutff
	nnoremap <Leader>j. :call utils#LastCommand()<cr>
	" j mappings taken <swypl;bqruihHdma248eEonf>
	" nnoremap <Leader>Mc :call utils#ManFind()<cr>
	" Tue Dec 19 2017 14:34: Removing the save all files. Not a good thing to do.
	" - Main reason is specially with Neomake running make an multiple files at the same
	"   time
	nnoremap <C-s> :w<cr>
	" Thu Feb 22 2018 07:42: Mind buggling super good mapping from vim-galore
	" Tue Apr 24 2018 14:06: For some reason in large .cpp files syntax sync takes away
	" highlight
	" nnoremap <c-h> :nohlsearch<cr>:diffupdate<cr>:syntax sync fromstart<cr><c-l>
	nnoremap <c-h> :nohlsearch<cr>:diffupdate<cr><c-l>
	nnoremap <C-Space> i<Space><Esc>
	" These are only for command line
	" insert in the middle of whole word search
	cnoremap <C-w> \<\><Left><Left>
	" insert visual selection search
	cnoremap <C-u> <c-r>=expand("<cword>")<cr>
	cnoremap <C-s> %s/
	cnoremap <C-j> <cr>
	cnoremap <C-p> <Up>
	cnoremap <C-A> <Home>
	cnoremap <C-F> <Right>
	cnoremap <C-B> <Left>
	" Sun Sep 17 2017 14:21: this will not work in vim
	cnoremap <A-b> <S-Left>
	cnoremap <A-f> <S-Right>

	cnoremap <silent> <expr> <cr> s:center_search()
	" move to the beggning of line
	" Don't make this nnoremap. Breaks stuff
	nnoremap <S-w> $
	vnoremap <S-w> $
	" move to the end of line
	nnoremap <S-b> ^
	vnoremap <S-b> ^
	" jump to corresponding item<Leader> ending {,(, etc..
	nmap <S-t> %
	vmap <S-t> %
	" Automatically insert date
	nnoremap <F5> i<Space><ESC>"=strftime("%a %b %d %Y %H:%M")<cr>P
	" Designed this way to be used with snippet md header
	vnoremap <F5> s<Space><ESC>"=strftime("%a %b %d %Y %H:%M")<cr>Pa
	inoremap <F5> <Space><ESC>"=strftime("%a %b %d %Y %H:%M")<cr>Pa
	" Auto indent pasted text
	nnoremap p p=`]<C-o>
	" Visual shifting (does not exit Visual mode)
	vnoremap < <gv
	vnoremap > >gv

	" Vim-unimpaired similar mappings
	" Do not overwrite [s, [c, [f
	" Overwitting [c to make it more useful
	nnoremap ]c ]czz
	nnoremap [c [czz

	nnoremap ]y :call s:yank_from('+')<cr>
	nnoremap [y :call s:yank_from('-')<cr>

	nnoremap ]d :call s:delete_line('+')<cr>
	nnoremap [d :call s:delete_line('-')<cr>

	nnoremap ]o :call s:comment_line('+')<cr>
	nnoremap [o :call s:comment_line('-')<cr>

	nnoremap ]m :m +1<cr>
	nnoremap [m :m -2<cr>

	" Quickfix and Location stuff
	nnoremap <silent> <s-q> :call quickfix#ToggleList("Quickfix List", 'c')<cr>
	nnoremap ]q :cnext<cr>
	nnoremap [q :cprevious<cr>

	nnoremap <s-u> :call quickfix#ToggleList("Location List", 'l')<cr>
	nnoremap ]l :lnext<cr>
	nnoremap [l :lprevious<cr>
	nnoremap Y y$

	nnoremap ]t <c-]>
	nnoremap [t <c-t>
	" Split window and jump to tag
	" nnoremap ]T :exec 'ptag ' . expand('<cword>')<cr><c-w>R
	nnoremap ]T :let word=expand('<cword>')<cr><c-w>l:exec 'tag ' . word<cr>
	nnoremap [T :let word=expand('<cword>')<cr><c-w>h:exec 'tag ' . word<cr>

	" Capital F because [f is go to file and this is rarely used
	" ]f native go into file.
	" [f return from file
	nnoremap [f <c-o>
	nnoremap ]F :let file=expand('<cfile>')<cr><c-w>l:exec 'edit ' . file<cr>
	nnoremap [F :let file=expand('<cfile>')<cr><c-w>h:exec 'edit ' . file<cr>

	" decrease number
	nnoremap <S-x> <c-x>
	vnoremap <S-x> <c-x>

	nnoremap <S-CR> O<Esc>
	" TODO-[RM]-(Mon Sep 18 2017 16:58): This is too rarely used. Turn it into
	" command
	" Display highlighted numbers as ascii chars. Only works on highlighted text
	vnoremap <Leader>ah :<c-u>s/<count>\x\x/\=nr2char(printf("%d", "0x".submatch(0)))/g<cr><c-l>`<
	vnoremap <Leader>ha :<c-u>s/\%V./\=printf("%x",char2nr(submatch(0)))/g<cr><c-l>`<

	nnoremap <expr> n 'Nnzz'[v:searchforward]
	nnoremap <expr> N 'nNzz'[v:searchforward]

	" Search forward/backwards but return
	nnoremap * *zz
	nnoremap # #zz

	" Insert Mode (Individual) mappings
	" TODO-[RM]-(Sat Oct 21 2017 10:32): Change this here for fix previous word.
	" This has never worked nor is ever used
	inoremap <C-A> <C-O>yiW<End>=<C-R>=<C-R>0<cr>
	inoremap <c-f> <del>
	inoremap <C-F> <Right>
	inoremap <C-B> <Left>
	" Sun Sep 17 2017 14:21: this will not work in vim
	inoremap <A-b> <S-Left>
	inoremap <A-f> <S-Right>

	" Fri Sep 29 2017 14:20: Break up long text into smaller, better undo
	" chunks. See :undojoin
	" For normal text typing
	inoremap . .<c-g>u
	inoremap , ,<c-g>u
	inoremap ? ?<c-g>u
	inoremap ! !<c-g>u
	" For cpp
	inoremap ; ;<c-g>u
	inoremap = =<c-g>u


	" CD <Leader>c?
	nnoremap <Leader>cd :lcd %:h<cr>
				\:pwd<cr>
	nnoremap <Leader>cu :lcd ..<cr>
				\:pwd<cr>
	" cd into dir. press <Tab> after ci to see folders
	nnoremap <Leader>ci :lcd
	nnoremap <Leader>cc :pwd<cr>
	" TODO.RM-Thu Jun 01 2017 10:10: Create mappings like c21 and c22

	" Folding
	" Folding select text then S-f to fold or just S-f to toggle folding
	nnoremap <C-j> zj
	nnoremap <C-k> zk
	nnoremap <C-z> zz
	nnoremap <C-c> zM
	nnoremap <C-n> zR
	nnoremap <C-x> za
	" dont use <C-a> it conflicts with tmux prefix

	" Window movement
	" move between windows
	if exists('*Focus') && executable('i3-vim-nav')
		" i3 integration
		nnoremap <A-l> :call Focus('right', 'l')<cr>
		nnoremap <A-h> :call Focus('left', 'h')<cr>
		nnoremap <A-k> :call Focus('up', 'k')<cr>
		nnoremap <A-j> :call Focus('down', 'j')<cr>
	elseif has('unix') && executable('tmux') && exists('$TMUX')
		nnoremap <A-h> :call utils#TmuxMove('h')<cr>
		nnoremap <A-j> :call utils#TmuxMove('j')<cr>
		nnoremap <A-k> :call utils#TmuxMove('k')<cr>
		nnoremap <A-l> :call utils#TmuxMove('l')<cr>
	else
		nnoremap <silent> <A-l> <C-w>l
		nnoremap <silent> <A-h> <C-w>h
		nnoremap <silent> <A-k> <C-w>k
		nnoremap <silent> <A-j> <C-w>j
		nnoremap <silent> <A-S-l> <C-w>>
		nnoremap <silent> <A-S-h> <C-w><
		nnoremap <silent> <A-S-k> <C-w>+
		nnoremap <silent> <A-S-j> <C-w>-
	endif

	inoremap <C-S> <c-r>=utils#FixPreviousWord()<cr>

	" Search <Leader>S
	" Tried ack.vim. Discovered that nothing is better than grep with ag.
	" search all type of files
	" Search visual selection text
	vnoremap // y/<C-R>"<cr>

	" Substitute for ESC
	execute "vnoremap " . g:esc . " <Esc>"
	execute "inoremap " . g:esc . " <Esc>"

	" Buffers Stuff <Leader>b?
	if !exists("g:loaded_plugins")
		nnoremap <S-k> :buffers<cr>:buffer<Space>
	else
		nnoremap <Leader>bs :buffers<cr>:buffer<Space>
	endif
	nnoremap <Leader>bd :bp\|bw #\|bd #<cr>
	nnoremap <S-j> :b#<cr>
	" deletes all buffers
	nnoremap <Leader>bl :%bd<cr>

	" Version Control <Leader>v?
	" For all this commands you should be in the svn root folder
	" Add all files
	nnoremap <Leader>vA :!svn add . --force<cr>
	" Add specific files
	nnoremap <Leader>va :!svn add --force
	" Commit using typed message
	nnoremap <Leader>vc :call utils#SvnCommit()<cr>
	" Commit using File for commit content
	nnoremap <Leader>vC :!svn commit --force-log -F %<cr>
	nnoremap <Leader>vd :!svn rm --force
	" revert previous commit
	"nnoremap <Leader>vr :!svn revert -R .<cr>
	nnoremap <Leader>vl :!svn cleanup .<cr>
	" use this command line to delete unrevisioned or "?" svn files
	" nnoremap <Leader>vL :!for /f "tokens=2*" %i in ('svn status ^| find "?"') do del %i<cr>
	" nnoremap <Leader>vs :!svn status .<cr>
	nnoremap <Leader>vu :!svn update .<cr>
	" Overwritten from plugin.vim
	" nnoremap <Leader>vo :!svn log .<cr>
	" nnoremap <Leader>vi :!svn info<cr>

	" Wiki mappings <Leader>w?
	" TODO.RM-Thu Dec 15 2016 16:00: Add support for wiki under SW-Testbed
	nnoremap <Leader>wt :call utils#WikiOpen('TODO.md')<cr>
	nnoremap <Leader>wo :call utils#WikiOpen()<cr>
	nnoremap <Leader>ws :call utils#WikiSearch()<cr>
	nnoremap <Leader>wm :call utils#MastersDropboxOpen('')<cr>

	" Comments <Leader>o
	nmap - <plug>NERDCommenterToggle
	" nmap <Leader>ot <plug>NERDCommenterAltDelims
	vmap - <plug>NERDCommenterToggle
	imap <C-c> <plug>NERDCommenterInsert
	nnoremap <Leader>oI :call utils#CommentReduceIndent()<cr>
	nmap <Leader>to <plug>NERDCommenterAltDelims
	" mapping ol conflicts with mapping o to new line
	nnoremap <Leader>oe :call utils#EndOfIfComment()<cr>
	nnoremap <Leader>ou :call utils#UpdateHeader()<cr>
	nnoremap <Leader>ot :call utils#TodoAdd()<cr>
	nmap <Leader>oa <Plug>NERDCommenterAppend
	nnoremap <Leader>od :call utils#CommentDelete()<cr>
	" Comment Indent Increase/Reduce
	nnoremap <Leader>oi :call utils#CommentIndent()<cr>

	" Edit file at location <Leader>e?
	nnoremap <Leader>ed :call utils#DeniteRec(g:std_config_path . '/dotfiles')<cr>
	nnoremap <Leader>em :call utils#DeniteRec('~/Seafile/masters/')<cr>
	nnoremap <Leader>ec :call utils#DeniteRec(getcwd())<cr>
	nnoremap <Leader>el :call utils#DeniteRec(input('Folder to recurse: ', "", "file"))<cr>
	nnoremap <Leader>et :execute('edit ' . g:std_config_path . '/dotfiles/TODO.md')<cr>
	" Edit plugin
	nnoremap <Leader>ep :call utils#DeniteRec(g:vim_plugins_path)<cr>
	nnoremap <Leader>ei :e
	" Edit Vimruntime
	nnoremap <Leader>ev :call utils#DeniteRec($VIMRUNTIME)<cr>
endfunction


function! s:save_session(...) abort
	let session_path = g:std_data_path . '/sessions/'
	" if session name is not provided as function argument ask for it
	if a:0 < 1
		execute "wall"
		let dir = getcwd()
		execute "cd ". session_path
		let session_name = input("Enter save session name:", "", "file")
		silent! execute "cd " . dir
	else
		" Need to keep this option short and sweet
		let session_name = a:1
	endif
	silent! execute "mksession! " . session_path . session_name
endfunction

function! s:load_session(...) abort
	let session_path = g:std_data_path . '/sessions/'
	" Logic path when not called at startup
	if a:0 >= 1
		let session_name = session_path . a:1
		if !filereadable(session_name)
			echoerr '[s:load_session]: File ' . session_name . ' not readabale'
			return
		endif
		silent! execute "normal :%bdelete\<CR>"
		silent! execute "normal :so " . session_path . a:1 . "\<CR>"
		return
	endif

	execute "wall"
	let response = confirm("Are you sure? This will unload all buffers?", "&Jes\n&No(def.)")
	if response != 1
		return -1
	endif

	if exists(':Denite')
		call setreg(v:register, "") " Clean up register
		execute "Denite -default-action=yank -path=" . session_path . " file_rec"
		let session_name = getreg()
		if !filereadable(session_path . session_name)
			return
		endif
	else
		let dir = getcwd()
		execute "cd ". session_path
		let session_name = input("Load session:", "", "file")
		silent! execute "cd " . dir
	endif
	silent! execute "normal :%bdelete\<CR>"
	silent execute "source " . session_path . session_name
endfunction

function! s:center_search() abort
	let cmdtype = getcmdtype()
	if cmdtype ==# '/' || cmdtype ==# '?'
		return '\<cr>zz'
	endif
	return "\<cr>"
endfunction

function! s:yank_from(sign) abort
	let in = s:parse_line_mod_input('Yank',  a:sign)
	execute "normal :" . in . "y\<CR>p"
endfunction

" msg - {Comment, Delete, Paste, Yank}
" sing - {+,-}
" Returns: Modified input
function! s:parse_line_mod_input(msg, sign) abort
	let in = input(a:msg . " Line:")
	let in = a:sign . in
	let comma = stridx(in, ',')
	if comma > -1
		return strcharpart(in, 0,comma+1) . a:sign . strcharpart(in, comma+1)
	endif

	return in
endfunction

function! s:delete_line(sign) abort
	let in = s:parse_line_mod_input('Delete',  a:sign)
	execute "normal :" . in . "d\<CR>``"
endfunction

function! s:comment_line(sign) abort
	if !exists("*NERDComment")
		echo "Please install NERDCommenter"
		return
	endif

	let in = utils#ParseLineModificationInput('Comment',  a:sign)
	execute "normal mm:" . in . "\<CR>"
	execute "normal :call NERDComment(\"n\", \"Toggle\")\<CR>`m"
endfunction

function! utils#LastCommand() abort
	execute "normal :\<Up>\<CR>"
endfunction

