#!/bin/sh

# i3-msg "floating toggle"

echo "Updating system..."
# Always update keyring first in case it's been a while you've updated the 
# system
trizen -S archlinux-keyring
trizen -Syu
echo "Storing package list..."
PACMANFILE="$XDG_CONFIG_HOME/dotfiles/pkg/$(hostname)/pacman-list.pkg"
AURFILE="$XDG_CONFIG_HOME/dotfiles/pkg/$(hostname)/aur-list.pkg"
pacman -Qqen > $PACMANFILE
pacman -Qqem > $AURFILE


update_polybar_python_venv() {
  local venv_loc="$XDG_DATA_HOME/pyvenv"
  local venv_name="polybar"
  local pkgs=(
    requests jinja2 stravalib
  )

  mkdir -p "$venv_loc"
  python -m venv "$venv_loc/$venv_name" \
    --symlinks --clear
  source "$venv_loc/$venv_name/bin/activate"
  pip3 install --upgrade ${pkgs[*]}
  deactivate
}

update_pass_import_python_venv() {
  local venv_loc="$XDG_DATA_HOME/pyvenv"
  local venv_name="pass-import"
  local pkgs=(
    defusedxml pykeepass secretstorage cryptography file-magic
  )

  mkdir -p "$venv_loc"
  python -m venv "$venv_loc/$venv_name" \
    --symlinks --clear
  source "$venv_loc/$venv_name/bin/activate"
  pip3 install --upgrade ${pkgs[*]}
  deactivate
}

update_nvim_plugins() {
  nvim +PlugUpgrade +PlugUpdate +UpdateRemotePlugins
}

update_pynvim() {
  # source /home/reinaldo/.config/nvim/python_neovim_virtualenv.sh
  local venv_loc="$XDG_DATA_HOME/pyvenv"
  local venv_name="nvim"
  local pkgs=(
    vim-vint psutil flake8 jedi
    "python-language-server[all]" frosted
    pep8 pylint pynvim isort
  )

  mkdir -p "$venv_loc"
  python -m venv "$venv_loc/$venv_name" \
    --symlinks --clear
  source "$venv_loc/$venv_name/bin/activate"
  pip3 install --upgrade ${pkgs[*]}
  deactivate
}

update_pandoc_bin() {
  # Sun Jul 14 2019 20:59
  # For some reason pandoc-{citeproc,crossref}-bin have been deleted from aur
  # So use this temporary workaround
  cd /tmp
  git clone --recursive https://github.com/ashwinvis/aur.git
  cd aur/pandoc-citeproc-bin
  makepkg -si
  cd ../pandoc-crossref-bin
  makepkg -si
}

read -p "Do you wish to update python polybar env? (y/N)" yn
case $yn in
[Yy]*) update_polybar_python_venv ;;
esac
read -p "Do you wish to update pass import python? (y/N)" yn
case $yn in
[Yy]*) update_pass_import_python_venv ;;
esac
read -p "Do you wish to update neovim pyvenv? (y/N)" yn
case $yn in
  [Yy]*) update_pynvim ;;
esac
read -p "Do you wish to update neovim plugins? (y/N)" yn
case $yn in
[Yy]*) update_nvim_plugins ;;
esac
read -p "Do you wish to update neovim-git? (y/N)" yn
case $yn in
[Yy]*) trizen -S neovim-git ;;
esac
read -p "Do you wish to update zsh-zim? (y/N)" yn
case $yn in
[Yy]*)
  zsh "$ZDOTDIR/.zim/zimfw.zsh" upgrade
  zsh "$ZDOTDIR/.zim/zimfw.zsh" update
  ;;
esac
read -p "Do you wish to pandoc-{citeproc,crossref}-bin? (y/N)" yn
case $yn in
[Yy]*) update_pandoc_bin ;;
esac

read -n1 -r -p "Manually update the firefox userjs: ~/.mozilla/firefox/<profile>" key
read -n1 -r -p "Done. Press any key to continue..." key
