#!/bin/bash

# File:           python_neovim_virtualenv.sh
# Description:    Create virtual environment used by neovim
# Author:		    Reinaldo Molina
# Email:          rmolin88 at gmail dot com
# Revision:	    0.0.0
# Created:        Fri Jan 25 2019 23:09
# Last Modified:  Fri Jan 25 2019 23:09

venv_loc="$XDG_DATA_HOME/nvim/"
req_loc="$XDG_CONFIG_HOME/nvim/requirements.txt"
venv_name="pyvenv"

mkdir -p "$venv_loc"
python -m venv "$venv_loc/$venv_name"
source "$venv_loc/$venv_name/bin/activate"
pip3 install --upgrade -r $req_loc
deactivate
