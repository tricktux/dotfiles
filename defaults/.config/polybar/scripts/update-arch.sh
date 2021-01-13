#!/usr/bin/env bash
# Inspiration from:
# https://betterdev.blog/minimal-safe-bash-script-template/

# Fail as soon as a command fails
set -Eeuo pipefail

# Execute cleanup() if any of these sig events happen
trap cleanup SIGINT SIGTERM ERR #EXIT

cleanup() {
  trap - SIGINT SIGTERM ERR #EXIT
  msg "${RED}${BOLD}==> Something went wrong..."
  read -n1 -r key
  exit $?
}

# Colors are only meant to be used with msg()
# Sample usage:
# msg "This is a ${RED}very important${NOFORMAT} message
setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' \
      BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' \
      YELLOW='\033[1;33m' BOLD='\033[1m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW='' \
      BOLD=''
  fi
}

msg() {
  echo >&2 -e "${1-}${NOFORMAT}"
}

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

update_github_repositories() {
  local repos=(
    "$XDG_DATA_HOME\polybar-scripts"
  )

  for i in "${repos[@]}"; do
    if [[ -d "$i" ]]; then
      cd "$i"
      git pull origin master
    fi
  done
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

save_pkg_list_to_dotfiles() {
  local PACMANFILE="$XDG_CONFIG_HOME/dotfiles/pkg/$(hostname)/pacman-list.pkg"
  local AURFILE="$XDG_CONFIG_HOME/dotfiles/pkg/$(hostname)/aur-list.pkg"
  pacman -Qqen >$PACMANFILE
  pacman -Qqem >$AURFILE
}

setup_colors

# Always update keyring first in case it's been a while you've updated the
# system
# This is not a good practice. Leaving it here for reference
# msg "${CYAN}${BOLD}==> Updating keyring..."
# trizen -Sy --needed archlinux-keyring ca-certificates

msg "${CYAN}${BOLD}==> Updating all packages..."
trizen -Syu

msg "${CYAN}${BOLD}==> Storing package list..."
save_pkg_list_to_dotfiles

msg "${CYAN}${BOLD}==> Checking for .pacnew files..."
sudo DIFFPROG="nvim -d" DIFFSEARCHPATH="/boot /etc /usr" /usr/bin/pacdiff

if [[ -f /usr/bin/ancient-packages ]]; then
  msg "${CYAN}${BOLD}==> Lists installed packages no longer available..."
  ancient-packages ||
    msg "${RED}${BOLD}Try again with a wider screen later"
  msg "${CYAN}${BOLD}==> Do you wish to remove ancient packages? [y/N]"
  read yn
  case $yn in
  [Yy]*) trizen -Rscn $(ancient-packages -q) ;;
  esac
fi

msg "${CYAN}${BOLD}==> Clean up orphan packages..."
sudo /usr/bin/pacman -Rns $(/usr/bin/pacman -Qtdq) ||
  msg "${GREEN}${BOLD}No orphans detected"

msg "${CYAN}${BOLD}==> Clean up pacman's cache..."
sudo /usr/bin/paccache -ruk0 -r

msg "${CYAN}${BOLD}==> Check for failed systemd services..."
systemctl --failed
read -n1 -r key

msg "${CYAN}${BOLD}==> Look for high priority errors in the systemd journal..."
journalctl -p 3 -xb
read -n1 -r key

msg "${BLUE}${BOLD}==> Do you wish to back up important folders? [y/N]"
read yn
case $yn in
[Yy]*) sudo "$XDG_CONFIG_HOME/dotfiles/scripts/nix/rsync/rsnapshot_home.sh" ;;
esac
msg "${BLUE}${BOLD}==> Do you wish to back up the mail server (~30mins)? [y/N]"
read yn
case $yn in
[Yy]*)
  sudo "$XDG_CONFIG_HOME/dotfiles/scripts/nix/rsync/rsnapshot_digital_ocean.sh"
  ;;
esac
msg "${BLUE}${BOLD}==> Do you wish to back up emails (~30mins)? [y/N]"
read yn
case $yn in
[Yy]*)
  offlineimap -c "$XDG_CONFIG_HOME/dotfiles/offlineimap/backup" -o
  ;;
esac
msg "${BLUE}${BOLD}==> Do you wish to remove junk? [y/N]"
read yn
case $yn in
[Yy]*)
  source /home/reinaldo/.config/polybar/scripts/rm_junk
  ;;
esac
msg "${BLUE}${BOLD}==> Do you wish to remove browser junk? [y/N]"
read yn
case $yn in
[Yy]*)
  bleachbit --clean chromium.cache \
    firefox.backup \
    firefox.cache \
    firefox.cookies \
    firefox.crash_reports \
    firefox.dom \
    firefox.forms \
    firefox.passwords \
    firefox.session_restore \
    firefox.site_preferences \
    firefox.url_history \
    firefox.vacuum \
    chromium.cookies \
    chromium.dom \
    chromium.form_history \
    chromium.history \
    chromium.passwords \
    chromium.search_engines \
    chromium.session \
    chromium.sync \
    chromium.vacuum
  ;;
esac
msg "${BLUE}${BOLD}==> Do you wish to update python polybar env? [y/N]"
read yn
case $yn in
[Yy]*) update_polybar_python_venv ;;
esac
msg "${BLUE}${BOLD}==> Do you wish to update pass import python? [y/N]"
read yn
case $yn in
[Yy]*) update_pass_import_python_venv ;;
esac
msg "${BLUE}${BOLD}==> Do you wish to update neovim pyvenv? [y/N]"
read yn
case $yn in
[Yy]*) update_pynvim ;;
esac
msg "${BLUE}${BOLD}==> Do you wish to update neovim plugins? [y/N]"
read yn
case $yn in
[Yy]*) update_nvim_plugins ;;
esac
msg "${BLUE}${BOLD}==> Do you wish to update neovim-git? [y/N]"
read yn
case $yn in
[Yy]*) trizen -S neovim-git ;;
esac
msg "${BLUE}${BOLD}==> Do you wish to update zsh-zim? [y/N]"
read yn
case $yn in
[Yy]*)
  zsh "$ZDOTDIR/.zim/zimfw.zsh" upgrade
  zsh "$ZDOTDIR/.zim/zimfw.zsh" update
  ;;
esac
msg "${BLUE}${BOLD}==> Do you wish to pandoc-{citeproc,crossref}-bin? [y/N]"
read yn
case $yn in
[Yy]*) update_pandoc_bin ;;
esac
msg "${BLUE}${BOLD}==> Manually update the firefox userjs: ~/.mozilla/firefox/<profile>"
read -n1 -r key
msg "${BLUE}${BOLD}==> Thanks for flying arch updates!"
read -n1 -r key
