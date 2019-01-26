#!/bin/bash

# File:           python_neovim_virtualenv.sh
# Description:    Create virtual environment used by neovim
# Author:		    Reinaldo Molina
# Email:          rmolin88 at gmail dot com
# Revision:	    0.0.0
# Created:        Fri Jan 25 2019 23:09
# Last Modified:  Fri Jan 25 2019 23:09

venv_loc="~/.local/share/python"
venv_name="neovim"

modules[0]="vim-vint"
modules[1]="thesaurus"
modules[2]="neovim-remote"
modules[3]="psutil"
modules[4]="flake8"
modules[5]="isort"
modules[6]="jedi"
modules[7]="pynvim"
modules[8]="python-language-server"

# mkdir -p $venv_loc
# python -m venv $venv_loc/$venv_name
# source $venv_name/bin/activate
pip install --user ${modules[*]}
pip2 install --user ${modules[7]}
# deactivate
