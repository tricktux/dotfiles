#!/usr/bin/env bash
# Inspiration from:
# https://betterdev.blog/minimal-safe-bash-script-template/

aur_helper='paru'
pacman_cache_loc="nowtheme@192.168.1.139::NetBackup/pacman_cache/$(uname -m)/"
rsync_opts="-rltgoi --delay-updates --delete --copy-links -e ssh"
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
  notify-send 'Arch Update' "${2:10:-8}"
}
msg_error() {
  echo >&2 -e "${RED}${BOLD}${1-}${NOFORMAT}"
  notify-send 'Arch Update' "${1:4:-8}" -u critical
}

quit() {
  for job in $(jobs -p); do
    msg_not "${BLUE}${BOLD}" "[RIMP]==> Waiting for job: ${job} to finish...     "
    wait "$job"
  done
  msg_not "${BLUE}${BOLD}" "[RIMP]==> Thanks for flying arch updates!"
  read -n1 -r key
  exit 0
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

update_nvim_plugins() {
  nvim +PlugUpgrade +PlugUpdate +PackerSync +UpdateRemotePlugins
}

update_pynvim() {
  # source /home/reinaldo/.config/nvim/python_neovim_virtualenv.sh
  local venv_loc="$XDG_DATA_HOME/pyvenv"
  local venv_name="nvim"
  local pkgs=(
    vim-vint psutil flake8 jedi matplot
    frosted pep8 pylint pylama pynvim isort mypy debugpy
  )

  mkdir -p "$venv_loc"
  python -m venv "$venv_loc/$venv_name" \
    --symlinks --clear
  source "$venv_loc/$venv_name/bin/activate"
  pip3 install --ignore-installed --upgrade ${pkgs[*]}
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
  pacman -Qqen >"$PACMANFILE"
  pacman -Qqem >"$AURFILE"
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
msg_not "${BLUE}${BOLD}" "[RIMP]==> Back up important folders? [y/N/q]"
read -r yn
case $yn in
[Yy]*) "$XDG_CONFIG_HOME/dotfiles/scripts/nix/rsync/rsnapshot_home.sh" ;;
[Qq]*) quit ;;
esac
msg_not "${BLUE}${BOLD}" "[RIMP]==> Back up the mail server (~30mins)? [y/N/q]"
read -r yn
case $yn in
[Qq]*) quit ;;
[Yy]*)
  "$TERMINAL" \
    "$XDG_CONFIG_HOME/dotfiles/scripts/nix/rsync/rsnapshot_digital_ocean.sh" &
  ;;
esac
# TODO: Semi Automate this process
# msg_not "${BLUE}${BOLD}" "==> Sync passwords? [y/N]"
# read yn
# case $yn in
# [Yy]*)
# "$TERMINAL" $HOME/Documents/scripts/backup_keepass_db.sh &
# ;;
# esac
msg_not "${BLUE}${BOLD}" "[RIMP]==> Back up emails (~15mins)? [y/N/q]"
read -r yn
case $yn in
[Qq]*) quit ;;
[Yy]*)
  "$TERMINAL" \
    "$XDG_CONFIG_HOME/dotfiles/scripts/nix/rsync/rsnapshot_mail.sh" &
  ;;
esac

# Always update keyring first in case it's been a while you've updated the
# system
# This is not a good practice. Leaving it here for reference
# msg "${CYAN}${BOLD}==> Updating keyring...   "
# sudo pacman-key --refresh-keys
# $aur_helper -Sy --needed archlinux-keyring ca-certificates

msg_not "${CYAN}${BOLD}" "[RIMP]==> Updating pacman cache FROM server...     "
rsync -rltgoi --delay-updates --delete --copy-links -e ssh \
  $pacman_cache_loc /var/cache/pacman/pkg/ || echo "there were errors..."

msg_not "${CYAN}${BOLD}" "[RIMP]==> Updating core packages...     "
sudo pacman -Syu

msg_not "${CYAN}${BOLD}" "[RIMP]==> Updating aur packages...     "
$aur_helper -Syu

msg "${CYAN}${BOLD}" "[RIMP]==> Storing package list...     "
save_pkg_list_to_dotfiles

msg "${CYAN}${BOLD}" "[RIMP]==> Checking for .pacnew files...     "
if [[ $(/usr/bin/pacdiff -o) ]]; then
  msg_not "${CYAN}${BOLD}" "[RIMP]==> Please address .pacnew files...     "
  sudo DIFFPROG="nvim -d" DIFFSEARCHPATH="/boot /etc /usr" /usr/bin/pacdiff
fi

if [[ -f /usr/bin/ancient-packages ]] && [[ $(/usr/bin/ancient-packages -q) ]]; then
  /usr/bin/ancient-packages
  msg_not "${CYAN}${BOLD}" "[RIMP]==> Remove ancient packages? [y/N/q]"
  read -r yn
  case $yn in
  [Qq]*) quit ;;
  [Yy]*) $aur_helper -Rscn "$(ancient-packages -q)" ;;
  esac
fi

msg "${CYAN}${BOLD}" "[RIMP]==> Checking for orphan packages...     "
if [[ $(/usr/bin/pacman -Qtdq) ]]; then
  msg_not "${CYAN}${BOLD}" "[RIMP]==> Please clean orphan packages...     "
  sudo /usr/bin/pacman -Rns "$(/usr/bin/pacman -Qtdq)" || echo "...  Or not..."
fi

msg "${CYAN}${BOLD}" "[RIMP]==> Clean up pacman's cache...     "
# Leave only the 3 most recent versions of packaages
sudo /usr/bin/paccache -r
# Remove cache for deleted packages
sudo /usr/bin/paccache -ruk0

msg_not "${CYAN}${BOLD}" "[RIMP]==> Updating pacman cache TO server...     "
rsync -rltgoi --delay-updates --delete --copy-links -e ssh \
  /var/cache/pacman/pkg/ "$pacman_cache_loc" || echo "there were errors..."

if [[ -f /usr/bin/fwupdmgr ]]; then
  msg "${CYAN}${BOLD}" "[RIMP]==> Update firmware?...     "
  sudo /usr/bin/fwupdmgr update || echo "...  Or not..."
else
  msg_not "${CYAN}${BOLD}" "[RIMP]==> Consider installing fwupdmgr?...     "
fi

msg_not "${CYAN}${BOLD}" "[RIMP]==> Checking for failed services...     "
systemctl --failed
read -n1 -r key

msg_not "${CYAN}${BOLD}" "[RIMP]==> Looking for errors in journalctl...     "
journalctl -p 3 -xb
read -n1 -r key

msg_not "${BLUE}${BOLD}" "[RIMP]==> Update pihole? [y/N/q]"
read -r yn
case $yn in
[Qq]*) quit ;;
[Yy]*)
  kitty +kitten ssh root@192.168.1.107
  ;;
esac
msg_not "${BLUE}${BOLD}" "[RIMP]==> Update mail server? [y/N/q]"
read -r yn
case $yn in
[Qq]*) quit ;;
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
msg_not "${BLUE}${BOLD}" "[RIMP]==> Remove junk? [y/N/q]"
read -r yn
case $yn in
[Qq]*) quit ;;
[Yy]*)
  msg "${CYAN}${BOLD}" "[RIMP]==> Please close all applications...  "
  read -n1 -r key
  "$XDG_CONFIG_HOME/polybar/scripts/rm_junk"
  mkdir -p ~/.cache
  # Clean trash
  gio trash --empty
  # Restore pywal cache files
  "$XDG_CONFIG_HOME/polybar/scripts/flux_/flux" -c \
    "$XDG_CONFIG_HOME/polybar/scripts/flux_/flux_config.lua" -f day
  ;;
esac
msg_not "${BLUE}${BOLD}" "[RIMP]==> Remove browser junk? [y/N/q]"
read -r yn
case $yn in
[Qq]*) quit ;;
[Yy]*)
  msg "${CYAN}${BOLD}" "[RIMP]==> Please close browsers...     "
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
msg_not "${BLUE}${BOLD}" "[RIMP]==> Update python polybar env? [y/N/q]"
read -r yn
case $yn in
[Qq]*) quit ;;
[Yy]*) update_polybar_python_venv ;;
esac
msg_not "${BLUE}${BOLD}" "[RIMP]==> Update neovim pyvenv? [y/N/q]"
read -r yn
case $yn in
[Qq]*) quit ;;
[Yy]*) update_pynvim ;;
esac
msg_not "${BLUE}${BOLD}" "[RIMP]==> Update neovim plugins? [y/N/q]"
read -r yn
case $yn in
[Qq]*) quit ;;
[Yy]*) update_nvim_plugins ;;
esac
msg_not "${BLUE}${BOLD}" "[RIMP]==> Update all npm global packages (md2apkg)? [y/N/q]"
read -r yn
case $yn in
[Qq]*) quit ;;
[Yy]*)
  if [[ -f /usr/bin/npm ]]; then
    /usr/bin/npm update -g
  fi
  ;;
esac
msg_not "${BLUE}${BOLD}" "[RIMP]==> Update neovim nightly? [y/N/q]"
read -r yn
case $yn in
[Qq]*) quit ;;
[Yy]*)
  # Create a subshell to cd locally
  (
    set -o pipefail
    pkgname=neovim-git
    srcdir=/tmp
    pkgdir=
    cd /tmp/
    git clone --depth=1 https://github.com/neovim/neovim.git "${pkgname}"
    cmake -S"${pkgname}" -Bbuild \
      -DCMAKE_BUILD_TYPE=RelWithDebInfo \
      -DCMAKE_INSTALL_PREFIX=/usr
    cmake --build build
    cd "${srcdir}/build"
    sudo DESTDIR="${pkgdir}" cmake --build . --target install

    cd "${srcdir}/${pkgname}"
    sudo install -Dm644 LICENSE "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
    sudo install -Dm644 runtime/nvim.desktop "${pkgdir}/usr/share/applications/nvim.desktop"
    sudo install -Dm644 runtime/nvim.png "${pkgdir}/usr/share/pixmaps/nvim.png"

    # Make Arch vim packages work
    sudo mkdir -p "${pkgdir}"/etc/xdg/nvim
    echo "\" This line makes pacman-installed global Arch Linux vim packages work." >"${pkgdir}"/etc/xdg/nvim/sysinit.vim
    sudo echo "source /usr/share/nvim/archlinux.vim" >>"${pkgdir}"/etc/xdg/nvim/sysinit.vim

    mkdir -p "${pkgdir}"/usr/share/vim
    sudo echo "set runtimepath+=/usr/share/vim/vimfiles" >"${pkgdir}"/usr/share/nvim/archlinux.vim
  )
  ;;
esac
msg_not "${BLUE}${BOLD}" "[RIMP]==> Diff ranger config with default? [y/N/q]"
read -r yn
case $yn in
[Qq]*) quit ;;
[Yy]*)
  nvim -d /usr/share/doc/ranger/config/rc.conf \
    "$XDG_CONFIG_HOME/ranger/rc.conf"
  ;;
esac
msg_not "${BLUE}${BOLD}" "[RIMP]==> Diff i3 config with default? [y/N/q]"
read -r yn
case $yn in
[Qq]*) quit ;;
[Yy]*)
  nvim -d /etc/i3/config \
    "$XDG_CONFIG_HOME/i3/config"
  ;;
esac
msg_not "${BLUE}${BOLD}" "[RIMP]==> Diff picom config with default? [y/N/q]"
read -r yn
case $yn in
[Qq]*) quit ;;
[Yy]*)
  nvim -d /etc/xdg/picom.conf \
    "$XDG_CONFIG_HOME/picom.conf"
  ;;
esac
msg_not "${BLUE}${BOLD}" "[RIMP]==> Diff kitty config with default? [y/N/q]"
read -r yn
case $yn in
[Qq]*) quit ;;
[Yy]*)
  curl -fsSL \
    https://sw.kovidgoyal.net/kitty/_downloads/433dadebd0bf504f8b008985378086ce/kitty.conf \
    >/tmp/kitty.conf
  nvim -d /tmp/kitty.conf \
    "$XDG_CONFIG_HOME/kitty/kitty.conf"
  ;;
esac
msg_not "${BLUE}${BOLD}" "[RIMP]==> Diff dunst config with default? [y/N/q]"
read -r yn
case $yn in
[Qq]*) quit ;;
[Yy]*)
  nvim -d /etc/dunst/dunstrc \
    "$XDG_CONFIG_HOME/dunst/dunstrc"
  ;;
esac
msg_not "${BLUE}${BOLD}" "[RIMP]==> Update pandoc extras? [y/N/q]"
read -r yn
case $yn in
[Qq]*) quit ;;
[Yy]*) update_pandoc_bin ;;
esac
msg_not "${BLUE}${BOLD}" "[RIMP]==> Manually update the firefox userjs: ~/.mozilla/firefox/<profile>"
read -n1 -r key

quit
