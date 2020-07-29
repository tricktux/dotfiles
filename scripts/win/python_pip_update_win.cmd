@echo off

setlocal enabledelayedexpansion

REM  set modules[4]=isort It's already installed by pyling
set modules[0]=vim-vint
set modules[1]=neovim-remote
set modules[2]=psutil
set modules[3]=flake8
set modules[4]=jedi
set modules[5]=pynvim
set modules[6]=python-language-server
set modules[7]=pip
set modules[8]=frosted
set modules[9]=pylint
set modules[10]=neovim
set modules[11]=yapf
set modules[12]=docformatter
set modules[13]=pylama

REM  set modules_2[0]=${modules[7]}
REM  set modules_2[1]=${modules[9]}
REM
for /l %%n in (0,1,13) do ( 
    pip install --upgrade --use-feature=2020-resolver !modules[%%n]!
)
