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
  msg_error "==> Something went wrong...     "
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

patch_firefox_omni() {
  (
    patchfile="$HOME/.config/dotfiles/mozilla/firefox-omni.patch"
    # /home/reinaldo/.config/dotfiles/mozilla/firefox-omni.patch
    if [[ ! -f $patchfile ]]; then
      echo "Patch file not found"
      return
    fi
    echo $patchfile
    omni=/usr/lib/firefox/browser/omni.ja

    # setopt -o err_exit
    # setopt -o xtrace

    [[ -d /tmp/firefox-omni ]] && rm -rf /tmp/firefox-omni
    mkdir /tmp/firefox-omni
    cd /tmp/firefox-omni
    unzip -q $omni || true

    patch chrome/browser/content/browser/browser.xhtml $patchfile

    zip -0DXqr /tmp/omni.ja *

    sudo cp -v $omni $omni.orig
    sudo cp -v /tmp/omni.ja $omni

    rm -rf /tmp/omni.ja /tmp/firefox-omni
    rm -rf ~/.cache/mozilla/firefox/*/startupCache
  )
}

update_machine_learning() {
  # This is all that is needed to have a neat self contained environment
  # All needed is to activate the environment: source bin/activate
  # jupyter notebook <x>
  amd=$(lspci | grep 'VGA')
  $aur_helper -Syu --needed --noconfirm python38

  if [[ $amd != *"AMD"* ]]; then
    $aur_helper -Syu --needed --noconfirm \
      nvidia opencl-nvidia cuda \
      ncurses5-compat-libs cudnn
  fi

  python3.8 -m ensurepip --upgrade
  local venv_loc="$XDG_DATA_HOME/pyvenv"
  local venv_name="machine_learning"
  local pkgs=(
    turicreate jupyter_ascending matplot
  )

  mkdir -p "$venv_loc"
  python3.8 -m venv "$venv_loc/$venv_name" \
    --symlinks --clear
  source "$venv_loc/$venv_name/bin/activate"
  pip3.8 install --upgrade "${pkgs[@]}"
  if [[ $amd != *"AMD"* ]]; then
    pip3.8 uninstall -y tensorflow
    pip3.8 install tensorflow-gpu pycuda
  fi
  jupyter nbextension install jupyter_ascending --user --py
  jupyter nbextension enable jupyter_ascending --user --py
  jupyter serverextension enable jupyter_ascending --user --py
  deactivate
}

update_polybar_python_venv() {
  local venv_loc="$XDG_DATA_HOME/pyvenv"
  local venv_name="polybar"
  local pkgs=(
    requests jinja2 stravalib matplot
    i3ipc pandas plotly plotly_resampler kaleido pip
  )

  mkdir -p "$venv_loc"
  python -m venv "$venv_loc/$venv_name" \
    --symlinks --clear
  source "$venv_loc/$venv_name/bin/activate"
  pip3 install --upgrade "${pkgs[@]}"
  deactivate

  # Download github file with curl
  mkdir -p $HOME/.local/bin
  curl -fsSL https://raw.githubusercontent.com/dflock/kitty-save-session/main/kitty-convert-dump.py >$HOME/.local/bin/kitty-save-session.py
}

update_pymodules() {
  local venv_loc="$XDG_DATA_HOME/pyvenv"
  local venv_name="pydev"
  local pkgs=(
    mypy debugpy black selenium
    autopep8 pylint pylama isort pip
  )

  pip3 install --ignore-installed --upgrade "${pkgs[@]}"
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
  local base="${XDG_CONFIG_HOME:=$HOME/.config}/dotfiles/pkg/$(hostname)"
  mkdir -p "$base"
  local PACMANFILE="$base/pacman-list.pkg"
  local AURFILE="$base/aur-list.pkg"
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

lightdm_fix_xs_errors() {
  # Pending: https://github.com/canonical/lightdm/issues/95#issuecomment-1139517222
  if ! strings /usr/sbin/lightdm | grep -q '.xsession-errors'; then
    return
  fi

  if [[ ! -f bbe ]]; then
    return
  fi

  sudo cp -f /usr/sbin/lightdm{,_bkp}
  bbe -e 's/.xsession-errors/.cache\x2Fxs-errors/' /usr/sbin/lightdm_bkp >/tmp/outfile
  chmod +x /tmp/outfile
  sudo mv /tmp/outfile /usr/sbin/lightdm
}

docker_update() {

  msg_not "${BLUE}${BOLD}" "[RIMP]==> Update all docker images? [y/N/q]"
  read -r yn
  case $yn in
    [Yy]*)
      # Simpler approach - just pull all images currently used by containers:
      docker ps --format "table {{.Image}}" | grep -v IMAGE | sort -u | xargs -L1 docker pull

      # Then manually recreate containers, or use this one-liner to restart all:
      docker restart $(docker ps -q)
      ;;
    [Qq]*) quit ;;
  esac
}

pac_update_install() {
  # Always update keyring first in case it's been a while you've updated the
  # system
  # This is not a good practice. Leaving it here for reference
  # msg "${CYAN}${BOLD}==> Updating keyring...   "
  # sudo pacman-key --refresh-keys
  # $aur_helper -Sy --needed archlinux-keyring ca-certificates
  msg_not "${CYAN}${BOLD}" "[RIMP]==> Updating core and aur packages...     "
  $aur_helper -Syu "$@"

  msg "${CYAN}${BOLD}" "[RIMP]==> Storing package list...     "
  save_pkg_list_to_dotfiles
}

cleanup_junk() {

  msg "${CYAN}${BOLD}" "[RIMP]==> Clean up pacman's server's cache...     "
  read -r yn
  case $yn in
  [Qq]*) quit ;;
  [Yy]*)
    sudo paccache --remove -vvv \
      --cachedir=/mnt/apex-vault/apps/pacman/x86_64
    # Remove cache for deleted packages
    # Omit for now, otherwise we are constantly downloading removed files
    # sudo paccache -ruk0
    ;;
  esac
  msg "${CYAN}${BOLD}" "[RIMP]==> Clean up pacman's local cache...     "
  read -r yn
  case $yn in
  [Qq]*) quit ;;
  [Yy]*)
    # Leave only the 3 most recent versions of packaages
    sudo paccache -r -vvv \
      --cachedir=/var/cache/pacman/pkg
    # Remove cache for deleted packages
    sudo paccache -ruk0 \
      --cachedir=/var/cache/pacman/pkg
    ;;
  esac
  msg "${CYAN}${BOLD}" "[RIMP]==> Prune unused Docker objects...     "
  read -r yn
  case $yn in
  [Qq]*) quit ;;
  [Yy]*)
    docker volume prune --filter "label!=keep"
    docker system prune --filter "until=720h"
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
    msg "${CYAN}${BOLD}" "[RIMP]==> Cleaning trash folder...  "
    gio trash --empty
    # Restore pywal cache files
    msg "${CYAN}${BOLD}" "[RIMP]==> Restore pywal cache files...  "
    # Remove forced mode, just in case
    "$XDG_CONFIG_HOME/polybar/scripts/flux_/flux" -v -c \
      "$XDG_CONFIG_HOME/polybar/scripts/flux_/flux_config.lua" -r
    # Force generation of night mode
    "$XDG_CONFIG_HOME/polybar/scripts/flux_/flux" -v -c \
      "$XDG_CONFIG_HOME/polybar/scripts/flux_/flux_config.lua" -f night
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
}

cleanup_nix() {
  msg "${CYAN}${BOLD}" "[RIMP]==> Clean up nix store...     "
  read -r yn
  case $yn in
  [Qq]*) quit ;;
  [Yy]*)
    make -C ~/.config/dotfiles/nix clean
    ;;
  esac
  msg "${CYAN}${BOLD}" "[RIMP]==> Deep Clean up nix store...     "
  read -r yn
  case $yn in
  [Qq]*) quit ;;
  [Yy]*)
    make -C ~/.config/dotfiles/nix deep-clean
    ;;
  esac
}

print_errors() {
  msg_not "${CYAN}${BOLD}" "[RIMP]==> Checking for failed services...     "
  systemctl --failed
  read -n1 -r key

  msg_not "${CYAN}${BOLD}" "[RIMP]==> Looking for errors in journalctl...     "
  journalctl -p 3 -xb
  read -n1 -r key
}

update_npm() {
  if [[ -f npm ]]; then
    npm cache verify
    npm update -g
  fi
}

diff_new_configs() {
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
}

update_python_venv() {
  msg_not "${BLUE}${BOLD}" "[RIMP]==> Update python polybar env? [y/N/q]"
  read -r yn
  case $yn in
  [Qq]*) quit ;;
  [Yy]*) update_polybar_python_venv ;;
  esac
  msg_not "${BLUE}${BOLD}" "[RIMP]==> Update python local modules? [y/N/q]"
  read -r yn
  case $yn in
  [Qq]*) quit ;;
  [Yy]*) update_pymodules ;;
  esac
  msg_not "${BLUE}${BOLD}" "[RIMP]==> Update machine learning pyvenv? [y/N/q]"
  read -r yn
  case $yn in
  [Qq]*) quit ;;
  [Yy]*) update_machine_learning ;;
  esac
}

update_servers() {
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
}

pac_maintenance() {
  # msg "${CYAN}${BOLD}" "[RIMP]==> Printing state of all packages to /tmp/pac.log ...     "
  # "$aur_helper" -Qkk /tmp/pac.log 2>&1
  # nvim /tmp/pac.log

  msg "${CYAN}${BOLD}" "[RIMP]==> Checking for .pacnew files...     "
  if [[ $(pacdiff -o) ]]; then
    msg_not "${CYAN}${BOLD}" "[RIMP]==> Please address .pacnew files...     "
    sudo DIFFPROG="nvim -d" DIFFSEARCHPATH="/boot /etc /usr" pacdiff
  fi

  if [[ -f ancient-packages ]] && [[ $(ancient-packages -q) ]]; then
    ancient-packages
    msg_not "${CYAN}${BOLD}" "[RIMP]==> Remove ancient packages? [y/N/q]"
    read -r yn
    case $yn in
    [Qq]*) quit ;;
    [Yy]*) $aur_helper -Rscn "$(ancient-packages -q)" ;;
    esac
  fi

  msg "${CYAN}${BOLD}" "[RIMP]==> Checking for orphan packages...     "
  if [[ $(pacman -Qtdq) ]]; then
    msg_not "${CYAN}${BOLD}" "[RIMP]==> Please clean orphan packages...     "
    sudo pacman -Qtdq | sudo pacman -Rns - || echo "...  Or not..."
  fi

  if [[ -f fwupdmgr ]]; then
    msg "${CYAN}${BOLD}" "[RIMP]==> Update firmware?...     "
    sudo fwupdmgr get-updates || echo "...  Or not..."
    sudo fwupdmgr update || echo "...  Or not..."
  else
    msg_not "${CYAN}${BOLD}" "[RIMP]==> Consider installing fwupdmgr?...     "
  fi
}

update_polybar_scripts() {
  msg_not "${BLUE}${BOLD}" "[RIMP]==> Update polybar scripts? [y/N/q]"
  read -r yn
  case $yn in
  [Yy]*)
    local loc="$HOME"/.config/polybar/scripts/
    curl -fsSL \
      https://raw.githubusercontent.com/unode/polypomo/master/polypomo \
      >"$loc"/polypomo
    chmod +x "$loc"/polypomo
    ;;
  [Qq]*) quit ;;
  esac
}

backup() {
  msg_not "${BLUE}${BOLD}" "[RIMP]==> Back up important folders? [y/N/q]"
  read -r yn
  case $yn in
  [Yy]*)
    # Backup pacman's local database
    # More info here:
    # https://wiki.archlinux.org/index.php/Pacman/Restore_local_database
    "$TERMINAL" \
      "$XDG_CONFIG_HOME/dotfiles/scripts/nix/rsync/restic-backup" &
    ;;
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
  msg_not "${BLUE}${BOLD}" "[RIMP]==> Back up anki? [y/N/q]"
  read -r yn
  case $yn in
  [Qq]*) quit ;;
  [Yy]*)
    "$TERMINAL" \
      "$XDG_CONFIG_HOME/dotfiles/scripts/nix/rsync/restic-anki.sh" &
    ;;
  esac
  msg_not "${BLUE}${BOLD}" "[RIMP]==> Back up emails? [y/N/q]"
  read -r yn
  case $yn in
  [Qq]*) quit ;;
  [Yy]*)
    "$TERMINAL" \
      "$XDG_CONFIG_HOME/dotfiles/scripts/nix/rsync/restic-mail.sh" &
    ;;
  esac
}

update_nix() {
  msg_not "${BLUE}${BOLD}" "[RIMP]==> Update nix? [y/N/q]"
  read -r yn
  case $yn in
  [Qq]*) quit ;;
  [Yy]*)
    make -C ~/.config/dotfiles/nix upgrade-home
    ;;
  esac
}

update_neovim() {
  "$TERMINAL" \
    "$XDG_CONFIG_HOME/dotfiles/scripts/nix/installs/arch/coding/neovim.sh" &
}

setup_colors

# Source: https://www.redhat.com/sysadmin/arguments-options-bash-scripts
help() {
  # Display Help
  echo "Set of General Maintnance tasks for Arch"
  echo
  echo "All options are optional"
  echo "If no options are provided all tasks will run optionally"
  echo
  echo "Syntax: update-arch [-i|b|s|c|p|d|v|n|y|f|h|x]"
  echo "options:"
  echo "i     Install a package"
  echo "b     Run only Backup tasks"
  echo "c     Clean up tasks"
  echo "u     Pacman Udpate"
  echo "m     Maintnance tasks"
  echo "s     Update servers"
  echo "p     Update python virtual environments"
  echo "d     Diff configs with new /etc configs"
  echo "n     Update npm packages"
  echo "v     Update neovim"
  echo "y     Update polybar scripts"
  echo "f     Patch firefox keymaps"
  echo "x     Update nix"
  echo "h     Print this Help."
  echo
}

# Get the options
while getopts "i:ubcpdmvyfhnx" option; do
  case $option in
  h) # display Help
    help
    exit
    ;;
  i)
    pac_update_install "${@:2}"
    exit 0
    ;;
  b)
    backup
    exit 0
    ;;
  u)
    pac_update_install
    exit 0
    ;;
  m)
    pac_maintenance
    exit 0
    ;;
  c)
    cleanup_junk
    exit 0
    ;;
  p)
    update_python_venv
    exit 0
    ;;
  y)
    update_polybar_scripts
    exit 0
    ;;
  d)
    diff_new_configs
    exit 0
    ;;
  n)
    update_npm
    exit 0
    ;;
  f)
    patch_firefox_omni
    exit 0
    ;;
  v)
    update_neovim
    exit 0
    ;;
  x)
    update_nix
    exit 0
    ;;
  \?) # Invalid option
    echo "Error: Invalid option"
    echo
    help
    exit
    ;;
  esac
done

msg "${CYAN}${BOLD}" "========== Welcome! To the Arch Maintnance Script! 💪😎  =========="
# Backups first, since most likely they'll be kernel update and that messes up
# everything
backup

pac_update_install

docker_update

pac_maintenance

print_errors

update_servers

cleanup_junk

update_python_venv

update_polybar_scripts

msg_not "${BLUE}${BOLD}" "[RIMP]==> Patch Firefox Default Mappings? [y/N/q]"
read -r yn
case $yn in
[Qq]*) quit ;;
[Yy]*) patch_firefox_omni ;;
esac

msg_not "${BLUE}${BOLD}" "[RIMP]==> Update all rustup packages? [y/N/q]"
read -r yn
case $yn in
[Qq]*) quit ;;
[Yy]*)
  rustup update
  ;;
esac
msg_not "${BLUE}${BOLD}" "[RIMP]==> Update all npm global packages (md2apkg)? [y/N/q]"
read -r yn
case $yn in
[Qq]*) quit ;;
[Yy]*)
  update_npm
  ;;
esac
msg_not "${BLUE}${BOLD}" "[RIMP]==> Update neovim binary? [y/N/q]"
read -r yn
case $yn in
[Qq]*) quit ;;
[Yy]*)
  update_neovim
  ;;
esac

diff_new_configs

msg_not "${BLUE}${BOLD}" "[RIMP]==> Update pandoc extras? [y/N/q]"
read -r yn
case $yn in
[Qq]*) quit ;;
[Yy]*) update_pandoc_bin ;;
esac
msg_not "${BLUE}${BOLD}" "[RIMP]==> Manually update the firefox userjs: ~/.mozilla/firefox/<profile>"
read -n1 -r key

quit
