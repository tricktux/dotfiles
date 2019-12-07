#!/bin/bash

# File:           python_neovim_virtualenv.sh
# Description:    Create virtual environment used by neovim
# Author:		    Reinaldo Molina
# Email:          rmolin88 at gmail dot com
# Revision:	    0.0.0
# Created:        Fri Jan 25 2019 23:09
# Last Modified:  Fri Jan 25 2019 23:09

recreate_custom_mods_symlink() {
	pydir=`python -m site --user-site`
	libs=~/Documents/python/python-libs/libs
	if [ ! -f $pydir/config.py ]; then
		mkdir -p $pydir
		ln -s $libs/config.py $pydir
		ln -s $libs/parse.py $pydir
		ln -s $libs/logger.py $pydir
	fi
}

modules[0]="vim-vint"
modules[1]="neovim-remote"
modules[2]="psutil"
modules[3]="flake8"
modules[4]="isort"
modules[5]="jedi"
modules[6]="pynvim"
modules[7]="python-language-server"
modules[8]="pip"
modules[9]="frosted"
modules[10]="pep8"
modules[11]="pylint"
modules[12]="requests"
modules[13]="neovim"
modules[14]="stravalib"
modules[14]="jinja2"

modules_2[0]=${modules[7]}
modules_2[1]=${modules[9]}

recreate_custom_mods_symlink

# mkdir -p $venv_loc
# python -m venv $venv_loc/$venv_name
# source $venv_name/bin/activate
pip3 install --upgrade --user ${modules[*]}
pip2 install --upgrade --user ${modules_2[*]}
# deactivate
