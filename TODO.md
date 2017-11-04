---
title:					TODO.md
subtitle:			Neo(vim) related Todo list
author:				Reinaldo Molina <rmolin88@gmail.com>
revision:				0.0.0
date: Sun Oct 29 2017 17:58 
fileext: md
---

\maketitle
\tableofcontents
\pagebreak

## Sat Nov 04 2017 02:25 
- [ ] git: delete ranger plugin files from repo.
- [ ] ranger: look into the folder diff plugin.

## Thu Nov 02 2017 06:25 
- [ ] vim: create a `install/download` software plugin. the idea is to download files or
gits and optionally run commands afterwards.

## Tue Oct 31 2017 08:42
- [ ] mutt: look into the `lbdb` address book software.
- [ ] vim: map `[S` to `autofix` previous error. Same thing with `]S`

## Mon Oct 30 2017 08:38
- [ ] pomodoro: replace the notification `system` call with a `job_start` or `terminal` type of thing
- [ ] arch-predator: get rid or fix `vmware`

## Sun Oct 29 2017 17:53 
- [ ] fzf: replace current `.fzf` with an installed fzf.
- [ ] vim: map `<Leader>tc` to a toggle `concellevel`.
- [ ] vim: set `commentstring` for plantuml so that snippet `author` works properly.

## Sat Oct 28 2017 13:48 
- [ ] termite: empty black space at the bottom of the screen.
- [ ] vim: fix `LanguageToolCheck`. set the path to the executable.
- [ ] vim: neomake add `pandoc` maker. see `vim-pandoc`
- [x] pandoc: move template and sample makefile to dotfiles.
- [ ] vim: modify `ftplugin/markdown.vim` to use `Neomake!` for make.
- [ ] vim: substitute function `bufdetect` with `ftdetect/*.vim`. see `plantuml-syntax`
- [ ] vim: mapping `<Leader>ou` update not only `Last Modified` but also `date`
plugin for an example.
- [ ] vim: disable `neomake` automake functionality on a per buffer basis.
- [ ] cmus: keymappings are gone!
- [ ] arch: try to see if it you can make calls from the headphones.
	- keyword: bluetooth, microphone, headphones, calls, audio.
	- It works.
	- You just have to go to `pavucontrols`.
	- Go to the **Configuration** Tab.
	- Select E7 and set it to `Headset Head Unit`.
	- Audio quality is terrible but mircrophone works.

## Fri Oct 27 2017 08:20
- [x] vim: port the `neosnippet` author to all files. Make it call netdcommenter for the comments insertion.
- [ ] vim: `neomake` enable makers on `ftplugin/*.vim` files. see `b:neomake_<ft>_enabled_makers`
- [ ] vim: `neomake` research `NeomakeProject`.
- [ ] vim: `neomake` for `latex`.
- [x] vim: `neomake` for `vint`.
- [ ] vim: distribute functions in `utils.vim` to make them like a plugin. i.e: moving
all lightline related functions to `lightline.vim` file.
	- Also do this with all the functions defined in `ftplugin/*.vim`

## Thu Oct 26 2017 08:33
- [ ] vim: the lsp plugin now supports vim8
	- Fri Oct 27 2017 08:22: Doesnt make much sense. vim is only used in windows where the NCM plugin is not used. 

## Wed Oct 25 2017 10:57 
- [ ] rg: look at the readme to get bash completion.

## Tue Oct 24 2017 10:47
- [ ] vim: nnoremap gk K. Then set keywordprg accordingly in `ftplugin/*.vim`
- [ ] vim: nnoremap gK <googling stuff>. Right now `gG`
- [ ] vim: search through your plugins and map <Leader>t<x> to all the plugin that toggle
something, like focus mode, systanstic, signify, most of them are toggable.
- [ ] vim: look into software caps lock plugin
- [ ] bash: better raw folder navigation
	- see fzf suggestions below
- [x] zathura: there doesnt seem to be a TOC but try to find it.
	- its done with `tab`. See man zathura(1)
- [ ] fzf: study these suggestions [here](https://dmitryfrank.com/articles/shell_shortcuts)

## Mon Oct 23 2017 10:04 
- [x] Remove gpg files from github. Along with their history
- [ ] vim: man files remove `K` mapping. Is really annoying plus regular go to tag works
- [ ] i3: mapping to copy email with a hotkey

## Sun Oct 22 2017 09:09 
- [ ] pomodoro: doc new feature
- [ ] pomodoro: fix readme.md
- [ ] vim: fix `wikisearch` to use normal grep instead of denite
- [ ] arch-guajiro: remove mounting `copter-server`

## Fri Oct 20 2017 09:05 
- [x] vim: paste yanked text. not deleted text

## Thu Oct 19 2017 10:37
- [x] vim: study vim-unimpaired and copy from it the best
- [x] vim: also study and rethink all of your vim mappings and methods

## Wed Oct 18 2017 12:53 
- [x] vim: had this super amazing realization. ';' its not used at all as a mapping. the idea is
to make all the `ftplugin/*.vim` mappings use `localleader` instead of `leader` and map
`localleader=;`. This would increase mappings efficiency by 1/3.

## Mon Oct 16 2017 16:31 

### Christmas 2017 projects.
- [ ] 1.arch: backup entire `seafile` library
- [ ] 2.arch: look into encryption for the making the following step `encrypted`
- [ ] 3.arch: install arch in `copter-server`.
- [ ] 4.arch: establish an `openvpn` in there.
- [ ] 5.arch: reestablish `seafile` however make it accessible from the internet.
- [ ] arch: figure out a password storage solution. `pass` its a possible candidate

### Tue Oct 24 2017 10:50
- [ ] seafile: I have also realize that I am misusing it. Files that are rarely used. Should not
be part of the library. Like picture old files, tutorials, They should be left out. Things that
change on a regular basis like ImpDocs, wikis, masters, those files are really the ones that
should be part of the library

## Thu Oct 12 2017 14:39 
- [ ] msys2: copy the default `.bashr...` to the dotfiles and modify them

## Wed Oct 11 2017 08:44 
- [x] vim: map `gl` to `Ttoggle`
- [ ] vim: make the previous mapping work also in windows.
- [ ] !vim: fix `lightline` stuff to make it more smart.
- [x] vim: `denite` mapping to scroll down faster.
- [ ] pomodoro: make the `statusline` message configurable.
- [ ] polybar: substitute the `launch.py`
- [ ] vim: `markdown` fix the make command to make it call the makefile.
- [ ] vim: `markdown` change the `textwidth`
- [x] feh: customize or learn its mappings to make it more useful.
- [ ] vim: `clangd` not being installed in linux.
- [ ] vim: in the `{unix,win32}.vim` files create `g:pc_name` variables.
- [ ] mutt: substitute mapping `d` delete message to scrolling up and down.
- [ ] mutt: figure out a mapping to delete and opened message.
- [ ] mutt: look into the issue of nvim not highlighting messages when openning from mutt.
- [ ] vim: download Spanish lenguage `spell` file.
- [ ] vim: `powerline` fonts for windows.
- [ ] vim: examine `vim-enhanced-diff`. its not being used properly
- [x] cygwin: install `ranger`
- [x] vim: change all the `confirm` function calls &Yes to &Jes
- [ ] vim: configure windows `set shell=\"C:\tools\cygwin\bin\bash.exe\"`
- [ ] cygwin: please for the love of god get a prettier `prompt`. Maybe `liquidprompt`
- [x] vim: `denite` find hidden files

## Thu Sep 21 2017 21:05
- [x] zathura mappings to scroll with `e` and `d`
- [x] `vim-pomodoro` install

## Fri Sep 15 2017 13:11 
- [ ] Standard for coding todo lists.
- [ ] Fix the rest of the <Alt> mappings in terminal vim.
- [x] Take a look at [this](https://github.com/Wandmalfarbe/pandoc-latex-template) repo. Looks
	very promessing so that I can move text dev to pandoc.

## Thu Sep 14 2017 05:14 
- [x] Get rid of the other colorscheme. At night time use only PaperCOlor but dark
- [x] Fix pressing `o` in markdown indenting. Its really annoying.
- [x] Figure out how to create beautiful latex docs. `choco install miktex -y`.
	- Sun Oct 15 2017 17:33: pandoc 
- [ ] Move dropbox pictures to google photos.
- [ ] android tui: move files into a git repo.
- [ ] android tui: create more shortcuts for calling and for rebooting devices.
	- Mon Oct 30 2017 09:41: Most efficient way to do it is to connect a keyboard to the tablet with termux and go from there. 
- [x] markdown focus mode not really working.
- [x] **Return surbook**.
	- Decided to give it a try.
- [ ] **update choco-neovim.**
- [ ] look into a vim-gdb plugin.
	- Mon Oct 30 2017 09:39: not used that often. 
- [-] make the clang-format.py work in visual mode. see c.vim
	- Mon Oct 30 2017 09:39: not used that often. 

## Wed Sep 13 2017 10:57
- [x] vim terminal. How to hide it.
	- you can press <c-\><c-n> to enter normal mode. However right now is not working. You can get
		out but not back in.
	- Mon Oct 30 2017 09:38: Still work in progress but it works now. 
- [x] vim terminal figure out how to scroll.
	- go into normal mode and scroll normally.
- [x] bash for windows. maybe even a different terminal instead of cmd.exe
	- Sun Oct 15 2017 17:31: Installed `cygwin` 
- [x] ditto plugin interfering with snippets.
	- This fix didnt really work. Revisit
- [x] Set work related mappings only when working on a work folder.
	- Improved detection of work pc
- [x] Look into the yankhighlight plugin
- [x] Look into the vim-sessions plugin
	- Dont like it. Prefer fix my own plugin
- [x] Move sessions into the g:std_data folder
	- Not only sessions. Created folder `vim-data` and moved all vim stuff in there.
- [x] Maybe move plugins into the g:std_data folder
- [x] Move vim-plug folder out of plugins folder
- [x] **Denite not working when being used for sessions**
	- [x] Also respond to the denite bug report you did.
	- Fri Sep 15 2017 13:53: Found out that if you `cd` into a folder and run the `file_rec`
		denite command it does work. 
- [ ] Follow all cpp tips [here](http://vim.wikia.com/wiki/Category:C%2B%2B)
- [ ] Search and fix all TODOs
- [x] Revisit the google plugin. To google stuff straight from anywhere.
- [x] fuzzy search variables. Probably denite can do this.
	- Sun Oct 15 2017 17:29: Doesn't look possible with `denite` 
	- Mon Oct 30 2017 09:34: deprecating this one.
- [x] Fix the `OnlineThesaurusCurrentWord` not working under windows. Find an alternative or
	something
	- Mon Oct 30 2017 09:35: Would have to look in the code. To see how the call is made. Not worth it right now 
- [x] the `w3m` plugin for windows. In order to see the master's highlights right in vim.
	- You'll have to compile yourself in windows. Maybe doable can try it with clang. See what happens.
	- Mon Oct 30 2017 09:35: Too much work. 

## Tue Sep 05 2017 05:21 
Improvements:
- [x] Create a after/syntax/gitcommit.vim to redline ahead and greenline
  up-to-date
	- Mon Oct 30 2017 09:34: deprecating this one.
- [x] Delete duplicate music.
	- Mon Oct 30 2017 09:34: deprecating this one.
- [x] Construct unified music library
- [x] Markdown math formulas

## Tue Jul 11 2017 13:27 
- [x] Put a terminal with a vim-instance in an i3-scratchpad, combine it with autosave-when-idle and you got the
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
