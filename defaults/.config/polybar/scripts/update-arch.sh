#!/usr/bin/env bash
# Inspiration from:
# https://betterdev.blog/minimal-safe-bash-script-template/

aur_helper='paru'
# Fail as soon as a command fails
set -Eeuo pipefail

# Execute cleanup() if any of these sig events happen
trap cleanup SIGINT SIGTERM ERR #EXIT

cleanup() {
  trap - SIGINT SIGTERM ERR #EXIT
  msg_error "==> Something went wrong...   "
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
  echo >&2 -e "${1-}${2-}${NOFORMAT}"
}
msg_not() {
  echo >&2 -e "${1-}${2-}${NOFORMAT}"
  # Skip pretty characters
  notify-send 'Arch Update' "${2:4:-6}"
}
msg_error() {
  echo >&2 -e "${RED}${BOLD}${1-}${NOFORMAT}"
  notify-send 'Arch Update' "${1:4:-6}" -u critical
}

update_polybar_python_venv() {
  local venv_loc="$XDG_DATA_HOME/pyvenv"
  local venv_name="polybar"
  local pkgs=(
    requests jinja2 stravalib matplot
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
    pyaml pass-import
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
    vim-vint psutil flake8 jedi=0.17.2 matplot
    "python-language-server[all]" frosted
    pep8 pylint pynvim isort mypy
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
  git clone --recursive https://github.com/ashwinvis/aur.git /tmp/aur
  cd /tmp/aur/pandoc-citeproc-bin
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

update_pihole() {
  ssh root@192.168.1.107 /bin/bash <<EOF
pihole -up
cloudflared update
systemctl status cloudflared
EOF
}

setup_colors

msg "${CYAN}${BOLD}" "========== Welcome! To the Arch Maintnance Script! 💪😎  =========="
# Backups first, since most likely they'll be kernel update and that messes up
# everything
msg_not "${BLUE}${BOLD}" "==> Back up important folders? [y/N]"
read yn
case $yn in
[Yy]*) sudo "$XDG_CONFIG_HOME/dotfiles/scripts/nix/rsync/rsnapshot_home.sh" ;;
esac
msg_not "${BLUE}${BOLD}" "==> Back up the mail server (~30mins)? [y/N]"
read yn
case $yn in
[Yy]*)
  "$TERMINAL" sudo \
    $XDG_CONFIG_HOME/dotfiles/scripts/nix/rsync/rsnapshot_digital_ocean.sh &
  ;;
esac
msg_not "${BLUE}${BOLD}" "==> Sync passwords? [y/N]"
read yn
case $yn in
[Yy]*)
  "$TERMINAL" $HOME/Documents/wiki/scripts/backup_keepass_db.sh &
  ;;
esac
msg_not "${BLUE}${BOLD}" "==> Back up emails (~15mins)? [y/N]"
read yn
case $yn in
[Yy]*)
  "$TERMINAL" sudo \
    $XDG_CONFIG_HOME/dotfiles/scripts/nix/rsync/rsnapshot_mail.sh &
  ;;
esac

# Always update keyring first in case it's been a while you've updated the
# system
# This is not a good practice. Leaving it here for reference
# msg "${CYAN}${BOLD}==> Updating keyring...   "
# $aur_helper -Sy --needed archlinux-keyring ca-certificates

msg_not "${CYAN}${BOLD}" "==> Updating core packages...   "
sudo pacman -Syu

msg_not "${CYAN}${BOLD}" "==> Updating aur packages...   "
$aur_helper -Syu

msg "${CYAN}${BOLD}" "==> Storing package list...   "
save_pkg_list_to_dotfiles

msg "${CYAN}${BOLD}" "==> Checking for .pacnew files...   "
if [[ $(/usr/bin/pacdiff -o) ]]; then
  msg_not "${CYAN}${BOLD}" "==> Please address .pacnew files...   "
  sudo DIFFPROG="nvim -d" DIFFSEARCHPATH="/boot /etc /usr" /usr/bin/pacdiff
fi

if [[ -f /usr/bin/ancient-packages ]] && [[ $(/usr/bin/ancient-packages -q) ]]; then
  /usr/bin/ancient-packages
  msg_not "${CYAN}${BOLD}" "==> Remove ancient packages? [y/N]"
  read yn
  case $yn in
  [Yy]*) $aur_helper -Rscn $(ancient-packages -q) ;;
  esac
fi

msg "${CYAN}${BOLD}" "==> Checking for orphan packages...   "
if [[ $(/usr/bin/pacman -Qtdq) ]]; then
  msg_not "${CYAN}${BOLD}" "==> Please clean orphan packages...   "
  sudo /usr/bin/pacman -Rns $(/usr/bin/pacman -Qtdq) || echo "...  Or not..."
fi

msg "${CYAN}${BOLD}" "==> Clean up pacman's cache...   "
sudo /usr/bin/paccache -ruk0 -r

msg_not "${CYAN}${BOLD}" "==> Checking for failed services...   "
systemctl --failed
read -n1 -r key

msg_not "${CYAN}${BOLD}" "==> Looking for errors in journalctl...   "
journalctl -p 3 -xb
read -n1 -r key

msg_not "${BLUE}${BOLD}" "==> Update pihole? [y/N]"
read yn
case $yn in
[Yy]*)
  kitty +kitten ssh root@192.168.1.107
  ;;
esac
msg_not "${BLUE}${BOLD}" "==> Update mail server? [y/N]"
read yn
case $yn in
[Yy]*)
  kitty +kitten ssh digital_ocean
  # apt-get -y update &&
  # apt-get -y upgrade &&
  # apt-get -y autoremove &&
  # apt-get -y autoclean
  # reboot
  # EOF
  ;;
esac
msg_not "${BLUE}${BOLD}" "==> Remove junk? [y/N]"
read yn
case $yn in
[Yy]*)
  msg "${CYAN}${BOLD}" "==> Please close all applications..."
  read -n1 -r key
  "$XDG_CONFIG_HOME/polybar/scripts/rm_junk"
  mkdir -p ~/.cache
  # Clean trash
  gio trash --empty
  # Restore pywal cache files
  msg "${CYAN}${BOLD}" "==> Please restore colors by forcing flux night or day..."
  read -n1 -r key
  ;;
esac
msg_not "${BLUE}${BOLD}" "==> Remove browser junk? [y/N]"
read yn
case $yn in
[Yy]*)
  msg "${CYAN}${BOLD}" "==> Please close browsers...   "
  read -n1 -r key
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
msg_not "${BLUE}${BOLD}" "==> Update python polybar env? [y/N]"
read yn
case $yn in
[Yy]*) update_polybar_python_venv ;;
esac
msg_not "${BLUE}${BOLD}" "==> Update pass import python? [y/N]"
read yn
case $yn in
[Yy]*) update_pass_import_python_venv ;;
esac
msg_not "${BLUE}${BOLD}" "==> Update neovim pyvenv? [y/N]"
read yn
case $yn in
[Yy]*) update_pynvim ;;
esac
msg_not "${BLUE}${BOLD}" "==> Update neovim plugins? [y/N]"
read yn
case $yn in
[Yy]*) update_nvim_plugins ;;
esac
msg_not "${BLUE}${BOLD}" "==> Diff ranger config with default? [y/N]"
read yn
case $yn in
[Yy]*)
  nvim -d /usr/share/doc/ranger/config/rc.conf \
    "$XDG_CONFIG_HOME/ranger/rc.conf"
  ;;
esac
# msg_not "${BLUE}${BOLD}" "==> Update github third-party repos? [y/N]"
# read yn
# case $yn in
# [Yy]*)
# ;;
# esac
# Sun Jan 17 2021 05:52: Moved to neovim-nightly-bin
# msg_not "${BLUE}${BOLD}" "==> Update neovim-git? [y/N]"
# read yn
# case $yn in
# [Yy]*) $aur_helper -S neovim-git ;;
# esac
msg_not "${BLUE}${BOLD}" "==> Update zsh-zim? [y/N]"
read yn
case $yn in
[Yy]*)
  zsh "$ZDOTDIR/.zim/zimfw.zsh" upgrade
  zsh "$ZDOTDIR/.zim/zimfw.zsh" update
  ;;
esac
msg_not "${BLUE}${BOLD}" "==> Update pandoc extras? [y/N]"
read yn
case $yn in
[Yy]*) update_pandoc_bin ;;
esac
msg_not "${BLUE}${BOLD}" "==> Manually update the firefox userjs: ~/.mozilla/firefox/<profile>"
read -n1 -r key

for job in $(jobs -p); do
  msg_not "${BLUE}${BOLD}" "==> Waiting for job: ${job} to finish...   "
  wait $job
done
msg_not "${BLUE}${BOLD}" "==> Thanks for flying arch updates!"
read -n1 -r key
