---
title:	    README.md
subtitle:   Document Description
author:		Reinaldo Molina  <rmolin88@gmail.com>
revision:	0.0.0
date:       Thu Oct 12 2017 13:53
fileext:    md
---

## Installation:
- `choco install msys2 -y`

## Decision over cygwin
- msys2 has a package manager.
- neovim runs on msys2

## Pacman
- Tried the Tadly `pacaur_install.sh` but it doesn't work because it cant find the pacman packages
`expac yajl`. 

## Setup:
- `pacman -Syuu`
- `pacman -S base-devel python python2 vim`
- Packages to install neovim:
- `pacman -S cmake git mingw-w64-x86_64-{gcc,libtool,cmake,make,perl,python2,pkg-config,unibilium} gperf cmake`

## Building neovim
- Genius it doesn't work because it is built of Windows not for MSYS2 shell.
- See the instructions in the website.
- When it says go to the cmd.exe. Do that!!!
	- If you dont do this the build will fail.
	- However, if you happen to have a `sh.exe` in you windows PATH you can temporarily rename that.
	- in the `cmd.exe` shell I also navigated to `~/Documents/packages` and build there.
- When performing this step:
	- `cmake -G "MinGW Makefiles" -DGPERF_PRG="C:\msys64\usr\bin\gperf.exe" ..`
	- Do it like this:
	- `cmake -G "MinGW Makefiles" -DGPERF_PRG="C:\msys64\usr\bin\gperf.exe" -DCMAKE_BUILD_TYPE="Release"..`

