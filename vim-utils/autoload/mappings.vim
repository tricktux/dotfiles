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
	" nnoremap <Leader>jk :call utils#Make()<CR>
	" ga " prints ascii of char under cursor
	" gA " prints radix of number under cursor
	" Untouchable g mappings: g;, gt, gr, gf, gd, g, gg, gs
	nmap gj <Plug>FileBrowser
	nmap gl <Plug>ToggleTerminal
	nmap <LocalLeader>m <Plug>Make
	nmap <LocalLeader>p <Plug>Preview

	" Global settings for all ftplugins
	nnoremap <LocalLeader>f :Neoformat<CR>
	nnoremap <LocalLeader>t :TagbarToggle<CR>

	" Refactor word under the cursor
	nnoremap <Leader>r :%s/\<<c-r>=expand("<cword>")<cr>\>//gc<Left><Left><Left>
	vnoremap <Leader>r "hy:%s/<C-r>h//gc<left><left><left>
	" duplicate current char
	nnoremap <Leader>d ylp
	" Reload syntax
	nnoremap <Leader>js <Esc>:syntax sync fromstart<CR>
	" Sessions
	nnoremap <Leader>jes :call utils#SaveSession()<CR>
	nnoremap <Leader>jel :call utils#LoadSession()<CR>
	nnoremap <Leader>jee :call utils#LoadSession('default.vim')<CR>
	" Count occurrances of last search
	nnoremap <Leader>jc :%s///gn<CR>
	" Indenting
	nnoremap <Leader>2 :setlocal ts=2 sw=2 sts=2<CR>
	nnoremap <Leader>4 :setlocal ts=4 sw=4 sts=4<CR>
	nnoremap <Leader>8 :setlocal ts=8 sw=8 sts=8<CR>
	" not paste the deleted word
	nnoremap P "0p
	vnoremap P "0p
	" Force wings_syntax on a file
	nnoremap <Leader>jw :set filetype=wings_syntax<CR>
	" Create file with name under the cursor
	" Diff Sutff
	nnoremap <Leader>j. :call utils#LastCommand()<CR>
	" j mappings taken <swypl;bqruihHdma248eEonf>
	" nnoremap <Leader>Mc :call utils#ManFind()<CR>
	nnoremap <C-s> :wa<CR>
	nnoremap <C-h> :noh<CR>
	nnoremap <C-Space> i<Space><Esc>
	" These are only for command line
	" insert in the middle of whole word search
	cnoremap <C-w> \<\><Left><Left>
	" insert visual selection search
	cnoremap <C-u> <c-r>=expand("<cword>")<cr>
	cnoremap <C-s> %s/
	cnoremap <C-j> <CR>
	cnoremap <C-p> <Up>
	cnoremap <C-A> <Home>
	cnoremap <C-F> <Right>
	cnoremap <C-B> <Left>
	" Sun Sep 17 2017 14:21: this will not work in vim 
	cnoremap <A-b> <S-Left>
	cnoremap <A-f> <S-Right>
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
	nnoremap <F5> i<Space><ESC>"=strftime("%a %b %d %Y %H:%M")<CR>P
	" Designed this way to be used with snippet md header
	vnoremap <F5> s<Space><ESC>"=strftime("%a %b %d %Y %H:%M")<CR>Pa
	inoremap <F5> <Space><ESC>"=strftime("%a %b %d %Y %H:%M")<CR>Pa
	" Auto indent pasted text
	nnoremap p p=`]<C-o>
	" Visual shifting (does not exit Visual mode)
	vnoremap < <gv
	vnoremap > >gv
	" Edit plugin
	nnoremap <Leader>ep :call utils#DeniteRec(g:vim_plugins_path)<CR>
	nnoremap <Leader>ei :e 

	" Vim-unimpaired similar mappings
	" Do not overwrite [s
	nnoremap ]y :call utils#YankFrom('+')<CR>
	nnoremap [y :call utils#YankFrom('-')<CR>

	nnoremap ]d :call utils#DeleteLine('+')<CR>
	nnoremap [d :call utils#DeleteLine('-')<CR>

	nnoremap ]o :call utils#CommentLine('+')<CR>
	nnoremap [o :call utils#CommentLine('-')<CR>

	nnoremap ]m :m +1<CR>
	nnoremap [m :m -2<CR>

	nnoremap ]f :call utils#GuiFont("+")<CR>
	nnoremap [f :call utils#GuiFont("-")<CR>

	" Quickfix and Location stuff
	" nnoremap <silent> <Leader>ll :call quickfix#ToggleList("Location List", 'l')<CR>
	nnoremap <silent> <S-q> :call quickfix#ToggleList("Quickfix List", 'c')<CR>
	nnoremap ]q :cnext<CR>
	nnoremap [q :cprevious<CR>

	nnoremap <S-u> :call quickfix#ToggleList("Location List", 'l')<CR>
	nnoremap ]l :lnext<CR>
	nnoremap [l :lprevious<CR>
	" nnoremap <Leader>ql :ccl<CR>
	" \:lcl<CR>

	" decrease number
	nnoremap <S-x> <c-x>
	vnoremap <S-x> <c-x>

	nnoremap <S-CR> O<Esc>
	" TODO-[RM]-(Mon Sep 18 2017 16:58): This is too rarely used. Turn it into
	" command
	" Display highlighted numbers as ascii chars. Only works on highlighted text
	vnoremap <Leader>ah :<c-u>s/<count>\x\x/\=nr2char(printf("%d", "0x".submatch(0)))/g<cr><c-l>`<
	vnoremap <Leader>ha :<c-u>s/\%V./\=printf("%x",char2nr(submatch(0)))/g<cr><c-l>`<

	" Search forward/backwards but return
	nnoremap * *N
	nnoremap # #N

	" Insert Mode (Individual) mappings
	inoremap <C-A> <C-O>yiW<End>=<C-R>=<C-R>0<CR>
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

	" Edit local <Leader>e?
	nnoremap <Leader>el :silent e ~/
	" cd into current dir path and into dir above current path
	nnoremap <Leader>e1 :call utils#DeniteRec(g:std_config_path . '/dotfiles')<CR>
	" Edit Vimruntime
	nnoremap <Leader>ev :call utils#DeniteRec($VIMRUNTIME)<CR>

	" CD <Leader>c?
	nnoremap <Leader>cd :lcd %:h<CR>
				\:pwd<CR>
	nnoremap <Leader>cu :lcd ..<CR>
				\:pwd<CR>
	" cd into dir. press <Tab> after ci to see folders
	nnoremap <Leader>ci :lcd
	nnoremap <Leader>cc :pwd<CR>
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
		nnoremap <A-l> :call Focus('right', 'l')<CR>
		nnoremap <A-h> :call Focus('left', 'h')<CR>
		nnoremap <A-k> :call Focus('up', 'k')<CR>
		nnoremap <A-j> :call Focus('down', 'j')<CR>
	elseif has('unix') && executable('tmux') && exists('$TMUX')
		nnoremap <A-h> :call utils#TmuxMove('h')<cr>
		nnoremap <A-j> :call utils#TmuxMove('j')<cr>
		nnoremap <A-k> :call utils#TmuxMove('k')<cr>
		nnoremap <A-l> :call utils#TmuxMove('l')<cr>
	elseif !has('nvim') && has('terminal')
		nnoremap <silent> <A-l> <C-\><C-n><C-w>l
		nnoremap <silent> <A-h> <C-\><C-n><C-w>h
		nnoremap <silent> <A-k> <C-\><C-n><C-w>k
		nnoremap <silent> <A-j> <C-\><C-n><C-w>j
	else
		nnoremap <silent> <A-l> <C-w>l
		nnoremap <silent> <A-h> <C-w>h
		nnoremap <silent> <A-k> <C-w>k
		nnoremap <silent> <A-j> <C-w>j
	endif

	" Spell Check <Leader>s?
	" search forward
	" nnoremap <Leader>sj ]s
	" search backwards
	" nnoremap <Leader>sk [s
	" suggestion
	" nnoremap <Leader>sc z=
	" toggle spelling
	nnoremap =os :setlocal spell! spelllang=en_us<CR>
	inoremap <C-S> <c-r>=utils#FixPreviousWord()
	" add to dictionary
	" nnoremap <Leader>sa zg
	" mark wrong
	" nnoremap <Leader>sw zw
	" repeat last spell correction

	" Search <Leader>S
	" Tried ack.vim. Discovered that nothing is better than grep with ag.
	" search all type of files
	nnoremap gs :call utils#Grep()<cr>
	" Search visual selection text
	vnoremap // y/<C-R>"<CR>

	" Substitute for ESC
	execute "vnoremap " . g:esc . " <Esc>"
	execute "inoremap " . g:esc . " <Esc>"

	" Buffers Stuff <Leader>b?
	if !exists("g:plugins_loaded")
		nnoremap <S-k> :buffers<CR>:buffer<Space>
	else
		nnoremap <Leader>bs :buffers<CR>:buffer<Space>
	endif
	nnoremap <Leader>bd :bp\|bw #\|bd #<CR>
	nnoremap <S-j> :b#<CR>
	" deletes all buffers
	nnoremap <Leader>bl :%bd<CR>
	" nnoremap <Leader>bS :bufdo
	" " move tab to the left
	" nnoremap <silent> <A-Left> :execute 'silent! tabmove ' . (tabpagenr()-2)<CR>
	" " move tab to the right
	" nnoremap <silent> <A-Right> :execute 'silent! tabmove ' . (tabpagenr()+1)<CR>
	" nnoremap <Leader>be :enew<CR>

	" Tabs <Leader>a?
	" open new to tab to explorer
	" nnoremap <S-Tab> gT
	" nnoremap <S-e> :tab split<CR>
	" nnoremap <S-x> :tabclose<CR>

	" Version Control <Leader>v?
	" For all this commands you should be in the svn root folder
	" Add all files
	nnoremap <Leader>vA :!svn add . --force<CR>
	" Add specific files
	nnoremap <Leader>va :!svn add --force
	" Commit using typed message
	nnoremap <Leader>vc :call utils#SvnCommit()<CR>
	" Commit using File for commit content
	nnoremap <Leader>vC :!svn commit --force-log -F %<CR>
	nnoremap <Leader>vd :!svn rm --force
	" revert previous commit
	"nnoremap <Leader>vr :!svn revert -R .<CR>
	nnoremap <Leader>vl :!svn cleanup .<CR>
	" use this command line to delete unrevisioned or "?" svn files
	" nnoremap <Leader>vL :!for /f "tokens=2*" %i in ('svn status ^| find "?"') do del %i<CR>
	" nnoremap <Leader>vs :!svn status .<CR>
	nnoremap <Leader>vu :!svn update .<CR>
	" Overwritten from plugin.vim
	" nnoremap <Leader>vo :!svn log .<CR>
	" nnoremap <Leader>vi :!svn info<CR>

	" Tags mappings
	" nnoremap <silent> gt <C-]>
	" nnoremap gr <C-t>

	" Wiki mappings <Leader>w?
	" TODO.RM-Thu Dec 15 2016 16:00: Add support for wiki under SW-Testbed
	nnoremap <Leader>wt :call utils#WikiOpen('TODO.md')<CR>
	nnoremap <Leader>wo :call utils#WikiOpen()<CR>
	nnoremap <Leader>ws :call utils#WikiSearch()<CR>
	nnoremap <Leader>wm :call utils#MastersDropboxOpen('')<CR>

	" Comments <Leader>o
	nmap - <plug>NERDCommenterToggle
	" nmap <Leader>ot <plug>NERDCommenterAltDelims
	vmap - <plug>NERDCommenterToggle
	imap <C-c> <plug>NERDCommenterInsert
	" mapping ol conflicts with mapping o to new line
	nnoremap <Leader>oe :call utils#EndOfIfComment()<CR>
	nnoremap <Leader>ou :call utils#UpdateHeader()<CR>
	nnoremap <Leader>ot :call utils#TodoAdd()<CR>
	nmap <Leader>oa <Plug>NERDCommenterAppend
	nnoremap <Leader>od :call utils#CommentDelete()<CR>
	" Comment Indent Increase/Reduce
	nnoremap <Leader>oi :call utils#CommentIndent()<CR>
	nnoremap <Leader>oI :call utils#CommentReduceIndent()<CR>
endfunction

" vim:tw=78:ts=2:sts=2:sw=2:
