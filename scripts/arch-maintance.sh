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
fi

echo "Removing unused orphan packages"
pacman -Rns $(pacman -Qtdq)

echo "Updating system"
pacman -Syuu --devel --noconfirm
pacman -Qqet > ~/.config/dotfiles/$machine-arch-packages

# TODO-[RM]-(Sun Oct 15 2017 10:28): find out bleachbit command line options.

echo "Check ~/.config for old software with options there"
