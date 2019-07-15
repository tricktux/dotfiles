#!/bin/sh

i3-msg "floating toggle"

echo "Updating pacman mirrors ..."
if hash /usr/bin/reflector 2>/dev/null; then
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
# Sun Jul 14 2019 12:54
#  Stick to stable neovim
# trizen -S neovim-git
nvim +PlugUpgrade +PlugUpdate +UpdateRemotePlugins

# Wed Apr 17 2019 22:46
# Gets updated on arch-maintance.sh script
# echo "Updating zplug ..."
# zplug update

# Sun Jul 14 2019 20:59
# For some reason pandoc-{citeproc,crossref}-bin have been deleted from aur
# So use this temporary workaround
echo "Updating pandoc binaries..."
cd /tmp
git clone --recursive https://github.com/ashwinvis/aur.git
cd aur
makepkg -si

read -n1 -r -p "Done. Press any key to continue..." key
