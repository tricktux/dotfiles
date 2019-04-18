#!/bin/sh

i3-msg "floating toggle"

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

# Wed Apr 17 2019 22:46
# Gets updated on arch-maintance.sh script
# echo "Updating zplug ..."
# zplug update

read -n1 -r -p "Done. Press any key to continue..." key
