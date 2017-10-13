---
title:	    README.md
subtitle:   Document Description
author:		Reinaldo Molina  <rmolin88@gmail.com>
revision:	0.0.0
date:       Thu Oct 12 2017 13:53
fileext:    md
---

## Reason why abandoning the project.

### TL;DR
- Ranger works only inside of `mintty` terminal. Not from `gvim` terminal.
- Vim doesnt work.
- Neovim doesnt work.

### Explanation
- The vision was to run `vim/neovim/ranger` inside of the `msys2/cygwin` console.
- This proved to be really hard.
1. neovim doesnt run inside of any of the two.
2. vim runs inside of fine inside `mintty, msys2` however it has an older build.
3. moreover building a newer version turned out to be really hard.
- Then I thought well maybe I can just run `ranger` from the `gvim terminal`
1. Wrong again. The terminal you can run from `gvim` is bash which doesnt work well at all with
   colors. 
2. I tried `export TERM=xterm-256color` but still doesnt work.
3. Too many factors such as `gvim terminal` involved.
4. No, you can't use `mintty` that is a graphical terminal.
- Vim doesnt work very well either.
1. A side from being an old build
2. Python3 doesnt work because it was compiled using `python-3.4`. Older version. Not easy to
   install with `pacman`. Current version 3.6
3. And forget about building your own vim.
- Ranger.
1. Even if ranger were to work. It doesnt follow `*.lnk` windows shortcuts. Therefore, limiting
   infinetely its posibilities.

## Installation:
- `choco install msys2 -y`

## Decision over cygwin
- msys2 has a package manager.
- `mintty` setup by default
- neovim runs on msys2
	- This is not true. See `Building neovim`

## Pacman
- Tried the Tadly `pacaur_install.sh` but it doesn't work because it cant find the pacman packages
`expac yajl`. 

## Setup:
- `pacman -Syuu`
- `pacman -S base-devel python vim`
- Packages to install neovim:
- `pacman -S cmake git mingw-w64-x86_64-{gcc,libtool,cmake,make,perl,python2,python3,pkg-config,unibilium} gperf cmake`

## Building vim
- Too difficult. Didnt work.
- Even if you were to get the location of python write the build fails after that.

## Building neovim
- TL;DR Genius it doesn't work because it is built for Windows not for MSYS2 shell.
- See the instructions in the website.
- When it says go to the cmd.exe. Do that!!!
	- If you dont do this the build will fail.
	- However, if you happen to have a `sh.exe` in you windows PATH you can temporarily rename that.
	- in the `cmd.exe` shell I also navigated to `~/Documents/packages` and build there.
- When performing this step:
	- `cmake -G "MinGW Makefiles" -DGPERF_PRG="C:\msys64\usr\bin\gperf.exe" ..`
	- Do it like this:
	- `cmake -G "MinGW Makefiles" -DGPERF_PRG="C:\msys64\usr\bin\gperf.exe" -DCMAKE_BUILD_TYPE="Release"..`
