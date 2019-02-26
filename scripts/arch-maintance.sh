#/bin/sh

# File:					arch-maintance.sh
# Description:			File to give arch maintance
# Author:				Reinaldo Molina <rmolin88@gmail.com>
# Version:				0.0.0
# Last Modified: Fri Feb 23 2018 06:11
# Created: Oct 15 2017 10:03

machine=`hostname`

echo "Cleaning pacman"
# This is very dangerous
# sudo pacman -Sc --noconfirm
# Better way paccache will remove everything except the latest THREE versions of a package
sudo paccache -r
# And remove remove all cached versions of uninstalled packages
sudo paccache -ruk0
# Rolling Back to an Older Version of a Package
# sudo pacman -U /var/cache/pacman/pkg/name-version.pkg.tar.gz
# sudo pacman-optimize

echo "Emptying trash"
gio trash --empty

echo "Emptying cache"
rm -r ~/.cache

# Tue Sep 26 2017 18:40 Update Mirror list. Depends on `reflector`
if hash reflector 2>/dev/null; then
	sudo reflector --protocol https --latest 30 --number 5 --sort rate --save /etc/pacman.d/mirrorlist -c 'United States' --verbose
else
	echo "reflector is not installed"
fi

# echo "Optimizing system memory now in order to do all sudo commands at once"
# sudo bleachbit --clean system.memory

# echo "Updating system"
# trizen -Syu
sudo pacman -Qnq > ~/.config/dotfiles/pkg/$machine/native
sudo pacman -Qmq > ~/.config/dotfiles/pkg/$machine/aur

# This is also dangerous do it manually
echo "Removing unused orphan packages. Look through the list and exit if you see
something unusual"
sudo pacman -Rns $(pacman -Qtdq)

# echo "BleachBit runnning"

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

# bleachbit --clean --preset
# Alternative
# bleachbit --list | grep -E "[a-z0-9_\-]+\.[a-z0-9_\-]+" | grep -v system.free_disk_space | xargs bleachbit --clean

# echo "Cleaning shitty files"
# curl -kLo ~/.cache/rmshit.py "https://raw.githubusercontent.com/lahwaacz/Scripts/master/rmshit.py"
# chmod +x ~/.cache/rmshit.py
# python cache/rmshit.py

# echo "Updating fish completions"
# fish_update_completions
