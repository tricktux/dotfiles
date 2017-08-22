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

	" Quickfix and Location stuff
	nnoremap <Leader>qO :lopen 20<CR>
	nnoremap <Leader>qo :call quickfix#OpenQfWindow()<CR>
	" nnoremap <silent> <Leader>ll :call quickfix#ToggleList("Location List", 'l')<CR>
	nnoremap <silent> U :call quickfix#ToggleList("Quickfix List", 'c')<CR>
	nnoremap <Leader>ln :call quickfix#ListsNavigation("next")<CR>
	nnoremap <Leader>lp :call quickfix#ListsNavigation("previous")<CR>
	nnoremap <Leader>qn :call quickfix#ListsNavigation("next")<CR>
	nnoremap <Leader>qp :call quickfix#ListsNavigation("previous")<CR>
	nnoremap <Leader>ql :ccl<CR>
				\:lcl<CR>

	" FileType Specific mappings use <Leader>l
	" Refer to ~/.dotfiles/vim-utils/after/ftplugin to find these

	" j and k
	" Display line movements unless preceded by a count and
	" Save movements larger than 5 lines to the jumplist. Use Ctrl-o/Ctrl-i.
	nnoremap <expr> j v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj'
	nnoremap <expr> k v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk'

	nnoremap <Leader>la :call utils#TodoAdd()<CR>
	nnoremap <Leader>lf :Autoformat<CR>
	nnoremap <Leader>lt :TagbarToggle<CR>

	" Miscelaneous Mappings <Leader>j?
	" nnoremap <Leader>Ma :Man
	" Most used misc get jk, jj, jl, j;
	" TODO.RM-Fri Apr 28 2017 14:25: Go through mappings and figure out the
	" language specific ones so that you can move them into ftplugin
	" nnoremap <Leader>jk :call utils#Make()<CR>
	" ga " prints ascii of char under cursor
	" gA " prints radix of number under cursor
	" Untouchable g mappings: g;, gt, gr, gf, gd, g, gg, gs
	nnoremap gl :e $MYVIMRC<CR>
	nmap gj <Plug>FileBrowser
	nmap gk <Plug>Make

	" Refactor word under the cursor
	nnoremap <Leader>r :%s/\<<c-r>=expand("<cword>")<cr>\>//gc<Left><Left><Left>
	vnoremap <Leader>r "hy:%s/<C-r>h//gc<left><left><left>
	" duplicate current char
	nnoremap <Leader>d ylp
	vnoremap <Leader>d ylp
	" Reload syntax
	nnoremap <Leader>js <Esc>:syntax sync fromstart<CR>
	" Sessions
	nnoremap <Leader>jes :call utils#SaveSession()<CR>
	nnoremap <Leader>jel :call utils#LoadSession()<CR>
	nnoremap <Leader>jee :call utils#LoadSession('default.vim')<CR>
	" Count occurrances of last search
	nnoremap <Leader>jc :%s///gn<CR>
	" Indenting
	nnoremap <Leader>j2 :setlocal ts=2 sw=2 sts=2<CR>
	nnoremap <Leader>j4 :setlocal ts=4 sw=4 sts=4<CR>
	nnoremap <Leader>j8 :setlocal ts=8 sw=8 sts=8<CR>
	" not paste the deleted word
	nnoremap <Leader>p "0p
	vnoremap <Leader>p "0p
	" Force wings_syntax on a file
	nnoremap <Leader>jw :set filetype=wings_syntax<CR>
	" Create file with name under the cursor
	" Diff Sutff
	nnoremap <Leader>j. :call utils#LastCommand()<CR>
	nnoremap <Leader>- :call utils#GuiFont("-")<CR>
	nnoremap <Leader>= :call utils#GuiFont("+")<CR>

	" j mappings taken <swypl;bqruihHdma248eEonf>
	" nnoremap <Leader>Mc :call utils#ManFind()<CR>
	nnoremap <C-s> :wa<CR>
	nnoremap <C-h> :noh<CR>
	nnoremap <C-Space> i<Space><Esc>
	" move current line up
	nnoremap <Leader>K ddkk""p
	" move current line down
	nnoremap <Leader>J dd""p
	" These are only for command line
	" insert in the middle of whole word search
	cnoremap <C-w> \<\><Left><Left>
	" insert visual selection search
	cnoremap <C-u> <c-r>=expand("<cword>")<cr>
	cnoremap <C-s> %s/
	" refactor
	"vnoremap <Leader>r :%s///gc<Left><Left><Left>
	cnoremap <C-p> <c-r>0
	cnoremap <C-j> <Down>
	cnoremap <C-k> <Up>
	cnoremap <C-j> <Left>
	cnoremap <C-l> <Right>
	" Switch back and forth between header file
	nnoremap <S-q> yyp
	" move to the beggning of line
	" Don't make this nnoremap. Breaks stuff
	noremap <S-w> $
	vnoremap <S-w> $
	" move to the end of line
	nnoremap <S-b> ^
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
	nnoremap P P=`]<C-o>
	" Visual shifting (does not exit Visual mode)
	vnoremap < <gv
	vnoremap > >gv
	" Edit plugin
	nnoremap <Leader>ep :call utils#EditFileInPath(g:vim_plugins_path)<CR>
	nnoremap <Leader>ei :e 

	" decrease number
	nnoremap <Leader>a <c-x>
	vnoremap <Leader>a <c-x>

	nnoremap yl :call utils#YankFrom()<CR>
	nnoremap dl :call utils#DeleteLine()<CR>

	nnoremap <S-CR> O<Esc>
	" Display highlighted numbers as ascii chars. Only works on highlighted text
	vnoremap <Leader>ah :<c-u>s/<count>\x\x/\=nr2char(printf("%d", "0x".submatch(0)))/g<cr><c-l>`<
	vnoremap <Leader>ha :<c-u>s/\%V./\=printf("%x",char2nr(submatch(0)))/g<cr><c-l>`<

	" Search forward/backwards but return
	nnoremap * *N
	nnoremap # #N

	" Insert Mode (Individual) mappings
	inoremap <C-A> <C-O>yiW<End>=<C-R>=<C-R>0<CR>
	inoremap <c-f> <del>
	inoremap <c-l> <Right>

	" Edit local <Leader>e?
	nnoremap <Leader>el :silent e ~/
	" cd into current dir path and into dir above current path
	nnoremap <Leader>e1 :call utils#EditFileInPath(g:location_vim_utils)<CR>
	" Edit Vimruntime
	nnoremap <Leader>ev :call utils#EditFileInPath($VIMRUNTIME, 1)<CR>

	" CD <Leader>c?
	nnoremap <Leader>cd :lcd %:h<CR>
				\:pwd<CR>
	nnoremap <Leader>cu :lcd ..<CR>
				\:pwd<CR>
	" cd into dir. press <Tab> after ci to see folders
	nnoremap <Leader>ci :lcd
	nnoremap <Leader>cc :pwd<CR>
	nnoremap <Leader>c1 :lcd ~/.dotfiles<CR>
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
	else
		nnoremap <silent> <A-l> <C-w>l
		nnoremap <silent> <A-h> <C-w>h
		nnoremap <silent> <A-k> <C-w>k
		nnoremap <silent> <A-j> <C-w>j
	endif

	" Spell Check <Leader>s?
	" search forward
	nnoremap <Leader>sj ]s
	" search backwards
	nnoremap <Leader>sk [s
	" suggestion
	nnoremap <Leader>sc z=
	" toggle spelling
	nnoremap <Leader>st :setlocal spell! spelllang=en_us<CR>
	nnoremap <Leader>sf :call utils#FixPreviousWord()<CR>
	" add to dictionary
	nnoremap <Leader>sa zg
	" mark wrong
	nnoremap <Leader>sw zw
	" repeat last spell correction
	nnoremap <Leader>sr :spellr<CR>

	" Search <Leader>S
	" Tried ack.vim. Discovered that nothing is better than grep with ag.
	" search all type of files
	" Search '&filetype' type of files, and word under the cursor
	nmap gsu :call utils#FileTypeSearch(1, 1)<CR>
	" Search '&filetype' type of files, and prompt for search word
	nmap gsi :call utils#FileTypeSearch(1, 8)<CR>
	" Search all type of files, and word under the cursor
	nmap gsa :call utils#FileTypeSearch(8, 1)<CR>
	" Search all type of files, and prompt for search word
	nmap gss :call utils#FileTypeSearch(8, 8)<CR>
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
	nnoremap <Leader>bS :bufdo
	" move tab to the left
	nnoremap <silent> <A-Left> :execute 'silent! tabmove ' . (tabpagenr()-2)<CR>
	" move tab to the right
	nnoremap <silent> <A-Right> :execute 'silent! tabmove ' . (tabpagenr()+1)<CR>
	nnoremap <Leader>be :enew<CR>

	" Tabs <Leader>a?
	" open new to tab to explorer
	nnoremap <S-Tab> gT
	nnoremap <S-e> :tab split<CR>
	nnoremap <S-x> :tabclose<CR>

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
	"nnoremap <Leader>vL :!for /f "tokens=2*" %i in ('svn status ^| find "?"') do del %i<CR>
	" nnoremap <Leader>vs :!svn status .<CR>
	nnoremap <Leader>vu :!svn update .<CR>
	" Overwritten from plugin.vim
	" nnoremap <Leader>vo :!svn log .<CR>
	" nnoremap <Leader>vi :!svn info<CR>

	" Terminal mappings <Leader>t?
	if has('nvim')
		nnoremap <Leader>tc :term cmus<bar>keepalt file cmus<cr>
	endif

	" Tags mappings <Leader>t?
	nnoremap <silent> gt <C-]>
	nnoremap gr <C-t>

	" Wiki mappings <Leader>w?
	" TODO.RM-Thu Dec 15 2016 16:00: Add support for wiki under SW-Testbed
	nnoremap <Leader>wt :call utils#WikiOpen('TODO.md')<CR>
	nnoremap <Leader>wo :call utils#WikiOpen()<CR>
	nnoremap <Leader>ws :call utils#WikiSearch()<CR>
	nnoremap <Leader>wm :call utils#DropboxOpen('masters/wiki_idx.md')<CR>
	" This mapping is special is to search the cpp-reference offline help with w3m
	nnoremap <Leader>wc :W3m local /home/reinaldo/Downloads/reference/en/index.html<CR>
	nnoremap <Leader>wu :W3m local /home/reinaldo/Downloads/reference/en/index.html<CR>

	" Comments <Leader>o
	nmap - <plug>NERDCommenterToggle
	nmap <Leader>ot <plug>NERDCommenterAltDelims
	vmap - <plug>NERDCommenterToggle
	imap <C-c> <plug>NERDCommenterInsert
	nmap <Leader>oa <plug>NERDCommenterAppend
	vmap <Leader>os <plug>NERDCommenterSexy
	" mapping ol conflicts with mapping o to new line
	nnoremap cl :call utils#CommentLine()<CR>
	nnoremap <Leader>oe :call utils#EndOfIfComment()<CR>
	nnoremap <Leader>ou :call utils#UpdateHeader()<CR>
	nnoremap <Leader>os :grep --cpp TODO.RM<CR>
endfunction

" vim:tw=78:ts=2:sts=2:sw=2:
