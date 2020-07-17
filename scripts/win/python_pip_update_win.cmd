@echo off

setlocal enabledelayedexpansion

set modules[0]=vim-vint
set modules[1]=thesaurus
set modules[2]=neovim-remote
set modules[3]=psutil
set modules[4]=flake8
set modules[5]=isort
set modules[6]=jedi
set modules[7]=pynvim
set modules[8]=python-language-server
set modules[9]=pip
set modules[10]=frosted
set modules[11]=pylint
set modules[12]=neovim
set modules[13]=yapf
set modules[14]=docformatter

REM  set modules_2[0]=${modules[7]}
REM  set modules_2[1]=${modules[9]}
REM
for /l %%n in (0,1,13) do ( 
	pip install --upgrade !modules[%%n]!
)
