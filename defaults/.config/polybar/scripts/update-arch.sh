#!/bin/sh

# i3-msg "floating toggle"

echo "Updating system ..."
trizen -Syu

update_pacman_mirrors() {
  if hash /usr/bin/reflector 2>/dev/null; then
    sudo reflector --protocol https --latest 30 --number 5 --sort \
      rate --save /etc/pacman.d/mirrorlist -c 'United States' --verbose
  else
    echo "reflector is not installed"
  fi
}

update_python_venv() {
  local pkgs=(
    requests jinja2 stravalib vim-vint psutil
    flake8 isort jedi "python-language-server[all]" frosted
    pep8 pylint neovim-remote
  )

  pip3 install --upgrade --user ${pkgs[*]}
}

update_nvim_plugins() {
  nvim +PlugUpgrade +PlugUpdate +UpdateRemotePlugins
}

update_pynvim() {
  # source /home/reinaldo/.config/nvim/python_neovim_virtualenv.sh
  local venv_loc="$XDG_DATA_HOME/nvim/"
  local venv_name="pyvenv"

  local pkgs=(pynvim)

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

read -p "Do you wish to update python system wide env? (y/N)" yn
case $yn in
[Yy]*) update_python_venv ;;
esac
read -p "Do you wish to update pacman mirrors? (y/N)" yn
case $yn in
[Yy]*) update_pacman_mirrors ;;
esac
read -p "Do you wish to update neovim plugins? (y/N)" yn
case $yn in
[Yy]*) update_nvim_plugins ;;
esac
read -p "Do you wish to update neovim pyvenv? (y/N)" yn
case $yn in
[Yy]*) update_pynvim ;;
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
