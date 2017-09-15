---
title:					TODO.md
subtitle:			Neo(vim) related Todo list
author:				Reinaldo Molina <rmolin88@gmail.com>
revision:				0.0.0
date: Sep 05 2017 05:23
fileext: md
...

\maketitle
\tableofcontents
\pagebreak

## Fri Sep 15 2017 13:11 
- [ ] Standard for coding todo lists.
- [ ] Fix the rest of the <Alt> mappings in terminal vim.
- [ ] Take a look at [this](https://github.com/Wandmalfarbe/pandoc-latex-template) repo. Looks
	very promessing so that I can move text dev to pandoc.

## Thu Sep 14 2017 05:14 
- [ ] Get rid of the other colorscheme. At night time use only PaperCOlor but dark
- [ ] Fix pressing `o` in markdown indenting. Its really annoying.
- [ ] Figure out how to create beautiful latex docs. `choco install miktex -y`.
- [ ] Move dropbox pictures to google photos.
- [ ] android tui move files into a git repo.
- [ ] android tui create more shortcuts for calling and for rebooting devices.
- [ ] markdown focus mode not really working.
- [ ] **Return surbook**.
	- Decided to give it a try.
- [ ] **update choco-neovim.**
- [ ] look into a vim-gdb plugin.
- [ ] make the clang-format.py work in visual mode. see c.vim

## Wed Sep 13 2017 10:57
- [-] vim terminal. How to hide it.
	- you can press <c-\><c-n> to enter normal mode. However right now is not working. You can get
		out but not back in.
- [x] vim terminal figure out how to scroll.
	- go into normal mode and scroll normally.
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
- [ ] **Denite not working when being used for sessions**
	- [ ] Also respond to the denite bug report you did.
	- Fri Sep 15 2017 13:53: Found out that if you `cd` into a folder and run the `file_rec`
		denite command it does work. 
- [ ] Follow all cpp tips [here](http://vim.wikia.com/wiki/Category:C%2B%2B)
- [ ] Search and fix all TODOs
- [ ] Revisit the google plugin. To google stuff straight from anywhere.
- [ ] fuzzy search variables. Probably denite can do this.
- [ ] Fix the `OnlineThesaurusCurrentWord` not working under windows. Find an alternative or
	something
- [ ] the `w3m` plugin for windows. In order to see the master's highlights right in vim.
	- You'll have to compile yourself in windows. Maybe doable can try it with clang. See what happens.

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
-  [x] Get familiar with `vifm`. Potential for substitute of `ranger`
	- `vifm` is a piece of shit. At least for windows.
	- Main thing is that it cannot follow `*.lnk` files
-  [x] Add `neovim` to `chocolatey`
- Useless List not worthy
-  [ ] Get `msys2` on cmder
	- Abandoned
-  [ ] Get `shell` to open `msys2`???
-  [ ] Get `pacaur` to work on `msys2`

## Fri Apr 21 2017 09:25 
-  [x] Profile command didnt work
-  [x] Look into using Neosolarized
	- Mon Jul 10 2017 12:08 
	- Didnt like it
-  [x] Cool cursor in nvim-qt on windows

## Wed Apr 19 2017 09:17 
-  [ ] On the svn.nvim plugin before switching to a branch make sure that the svn status command returns empty. Otherwise
  the switch is not going to go well.

## Mon Apr 10 2017 16:42 
- [  ] Fix svn.nvim plugin to obtain url from svn info instead of all of that twisted logic that you have.
- [  ] Finish the svn.nvim plugin
- 
## Tue Apr 04 2017 08:50 
-  [x] Make a new `autoload\autocomplete.vim` file where you handle all the autocompletion logic
-  [x] Look into neovim completion manager
-  [x] cscope command its really not working
	- I am sure that it has to do with the rg command creating some weird paths. Take a look at `cscope.files`

## Mon Apr 03 2017 11:15
-  [x] Fix nvim-install.ps1 to include copying of the spells from vim to nvim
-  [x] Fix the snippet `header`
-  [x] Create profile command.
```vim
profile start profile.log
profile func *
profile func *
profile file *
" At this point do slow actions
profile pause
noautocmd qall!
```
-  [x] Improve PlugInstall to do `so % | call plugin#Config() | PlugInstall`
-  [x] Profile why typing is kinda slow and slugish
- Created `~/.cache/profile_typing.log` for this purpose
- [x] Fix snippets for cpp for if and all so that they dont have the bad brackets

## Thu Mar 16 2017 09:20 
-  [x] Remap `<Shift+s>`
-  [ ] Create svn.vim as remote pyhon plugin
- Make it not dependant on the user providing the `repo_url` 
## Mon Mar 13 2017 14:54 
-  [x] Think of a way to create your own update of tags and cscope
## Fri Mar 10 2017 09:22
-  [x] Clang complete
-  [x] vim-gutentags
-  [x] Real piece of shit
## Fri Mar 03 2017 10:03
-  [x] Implement function for when cd into rooter check if cscope is there then load it.
-  [x] Give easytags another try
- Not working in win32 neovim
## Thu Mar 02 2017 10:41 
-  [x] Fix ctags for neovim `tagbar` doesnt like new ctags. Not happening really haard
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
-  [x] Fix all cd functions to substitute with `getcwd()`
-  [x] Fix tags to use `list` that get searched for and if not there created
-  [x] Merge OneWings with CC
