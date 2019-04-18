#!/bin/sh

echo "Updating pacman mirrors ..."
if hash reflector 2>/dev/null; then
	sudo reflector --protocol https --latest 30 --number 5 --sort \
		rate --save /etc/pacman.d/mirrorlist -c 'United States' --verbose
else
	echo "reflector is not installed"
fi

echo "Updating python ..."
source ~/.config/dotfiles/scripts/python_neovim_virtualenv.sh

echo "Updating system ..."
trizen -Syu

echo "Updating neovim ..."
trizen -S neovim-git
nvim +PlugUpgrade +PlugUpdate +UpdateRemotePlugins

echo "Updating zplug ..."
zplug update

read -n1 -r -p "Done. Press any key to continue..." key
