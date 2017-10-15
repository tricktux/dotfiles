#/bin/sh

# File:					arch-maintance.sh
# Description:			File to give arch maintance
# Author:				Reinaldo Molina <rmolin88@gmail.com>
# Version:				0.0.0
# Last Modified: Oct 15 2017 10:03
# Created: Oct 15 2017 10:03

echo "Optimizing pacman"
sudo pacman -Sc --noconfirm
sudo pacman-optimize
# Tue Sep 26 2017 18:40 Update Mirror list. Depends on `reflector`
if hash reflector 2>/dev/null; then
	sudo reflector --protocol https --latest 30 --number 5 --sort rate --save /etc/pacman.d/mirrorlist -c 'United States' --verbose
else
	echo "Please install reflector"
	exit 8
fi

echo "Removing unused orphan packages"
pacman -Rns $(pacman -Qtdq)

echo "Updating system"
pacaur -Syuu --devel --noconfirm
pacman -Qqet > ~/.config/dotfiles/$machine-arch-packages

echo "BleachBit runnning"
# Make sure to run it the first time and set up the cleaners.
# Then go to ~/.config/bleachbit and copy all the [tree] cleaners
bleachbit -c \
	google_chrome.cache \
	google_chrome.cookies \
	google_chrome.dom \
	google_chrome.form_history \
	google_chrome.history \
	google_chrome.search_engines \
	google_chrome.session \
	google_chrome.vacuum \
	libreoffice.cache \
	libreoffice.history \
	system.desktop_entry \
	system.cache \
	system.clipboard \
	system.custom \
	system.free_disk_space \
	system.localizations \
	system.memory \
	system.recent_documents \
	system.rotated_logs \
	system.tmp \
	system.trash \
	thumbnails.cache \
	transmission.blocklists \
	transmission.history \
	transmission.torrents \
	x11.debug_logs \
	deepscan \
	deepscan.ds_store \
	deepscan.backup \
	deepscan.tmp \
	deepscan.thumbs_db

echo "Cleaning shitty files"
curl -kLo ~/.cache/rmshit.py "https://raw.githubusercontent.com/lahwaacz/Scripts/master/rmshit.py"
chmod +x ~/.cache/rmshit.py
python cache/rmshit.py


