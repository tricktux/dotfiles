@echo off

setlocal enabledelayedexpansion

python.exe -m pip install --user --upgrade -r nvimvenv.txt
exit %errorlevel%

REM  set modules[4]=isort It's already installed by pylint
REM local pkgs=requests psutil ^
REM    flake8 isort jedi "python-language-server[all]" frosted ^
REM    pep8 pylint pynvim

set venv_loc=%APPDATA%\..\Local\nvim-data
set venv_name=pyvenv

mkdir %venv_loc%
python -m venv %venv_loc%\%venv_name% --clear
cmd /k call "%venv_loc%\%venv_name%\Scripts\activate.bat"
REM pip install --upgrade -r nvimvenv.txt
REM deactivate

