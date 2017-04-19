### Wed Apr 19 2017 09:17 
-  [ ] On the svn.nvim plugin before switching to a branch make sure that the svn status command returns empty. Otherwise
  the switch is not going to go well.

### Mon Apr 10 2017 16:42 
- [  ] Fix svn.nvim plugin to obtain url from svn info instead of all of that twisted logic that you have.
- [  ] Finish the svn.nvim plugin
- 
### Tue Apr 04 2017 08:50 
-  [X] Make a new `autoload\autocomplete.vim` file where you handle all the autocompletion logic
-  [X] Look into neovim completion manager
-  [ ] cscope command its really not working
	- I am sure that it has to do with the rg command creating some weird paths. Take a look at `cscope.files`

### Mon Apr 03 2017 11:15
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

### Thu Mar 16 2017 09:20 
-  [X] Remap `<Shift+s>`
-  [ ] Create svn.vim as remote pyhon plugin
- Make it not dependant on the user providing the `repo_url` 
### Mon Mar 13 2017 14:54 
-  [X] Think of a way to create your own update of tags and cscope
### Fri Mar 10 2017 09:22
-  [X] Clang complete
-  [X] vim-gutentags
-  [X] Real piece of shit
### Fri Mar 03 2017 10:03
-  [X] Implement function for when cd into rooter check if cscope is there then load it.
-  [X] Give easytags another try
- Not working in win32 neovim
### Thu Mar 02 2017 10:41 
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
