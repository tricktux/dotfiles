@echo off

setlocal enabledelayedexpansion

REM  set modules[4]=isort It's already installed by pyling
set modules[0]=psutil
set modules[1]=flake8
set modules[2]=jedi
set modules[3]=pynvim
set modules[4]=python-language-server
set modules[5]=pip
set modules[6]=frosted
set modules[7]=pylint
set modules[8]=neovim
set modules[9]=yapf
set modules[10]=docformatter
set modules[11]=pylama
set modules[12]=ptpython

for /l %%n in (0,1,12) do ( 
    pip install --upgrade !modules[%%n]!
)
