```
- File:					TODO.md
- Description:			Neo(vim) related Todo list
- Author:				Reinaldo Molina <rmolin88@gmail.com>
- Version:				0.0.0
- Last Modified: Sep 05 2017 05:23
- Created: Sep 05 2017 05:23
```

## Wed Sep 13 2017 10:57
- [ ] vim terminal. How to hide it.
- [ ] bash for windows. maybe even a different terminal instead of cmd.exe
- [ ] ditto plugin interfering with snippets.
	- This fix didnt really work. Revisit
- [x] Set work related mappings only when working on a work folder.
	- Improved detection of work pc
- [x] Look into the yankhighlight plugin
- [ ] Look into the vim-sessions plugin
	- Dont like it. Prefer fix my own plugin
- [x] Move sessions into the g:std_data folder
	- Not only sessions. Created folder `vim-data` and moved all vim stuff in there.
- [x] Maybe move plugins into the g:std_data folder
- [x] Move vim-plug folder out of plugins folder
- [ ] Denite not working when being used for sessions
- [ ] Follow all cpp tips [here](http://vim.wikia.com/wiki/Category:C%2B%2B)
- [ ] Search and fix all TODOs
- [ ] Revisit the google plugin. To google stuff straight from anywhere.
- [ ] vim terminal figure out how to scroll.
- [ ] fuzzy search variables. Probably denite can do this.

## Tue Sep 05 2017 05:21 
Improvements:
- [ ] Create a after/syntax/gitcommit.vim to redline ahead and greenline
  up-to-date
- [ ] Delete duplicate music.
- [ ] Construct unified music library
- [x] Markdown math formulas

## Tue Jul 11 2017 13:27 
- [ ] Put a terminal with a vim-instance in an i3-scratchpad, combine it with autosave-when-idle and you got the
  perfect note keeping workflow

## Mon Jul 10 2017 12:06 
- [x] Create Index for Wikis
	- Using denite for this purpose
- [x] Fix markdwon enter issue where its no breaking lines
- [x] Modularize `init.vim`. Example break it down into simpler files
- [x] Best `colorscheme` for cpp.
	- Didnt yield anything.
- [x] Why `ctrlp` having such a lame buffer thing

## Tue May 02 2017 10:14 
-  [X] Get familiar with `vifm`. Potential for substitute of `ranger`
	- `vifm` is a piece of shit. At least for windows.
	- Main thing is that it cannot follow `*.lnk` files
-  [X] Add `neovim` to `chocolatey`
- Useless List not worthy
-  [ ] Get `msys2` on cmder
	- Abandoned
-  [ ] Get `shell` to open `msys2`???
-  [ ] Get `pacaur` to work on `msys2`

## Fri Apr 21 2017 09:25 
-  [X] Profile command didnt work
-  [X] Look into using Neosolarized
	- Mon Jul 10 2017 12:08 
	- Didnt like it
-  [X] Cool cursor in nvim-qt on windows

## Wed Apr 19 2017 09:17 
-  [ ] On the svn.nvim plugin before switching to a branch make sure that the svn status command returns empty. Otherwise
  the switch is not going to go well.

## Mon Apr 10 2017 16:42 
- [  ] Fix svn.nvim plugin to obtain url from svn info instead of all of that twisted logic that you have.
- [  ] Finish the svn.nvim plugin
- 
## Tue Apr 04 2017 08:50 
-  [X] Make a new `autoload\autocomplete.vim` file where you handle all the autocompletion logic
-  [X] Look into neovim completion manager
-  [X] cscope command its really not working
	- I am sure that it has to do with the rg command creating some weird paths. Take a look at `cscope.files`

## Mon Apr 03 2017 11:15
-  [X] Fix nvim-install.ps1 to include copying of the spells from vim to nvim
-  [X] Fix the snippet `header`
-  [X] Create profile command.
```vim
profile start profile.log
profile func *
profile func *
profile file *
" At this point do slow actions
profile pause
noautocmd qall!
```
-  [X] Improve PlugInstall to do `so % | call plugin#Config() | PlugInstall`
-  [X] Profile why typing is kinda slow and slugish
- Created `~/.cache/profile_typing.log` for this purpose
- [X] Fix snippets for cpp for if and all so that they dont have the bad brackets

## Thu Mar 16 2017 09:20 
-  [X] Remap `<Shift+s>`
-  [ ] Create svn.vim as remote pyhon plugin
- Make it not dependant on the user providing the `repo_url` 
## Mon Mar 13 2017 14:54 
-  [X] Think of a way to create your own update of tags and cscope
## Fri Mar 10 2017 09:22
-  [X] Clang complete
-  [X] vim-gutentags
-  [X] Real piece of shit
## Fri Mar 03 2017 10:03
-  [X] Implement function for when cd into rooter check if cscope is there then load it.
-  [X] Give easytags another try
- Not working in win32 neovim
## Thu Mar 02 2017 10:41 
-  [X] Fix ctags for neovim `tagbar` doesnt like new ctags. Not happening really haard
- This is because neovim doesnt support yet system() in windows
- Issue I was creating on the repo:
- Error message after running Tagbar:
```
Error detected while processing function tagbar#ToggleWindow[1]..<SNR>97_ToggleWindow[9]..<SNR>97_OpenWindow[25]..<SNR>97_Init[4]..<SNR>97_CheckForExCtags[64]..<SNR>97_CtagsErrMsg:
line   10:
Tagbar: Ctags doesn't seem to be Exuberant Ctags!
GNU ctags will NOT WORK. Please download Exuberant Ctags from ctags.sourceforge.net and install it in a directory in your $PATH or set g:tagbar_ctags_bin.
Executed command: "ctags --version"
Command output:
'\"ctags --version\"' is not recognized as an internal or external command,
	operable program or batch file.
	```
	- This is probably a neovim bug as well but please keep it mind for future support. Neovim full support for windows is very near.
	- BTW
	```vim
	echo system('"ctags --version"')
	```
	```
	Exuberant Ctags 5.8, Copyright (C) 1996-2009 Darren Hiebert
	Compiled: Jul  9 2009, 17:05:35
	Addresses: <dhiebert@users.sourceforge.net>, http://ctags.sourceforge.net
	Optional compiled features: +win32, +regex, +internal-sort
	```
	-  [X] Fix all cd functions to substitute with `getcwd()`
	-  [X] Fix tags to use `list` that get searched for and if not there created
	-  [X] Merge OneWings with CC
