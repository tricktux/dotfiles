#/bin/sh

# File:					arch-maintance.sh
# Description:			File to give arch maintance
# Author:				Reinaldo Molina <rmolin88@gmail.com>
# Version:				0.0.0
# Last Modified: Oct 15 2017 10:03
# Created: Oct 15 2017 10:03

machine=`hostname`

echo "Optimizing pacman"
# sudo pacman -Sc --noconfirm
sudo pacman-optimize
# Tue Sep 26 2017 18:40 Update Mirror list. Depends on `reflector`
if hash reflector 2>/dev/null; then
	sudo reflector --protocol https --latest 30 --number 5 --sort rate --save /etc/pacman.d/mirrorlist -c 'United States' --verbose
else
	echo "Please install reflector"
	exit 8
fi

echo "Optimizing system memory now in order to do all sudo commands at once"
sudo bleachbit --clean system.memory

echo "Removing unused orphan packages"
sudo pacman -Rns $(pacman -Qtdq) --noconfirm

echo "Updating system"
trizen -Syyu --devel --noconfirm
sudo pacman -Qnq > ~/.config/dotfiles/$machine.native
sudo pacman -Qmq > ~/.config/dotfiles/$machine.aur

echo "BleachBit runnning"

# This options will use what is set in the ~/.config/bleachbit/bleachbit.ini 
# The options there come from what is set up in the gui.
# PLEASE: open the gui and make sure that you have the right options there
# Also consider adding this options
# [whitelist/paths]
# 0_type = folder
# 0_path = /home/reinaldo/Seafile
# 1_type = folder
# 1_path = /home/reinaldo/Dropbox
# Also disable system.memory clean swap but requires sudo

bleachbit --clean --preset

# echo "Cleaning shitty files"
# curl -kLo ~/.cache/rmshit.py "https://raw.githubusercontent.com/lahwaacz/Scripts/master/rmshit.py"
# chmod +x ~/.cache/rmshit.py
# python cache/rmshit.py

# echo "Updating fish completions"
# fish_update_completions
