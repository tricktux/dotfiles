#/////////////////////////////////MISC NOTES/////////////////////////////////////////////
useful command to convert all , into new lines
	:%s,/\r/g  
		 to umap something simply type it in the command :unmap ii for example
 :w xxx - save as xxx keep working on original
 :sav xxx -save as xxx switch to new file
 H - jump cursor to begging of screen
 M - jump cursor to middle of screen
 L - jump cursor to end of screen
 vib - visual mode select all inside ()
 cib - even better
 ci" - inner quotes
 ci< - inner <>
 :nmap shows all your normal mode mappings
 :vmap shows all your visual mode mappings
 :imap shows all your insert mode mappings
 :map shows all mappings
 :mapclear Clears all mappings then do :so % 
 <C-q> in windows Visual Block mode
 <C-v> in linux Visual Block mode
 A insert at end of line
 To read output of a command use:
	   :read !<command>
 Create vim log run vim with command:
	vim -V9myVimLog
 When using <plug> do a :nmap and make sure your option is listed, usually at the end
 Search for INdENTGUIDES to join braces with \
 use :verbose map <c-i> to understand mappings
 use z. to make current line center of screen
 use c-w+<H,J,K,L> to swap windows around
 Surround stuff:
	 change(c) surrournd(s): cs<from><to>, i.e: cs("
	 change(c) surrournd(s) to(t): cst<to>
	 insert(y) surround: ys<text object>, i.e: ysiw
	 using opening surrounds, i.e:{,( inserts spaces, closing deletes them
	 wrap entire line with yss<to>, i.e: yssb or yss( which are the same
	 delete(d) surrournd(s): ds<surround>, i.e: ds{
	 Select visual mode line and press:
		S<p class="important">
 Another important motion is f
	 df. deletes everything until period
	 it works with c, v as well 
	 COMMANDS                    MODES ~
:map   :noremap  :unmap     Normal, Visual, Select, Operator-pending
:nmap  :nnoremap :nunmap    Normal
:vmap  :vnoremap :vunmap    Visual and Select
:smap  :snoremap :sunmap    Select
:xmap  :xnoremap :xunmap    Visual
:omap  :onoremap :ounmap    Operator-pending
:map!  :noremap! :unmap!    Insert and Command-line
:imap  :inoremap :iunmap    Insert
:lmap  :lnoremap :lunmap    Insert, Command-line, Lang-Arg
:cmap  :cnoremap :cunmap    Command-line

 Search and replace examples:
	 - Search current highlited word in all cpp and h files recursively
		 :vimgrep // **/*.cpp **/*.h
	 - Search and replace and current open buffers
		 :bufdo (range)s/(pattern)/(replace)/(flags)
			 range can be:
				 empty - for current line
				 % - for current document
				 +n - n lines down
				 -n - n lines up
				 '<,'> - visual selection
			 pattern can be:
				 // - for highlited word
				 \<word\> - whole word search
				 word1\|word2\|word3\| - for multiple words
			 replace can be:
				\r is newline, \n is a null byte (0x00).
				\& is ampersand (& is the text that matches the search pattern).
				\0 inserts the text matched by the entire pattern
				\1 inserts the text of the first backreference. \2 inserts the second backreference, and so on.
				\=@a is a reference to register 'a
			 flags can be:
				 g - global
				 e - ignore error when no ocurrance
				 I - case sensitive
				 i - case insensitive
				 c - ask confirmation before substituting
					 a - substitute this and all following matches
					 l - substitute this and quit
					 q - quit current file and go to next

	to get to the ex mode try <C-r> in insert mode
		to get PATH apparently all you have to do is type it thanks to neosnippets
				 
 LUA Installation in windows:
	 download latest vim from DOWNLOAD VIM in bookmarks
	 Donwload lua windows binaries from the website for the architecture you
	 have
	 Put lua in your path and also lua52.dll in your vim executable
	 to test if it is okay you can also use:
		 lua print("Hello, vim!")
		 this will tell you the error you are getting
		 last time wih only the lua53.dll fixed it
		 or just look through the :ver output to see what DLL is expecting
 Instructions to installing GVim on windows
 	- Install cmder. Google and download from website
 	- Install chocolatey. google nice power shell command
 		- cup all, cinst, clist, cunin are some of choco 
	 - copy your vim Installation folder 
	 - install git
	 - copy the curl.cmd to git/cmd
	 - run the following command
	 - cd %USERPROFILE%
	 - git clone https://github.com/gmark/Vundle.vim.git
	 %USERPROFILE%/vimfiles/bundle/Vundle.vim
	 - set up your .gitconfig @ ~/ or project specific
		[user]
			name = Reinaldo Molina
			email = rmolin88@gmail.com
		[core]
			editor = gvim
		[remote "origin"]
			url = http://github.com/rmolin88/vimrc.git
			fetch = +refs/heads/*:refs/remotes/origin/*
		[credential]
			helper = wincred # for windows
			#helper = cache --timeout 30000 # for unix 2 below
			#helper = store --file /mnt/thumbdrive/.git-credentials
		[diff]  
			tool = gvim
		[difftool "gvim"]  
			cmd = "C:/Users/USER/Downloads/vim/complete-x86/gvim.exe -d \"$LOCAL\" \"$REMOTE\""
		[merge]  
			tool = gvim
		[mergetool "gvim"]  
			cmd = "C:/Users/USER/Downloads/vim/complete-x86/gvim.exe -d \"$BASE\" \"$LOCAL\" \"$REMOTE\" \"$MERGED\""
			prompt = false
		*make sure you have internet
		git init
		git add remote origin
		this downloads your _vimrc
	- svn config file
		~/.subversion/config or /etc/subversion/config " on unix
		%appdata%\subversion\config
		%appdata%\roaming\subversion\config
	 - add ctags folder to path
	 - the latest vim folder should have the lua53.dll already inside
	 - Cscope:
		 - To create database:
			 - Win: 
			 add cscope.exe and sort.exe to PATH
			 do this command on root folder of files
				 dir /b /s *.cpp *.h > cscope.files
				 cscope -b
			 This will create the cscope.out
			 then in vim cs add <PATH to cscope.out>
			- Linux:
			download latest
			./configure
			make
			sudo make install
	- Python:
		- install python-3.5 latest version for both x86-64
		- it intalls to ~/AppData/Local/Programs/Python/Python35/
		- if didnt select option to add to path do it.
		- copy DLL from previous path.
		- this works on 64 bit systems
		////////////////
		- 32 bit: Download and install python 2.7.9 for 32-bit
		- copy DLL from Windosws/System32/python27.dll
 Installin vim in unix:
	- Download vim_source_install.sh from drive
	- run. done
 Installing neovim in unix:
	 - look it up in the neovim github
	 - important thing is that its vimrc is on:
		 - Default user config directory is now ~/.config/nvim/
		 - Default "vimrc" location is now ~/.config/nvim/init.vim
		 - you have to create the nvim folder and the init.vim
		 - install python and xclip
 --------------------------


