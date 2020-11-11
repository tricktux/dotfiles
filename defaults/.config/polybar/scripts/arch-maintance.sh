#/bin/sh

# File:					arch-maintance.sh
# Description:			File to give arch maintance
# Author:				Reinaldo Molina <rmolin88@gmail.com>
# Version:				0.0.0
# Last Modified: Fri Feb 23 2018 06:11
# Created: Oct 15 2017 10:03

machine=`hostname`

echo "Cleaning files desktop files..."
/home/reinaldo/.config/polybar/scripts/rm_junk
# Recreating deleted files
mkdir ~/.cache
# Recreating deleted files
gio trash --empty

clean_pacman_cache() {
	# This is very dangerous
	# sudo pacman -Sc --noconfirm
	# Better way paccache will remove everything except the latest THREE versions of 
	# a package
	sudo paccache -r
	# And remove remove all cached versions of uninstalled packages
	sudo paccache -ruk0
	# Rolling Back to an Older Version of a Package
	# sudo pacman -U /var/cache/pacman/pkg/name-version.pkg.tar.gz
	# sudo pacman-optimize
}

remove_pacman_orphans() {
	# This is also dangerous do it manually
	echo "Please look through the list and exit if you see something unusual"
	sudo pacman -Rns $(pacman -Qtdq)
}

read -p "Do you wish to clean pacman cache? (y/N)" yn
case $yn in
		[Yy]* ) clean_pacman_cache;;
esac

read -p "Do you wish to remove pacman orphans? (y/N)" yn
case $yn in
		[Yy]* ) remove_pacman_orphans;;
esac

read -p "Do you wish to clean with bleachbit? (y/N)" yn
case $yn in
	[Yy]* ) bleachbit --clean --preset;;
esac
# Tue Sep 26 2017 18:40 Update Mirror list. Depends on `reflector`
# echo "Optimizing system memory now in order to do all sudo commands at once"
# sudo bleachbit --clean system.memory

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
# bleachbit --list | grep -E "[a-z0-9_\-]+\.[a-z0-9_\-]+" | grep -v 
# system.free_disk_space | xargs bleachbit --clean

systemctl --failed
read -n1 -r -p "Look for failures in services..." key
journalctl -p 3 -xb
read -n1 -r -p "Look for errors in log files..." key
read -n1 -r -p "Done. Press any key to continue..." key
