@echo off

setlocal enableextensions enabledelayedexpansion

set dot=%userprofile%\AppData\Roaming\dotfiles

:: Update nvim plugins. Spin off a window
start cmd /k "nvim +PackerUPDATE"

:: Choco update
start cmd /k "cup all -y"

:: Save choco list
choco list --local-only > %dot%\pkg\choco-windows\choco_pkg.txt

:: Backup to the network
:: set rob=%dot%\scripts\win\robocopy_python_generator.py
:: start cmd /k python %rob%

:: Update python pip
set req=%dot%\scripts\win\nvimvenv.txt
start cmd /k python -m pip install --user --upgrade -r %req%

:: Update rust
start cmd /k rustup update

:: Disk cleanup
:: The very first time run this one below
:: It will prompt, and save your selections to be run with the SAGERUN
:: cleanmgr.exe /SAGESET:8
cleanmgr.exe /SAGERUN:8

:: Setting up some envvars
setx NEOVIDE_FRAMELESS 1
setx NEOVIDE_MULTIGRID 1

wsl --update

vale sync
