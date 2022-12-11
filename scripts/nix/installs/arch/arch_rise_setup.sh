# Basics

# You could start here:
# https://github.com/ahmedelhori/install-arch

# Add your user {{{
# useradd -m -g users -G wheel,storage,power,sys -s /bin/bash <USERNAME>
useradd -m -g users -G wheel,storage,power,sys -s /bin/bash reinaldo
# }}}

# Set user passwd {{{
# passwd <USERNAME>
passwd reinaldo
# Set passwd for root
passwd
# }}}

# Allow user to execute sudo commands {{{
EDITOR=nvim visudo
# Search for wheel and uncomment that line
# And underneath add the following:
Defaults rootpw
# This way you only need to enter your pw once per session
# `Defaults:<username> timestamp_timeout=-1`
Defaults:reinaldo timestamp_timeout=7200
# }}}

## 3. Network{{{
# Fix dhcpcd slow startup
# https://wiki.archlinux.org/title/dhcpcd#dhcpcd@.service_causes_slow_startup
sudo mkdir -p /etc/systemd/system/dhcpcd@.service.d
sudo bash -c 'cat > /etc/systemd/system/dhcpcd@.service.d/no-wait.conf' << EOL
[Service]
ExecStart=
ExecStart=/usr/bin/dhcpcd -b -q %I
EOL

# Run this section as root, not using sudo
interface="wlp1s0"
su
ip link
ip link set up dev $interface
dmesg | grep iwlwifi
ip link show $interface
wpa_supplicant -B -i $interface -c <(wpa_passphrase "<SID>" "<passwd>")
dhcpcd $interface
# NOTE: Once this works proceed to create the config files and enable 
# wpa_supplicant and dhcpcd 
# NOTE: Substitute <wlp1s0> with your interface from ip link show
sudo bash -c 'wpa_passphrase "05238_5GHz" "<password>" > /etc/wpa_supplicant/wpa_supplicant-wlan0.conf'
# Delete commented password sudo nvim /etc/wpa_supplicant/wpa_supplicant-wlp1s0.conf

sudo bash -c 'cat >> /etc/wpa_supplicant/wpa_supplicant-${interface}.conf' << EOL
# Giving configuration update rights to wpa_cli
ctrl_interface=/run/wpa_supplicant
ctrl_interface_group=wheel
update_config=1

# AP scanning
ap_scan=1

# ISO/IEC alpha2 country code in which the device is operating
country=US

# auto-connect to any unsecured network as a fallback with the lowest priority:
network={
  key_mgmt=NONE
  priority=-999
}
EOL
# - Check the connection:
# - `iw dev <interface> link`
# - Obtain ip address:
sudo systemctl enable --now wpa_supplicant@$interface 
sudo systemctl status wpa_supplicant@$interface 
sudo systemctl enable --now dhcpcd@$interface 
sudo systemctl status dhcpcd@$interface 
sudo systemctl restart dhcpcd@$interface 

# Setup wpa_supplicant to wait for dbus to shutdown
# This is a long story complicated bug
# When you mount NAS stuff through fstab shutdown is halted for a long time 
# waiting to unmount NAS mounts
# The problem is that there's a dbus bug that causes it to shutdown too early: 
# https://bugs.launchpad.net/ubuntu/+source/dbus/+bug/1438612
# It's related to network manager which, but switching network manager is not 
# sane
# The solution is detailed here:
# https://wiki.archlinux.org/index.php/Wpa_supplicant
# There's a section about Problems with mounted network shares:
sudo mkdir -p /etc/systemd/system/wpa_supplicant.service.d
sudo bash -c \
  'printf "[Unit]" >> /etc/systemd/system/wpa_supplicant.service.d/override.conf'
sudo bash -c \
  'printf "\nAfter=dbus.service" >> /etc/systemd/system/wpa_supplicant.service.d/override.conf'
#}}}

# Copy your `mirrorlist`:
scp /etc/pacman.d/mirrorlist reinaldo@192.168.1.194:/home/reinaldo/mirrorlist
sudo mv /etc/pacman.d/mirrorlist{,.bak}
sudo mv /home/reinaldo/mirrorlist /etc/pacman.d/mirrorlist

# install `paru`{{{
# From this point on you need to login as your user
# You should not run `paru` or `makepkg` as `root`
pacman -S --needed git
# cd /tmp
# git clone https://aur.archlinux.org/trizen.git --depth 1
# cd trizen
# makepkg -si
git clone https://aur.archlinux.org/paru-bin.git --depth 1 /tmp/paru
cd /tmp/paru
makepkg -si
#}}}

# install dotfiles{{{
# Download dotfiles
mkdir -p ~/.{config,cache}
mkdir -p ~/Documents
mkdir -p ~/.local/share/Trash/files
cd ~/.config
git clone https://github.com/tricktux/dotfiles
# NOTE: Change link to: ssh://github/tricktux/dotfiles
nvim "$HOME/.config/dotfiles/.git/config"
# Install needed software
paru -S stow
# So that you don't loose the hostname command
paru -S inetutils
# Backup current setup
# Make sure no other dotfiles are left
mv ~/.bash_logout{,_bak}
mv ~/.bash_profile{,_bak}
mv ~/.bashrc{,_bak}
# mv ~/.config/paru{,_}
# Install your configs
cd ~/.config/dotfiles
stow -t /home/reinaldo -S defaults 
# Check that all went well
ls -als ~/ 
ls -als ~/.config
# Get your aliases
source ~/.bash_aliases 
# Pass nvim config to root user as well to make `sudo nvim` usable
sudo mkdir -p /root/.config
sudo ln -s /home/reinaldo/.config/nvim /root/.config
#}}}

# fix time:{{{
paci ntp
sudo timedatectl set-ntp true
#}}}

# Install old packages: {{{
# NOTE: Go to `sudo vim /etc/pacman.conf` and uncomment `multilib`
sudo nvim /etc/pacman.conf
sudo pacman-key --refresh-keys
sudo pacman -Sy archlinux-keyring && sudo pacman -Su
sudo pacman -S --needed - < ~/.config/dotfiles/pkg/surbook/pacman-list.pkg
paru -S --needed - < ~/.config/dotfiles/pkg/surbook/aur-list.pkg
# }}}

# ccache to speed up compilations
paci --needed --noconfirm ccache

# Beautiful arch wallpapers
paci --needed --noconfirm archlinux-wallpaper
# TODO
# optional dependency
# wallutils: support the simple timed wallpaper format

# `arch-audit`
paci --needed --noconfirm arch-audit
# - Enable the `pacman` hook to auto check for vulnerabilities
# - Not needed anymore:
# - `sudo cp /usr/share/arch-audit/arch-audit.hook /etc/pacman.d/hooks`

# pacman helpers{{{
# Thu Apr 08 2021 14:43: NOTE: Don't do this anymore
paci --needed --noconfirm informant 
paci --needed --noconfirm ancient-packages
  informant 
# NOTE: Add yourself to group "informant" to avoid the need for sudo
sudo gpasswd -a reinaldo informant
# List recent news
sudo informant list
# Mark them as read
sudo informant read --all
#}}}

# `ssh`
paci --needed --noconfirm openssh mosh
# - Actually use `mosh` is much faster
# - If you want this setup to be `ssh` accessible:
# - `systemctl enable sshd.socket`
# - `systemctl enable sshd`
# - Add to `.ssh/config`
# - `AddKeysToAgent yes`

# install polkit {{{
paci --needed --noconfirm lxqt-policykit
# }}}

# zsh{{{
paci --needed --noconfirm zsh
# Legacy
# Install plugins
paci --needed --noconfirm pkgfile z-git \
  zsh-theme-powerlevel10k zsh-autosuggestions \
  zsh-history-substring-search zsh-syntax-highlighting \
  zsh-completions zsh-vi-mode
chsh -s /usr/bin/zsh
export ZDOTDIR=$HOME/.config/zsh
zsh

# pkgfile needs to be updated
sudo systemctl enable pkgfile-update.timer
# By default it runs daily
# Update /usr/lib/systemd/system/pkgfile-update.timer to run weekly
# Also update it to wait for network by adding to [Unit]
# Wants=network-online.target
# After=network-online.target nss-lookup.target
sudo nvim /usr/lib/systemd/system/pkgfile-update.timer
sudo systemctl start pkgfile-update.service
# symlink all the `zsh*` files
#}}}

# Update arch mirrors {{{
paci --needed --noconfirm reflector
sudo mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist_king
# Put options in config file
sudo bash -c 'printf "\n--latest 30" >> /etc/xdg/reflector/reflector.conf'
sudo bash -c 'printf "\n--number 5" >> /etc/xdg/reflector/reflector.conf'
sudo bash -c 'printf "\n--sort rate" >> /etc/xdg/reflector/reflector.conf'
sudo bash -c 'printf "\n--country \"United States\"" >> /etc/xdg/reflector/reflector.conf'
sudo bash -c 'printf "\n--verbose" >> /etc/xdg/reflector/reflector.conf'
sudo nvim /etc/xdg/reflector/reflector.conf
sudo systemctl enable --now reflector.timer
sudo systemctl start reflector.timer
sudo systemctl status reflector.timer
sudo systemctl start reflector.service
# If service fails, ensure that root owns the file
sudo chown root:root /etc/pacman.d/mirrorlist
sudo chmod 644 /etc/pacman.d/mirrorlist
sudo systemctl status reflector.service
sudo reflector --country "United States" --latest 30 --number 5 \
  --sort rate --protocol https --save /etc/pacman.d/mirrorlist

#}}}

# Linux kernel{{{
# Tue Dec 29 2020 09:44
# Just stay with LTS please. When nvidia is involved is just painful
# Installing LTS
paci --needed --noconfirm linux-lts{,-headers} nvidia-lts
paci --needed --noconfirm linux-lts{,-headers}
# If you need to remove linux
pacu linux{,-headers} nvidia
# **NOTE: Otherwise you wont be able to boot**
# Update /boot/loader/entries/arch.conf
sudo nvim /boot/loader/entries/arch.conf
# Below for lts
# linux /vmlinuz-linux-lts
# initrd /initramfs-linux-lts.img
# Just remove the -lts for regular linux
#}}}

# Protects from running out of memory{{{
paci --needed --noconfirm earlyoom
sudo systemctl enable --now earlyoom
sudo systemctl status earlyoom
#}}}

# Video card{{{
lspci -k | grep -A 2 -i "VGA"
# If you happen to see 2 cards here, follow instructions at [this](https://wiki.archlinux.org/index.php/Optimus)
# Should be good
# With the predator you should also do:
# Go to `sudo vim /etc/pacman.conf` and uncomment `multilib` this allows you to
# Now that you are there also uncomment the Color option
# Also add the ParallelDownloads = 5 option
# Also uncomment Color option
# Also add ILoveCandy option
# Also add:
# CacheDir    = /home/reinaldo/.mnt/skywafer/NetBackup/pacman_cache/x86_64
# CacheDir    = /var/cache/pacman/pkg/
sudo nvim /etc/pacman.conf
sudo pacman -Sy
# install 32-bit programs
# Mon Sep 18 2017 22:46: Also dont forget to update and uncomment both lines, multilib and Include 
# **Nvidia drivers**
# [Instructions](https://wiki.archlinux.org/index.php/NVIDIA)
# ***LTS*** needed if you are running linux-lts
# NVIDIA {{{
paci --needed --noconfirm nvidia-lts
# Otherwise use this one....**DO NOT USE BOTH**
paci --needed --noconfirm nvidia
paci --needed --noconfirm nvidia-libgl lib32-nvidia-libgl lib32-nvidia-utils \
  nvidia-utils nvidia-settings nvtop
# ***Configure DRM*** It should allow for the kernel to control the card
# Don't do this. I though it caused problems with picom. Now not sure. Better be 
# safe than sorry
# sudo bash -c 'printf "options nvidia-drm modeset=1" > /etc/modprobe.d/nvidia-drm.conf'
# ***Configure Xorg***
# Don't worry it will auto backup /etc/X11/xorg.conf
sudo nvidia-xconfig
# Tue Dec 29 2020 05:35
# ***DKMS*** is only needed if you are running a custom version of the kernel
sudo pacman -S --needed --noconfirm nvidia-dkms
sudo pacman -S --needed --noconfirm nvidia-utils lib32-nvidia-utils \
  nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader
# **Intel drivers**
sudo pacman -S --needed --noconfirm lib32-mesa mesa vulkan-intel \
  lib32-vulkan-intel vulkan-icd-loader lib32-vulkan-icd-loader xf86-video-intel
# **Hybrid Card**
# If you have one:
paci --needed --noconfirm bumblebee mesa \
  lib32-{virtualgl,nvidia-utils,primus} primus
paci --needed --noconfirm bbswitch
# Add your user to the `bumblebee` group:
gpasswd -a <user> bumblebee
gpasswd -a reinaldo bumblebee
sudo systemctl enable --now bumblebeed
# manually turn on/off gpu
sudo tee /proc/acpi/bbswitch <<< {ON,OFF}
# checkout [this][1] link for hardware acceleration
#}}}

# hardware {{{
paci --needed --noconfirm fwupd
# }}}

# AMD
paci --needed --noconfirm lib32-mesa mesa
paci --needed --noconfirm xf86-video-amdgpu
paci --needed --noconfirm lib32-vulkan-radeon vulkan-radeon vulkan-mesa-layers
paci --needed --noconfirm lib32-libva-mesa-driver libva-mesa-driver \
  mesa-vdpau lib32-mesa-vdpau
paci --needed --noconfirm radeontop

#}}}

# terminal utils{{{
paci --needed --noconfirm acpi lm_sensors liquidprompt tldr
paci --needed --noconfirm {ttf,otf}-fira-{code,mono} {ttf,otf}-font-awesome-5 \
  nerd-fonts-inconsolata {ttf,otf}-cascadia-code
paci --needed --noconfirm ttf-inconsolata
paci --needed --noconfirm xorg-xfontsel gtk2fontsel
# Package doesn't exist anymore thumbnailer 
paci --needed --noconfirm atool ranger-git zip unzip w3m ffmpeg highlight libcaca python-pillow

paci --needed --noconfirm atuin direnv
# Either restore the local/share/atuin folder from the backups
# or
# Giving it the path to zhist file
# HISTFILE=/path/to/history/file atuin import zsh

# Not installing anymore: advcp 
paci --needed --noconfirm mediainfo odt2txt poppler w3m bat exa fzf fd \
  ripgrep tmux imagemagick ghostscript xclip

# Utility to lint aur packages, makepkg, PKGBUILD
paci --needed --noconfirm namcap

# Utility to easily handle systemctl
paci --needed --noconfirm chkservice

# Main languages
paci --needed --noconfirm go

# kitty
paci --needed --noconfirm kitty termite
cp "$HOME"/.config/kitty/{predator,"$(hostname)"}.conf
nvim "$HOME/.config/kitty/$(hostname).conf"
# Depends on rust
# Causes all kinds of problems
# paci page-git
#}}}
# Essentials

# resilio
# See `random.md resilio` section
# samba
# See `random.md samba-manual` section

# nfs/samba {{{
paci --needed --noconfirm nfs-utils
mkdir -p $HOME/.mnt/skynfs
mkdir -p $HOME/.mnt/skywafer/{home,music,shared,video}
sudo bash -c 'printf "\n//192.168.1.139/NetBackup /home/reinaldo/.mnt/skywafer/NetBackup cifs credentials=/etc/samba/credentials/share,workgroup=WORKGROUP,uid=1000,gid=985,nofail,x-systemd.device-timeout=10,noauto,x-systemd.automount,_netdev,vers=3.0 0 0" >> /etc/fstab'
sudo bash -c 'printf "\n//192.168.1.139/home /home/reinaldo/.mnt/skywafer/home cifs credentials=/etc/samba/credentials/share,workgroup=WORKGROUP,uid=1000,gid=985,nofail,x-systemd.device-timeout=10,noauto,x-systemd.automount,_netdev,vers=3.0 0 0" >> /etc/fstab'
sudo bash -c 'printf "\n//192.168.1.139/music /home/reinaldo/.mnt/skywafer/music cifs credentials=/etc/samba/credentials/share,workgroup=WORKGROUP,uid=1000,gid=985,nofail,x-systemd.device-timeout=10,noauto,x-systemd.automount,_netdev,vers=3.0 0 0" >> /etc/fstab'

# Try it with
sudo mount -v -t nfs 192.168.1.139:/volume1/backup /home/reinaldo/.mnt/skynfs \
  -o vers=3
mv ~/.gnupg{,_orig}
cp -r \
    /home/reinaldo/.mnt/skywafer/home/bkps/predator/latest/.{ssh,password-store,gnupg} \
    /home/reinaldo
cp -r \
    /home/reinaldo/.mnt/skywafer/home/bkps/predator/latest/doublecmd \
    /home/reinaldo/.config
sudo chown -R reinaldo: ~/.{ssh,password-store,gnupg}
chmod 700 ~/.ssh
chmod 600 -R ~/.ssh/*
chmod 644 -f ~/.ssh/*.pub ~/.ssh/authorized_keys ~/.ssh/known_hosts
chmod 700 -R ~/.password-store
chmod 700 -R ~/.gnupg

sudo mkdir -p /etc/samba/credentials
sudo nvim /etc/samba/credentials/share
# - format:
# - `username=X`
# - `password=Y`
# - Obscure the file:
sudo chown root:root /etc/samba/credentials/share
sudo chmod 700 /etc/samba/credentials/share
sudo chmod 600 /etc/samba/credentials/share

# This is now for the caching of `pacman` packages on the network
sudo nvim /etc/rsync
# All the content in this file should just be the password: nas/synology/skywafer/rsync
sudo chown root:root /etc/rsync
sudo chmod 700 /etc/rsync
sudo chmod 600 /etc/rsync

paci --needed --noconfirm cifs-utils
sudo mount -t cifs //192.168.1.139/home ~/.mnt/skywafer/home -o credentials=/etc/samba/credentials/share,workgroup=WORKGROUP,uid=1000,gid=985,nofail,x-systemd.device-timeout=10,noauto,x-systemd.automount,_netdev
mkdir -p ~/Documents
# ln -s ~/.mnt/skywafer/home/Drive/wiki ~/Documents
paci --needed --noconfirm synology-drive
#}}}

# VPN {{{

paci --needed --noconfirm riseup-vpn

# wireguard {{{
# Get conf file from router linux_pcs
# Put it at /etc/wireguard/wg0.conf
paci --needed --noconfirm wireguard-tools systemd-resolvconf
sudo systemctl enable --now systemd-resolved.service
# The value for this ip is given by the ip assigned to the peer
# You can find it in the config file
sudo bash -c 'echo "nameserver 10.4.0.7" >> /etc/resolv.conf'
sudo reboot
# Try it with:
sudo wg-quick up wg0
sudo wg-quick down wg0
sudo systemctl start wg-quick@wg0.service
sudo systemctl status wg-quick@wg0.service
sudo systemctl stop wg-quick@wg0.service
sudo chmod 700 /etc/wireguard/wg0.conf
sudo chmod 600 /etc/wireguard/wg0.conf
# }}}

# openvpn {{{
paci --needed --noconfirm openvpn
# Test it
sudo openvpn ~/Documents/Drive/wiki/misc/home.ovpn
sudo cp /home/reinaldo/Documents/Drive/wiki/misc/home.ovpn /etc/openvpn/client/home.conf
# Edit config and add pass.conf to the auth-user-pass line
sudo nvim /etc/openvpn/client/home.conf
# Then create the file
sudo nvim /etc/openvpn/client/pass.conf
# use meli openvpn account
# - format:
# - `<username>`
# - `<password>`
# - Obscure the file:
# https://bbs.archlinux.org/viewtopic.php?id=260900
sudo chown openvpn:openvpn /etc/openvpn/client/{home,pass}.conf
sudo chmod 700 /etc/openvpn/client/{home,pass}.conf
sudo chmod 600 /etc/openvpn/client/{home,pass}.conf
sudo systemctl start openvpn-client@home
sudo systemctl status openvpn-client@home
# }}}
# }}}

# password-store{{{
paci --needed --noconfirm --needed pass rofi-pass
## Passwords
# pass-import most likely you'll have to download from git page
gpg --recv-keys 06A26D531D56C42D66805049C5469996F0DF68EC
paci --needed --noconfirm python-pykeepass
paci --needed --noconfirm pass keepassxc pass-import pass-update
## Root passwd
# - ~~`install openssh-askpass`~~
# - Tue Mar 26 2019 08:53
paci --needed --noconfirm lxqt-openssh-askpass
# import key
# From a pc containing the keys:
# `gpg --armor --output mykey.asc --export-secret-key you@example.com`
# `gpg --armor --output mykey.asc --export-secret-key "Password Store Key"`
# `scp mykey.asc othermachine:`
# `scp mykey.asc othermachine:`
# From client machine:
# `gpg --import mykey.asc`
# `gpg --edit-key <Key ID> trust quit`
# `gpg --edit-key "Password Store Key" trust quit`
# choose the ultimate trust option
# save changes.
# `gpg -K` should list your imported key as trusted ultimate.
# create and copy ssh key
# See `random.md key-generation` section
# import repo
# See `git.md`
#}}}
# numlock on at boot

# Tue Mar 26 2019 21:49
# The rest is taken care of at `.xinitrc`
paci --needed --noconfirm numlockx

# Desktop

# screenshots, i3
# After this steps you should have a working `i3` setup.

# Network Manager{{{
paci --needed --noconfirm networkmanager network-manager-applet networkmanager-openvpn
pacu networkmanager network-manager-applet networkmanager-openvpn networkmanager-dmenu-git 
sudo systemctl enable --now NetworkManager.service
sudo systemctl status NetworkManager.service
#}}}

# i3-wm{{{
cp "$HOME"/.config/rofi/{predator,"$(hostname)"}.rasi
nvim "$HOME/.config/rofi/$(hostname).rasi"
# Action also update the xdotool script for the new hostname
nvim "$HOME/.config/i3/scripts/xdotool_launch"
paci --needed --noconfirm i3-gaps i3lock-fancy-git rofi rofi-dmenu alttab-git xdotool 
paci --needed --noconfirm feh redshift qrencode xclip dunst libnotify
paci --needed --noconfirm scrot flameshot
# Replacement for htop. Execute: btm
paci --needed --noconfirm bottom htop-vim-git
# Compton changed name to picom
paci --needed --noconfirm picom
paci --needed --noconfirm xss-lock
# mimeo to handle default applications
# keyword: xdg-open
paci --needed --noconfirm mimeo xdg-utils-mimeo
# determine a file's MIME type
$ mimeo -m photo.jpeg
photo.jpeg
  image/jpeg

# choose the default application for this MIME type
$ mimeo --add image/jpeg feh.desktop

# open a file with its default application
$ mimeo photo.jpeg
# Sample usage
# Deprecated
# `cbatticon `
# `paystray`
# `blueberry`
#}}}

# fonts {{{
sudo pacman -S "$(pacman -Ssq noto-fonts-\*)"
# }}}

# rofi extra goodies
paci --needed --noconfirm rofi-{emoji,bluetooth-git,file-browser-extended-git}
paci --needed --noconfirm noto-fonts-emoji

# synology nfs and backups
# paci --needed

# polybar{{{
# NOTE: For new hostnames you will to tweak polybar/config and 
# polybar/modules.ini
paci --needed --noconfirm jsoncpp polybar alsa-utils paprefs
paci --needed --noconfirm alsa-lib wireless_tools curl pacman-contrib
paci --needed --noconfirm ttf-weather-icons jq
paci --needed --noconfirm nerd-fonts-iosevka
paci --needed --noconfirm python-pywal galendae-git
wal --theme base16-google -l -q -o "$HOME/.config/polybar/launch.sh"
# usb automount
# There's a polybar module that will be used to mount/umount devices
paci --needed --noconfirm gvfs-mtp gvfs-gphoto2 udisks2 pcmanfm
sudo install -Dm644 /home/reinaldo/.config/polybar/scripts/95-usb.rules \
  /etc/udev/rules.d/95-usb.rules
#}}}

# xorg{{{
# Multi Monitor setup, or for HiDPI displays it's best to auto calculate 
# resolution
paci --needed --noconfirm xorg-xrandr arandr xlayoutdisplay
paci --needed --noconfirm xorg xorg-apps xorg-xinit xorg-drivers xorg-server
/usr/bin/xlayoutdisplay
# ACTION: Copy output and paste it there
nvim "$HOME/.config/xprofile-$(hostname)"
# ACTION: Now is also a good time to add that hostname there
nvim "$HOME/.config/i3/scripts/xrandr.sh"
# `xorg autologin`
paci --needed --noconfirm lightdm
sudo systemctl enable lightdm
#}}}

# add your user to the autologin group
sudo groupadd -r autologin
sudo gpasswd -a reinaldo autologin

# Create
# Valid session names under /usr/share/xsessions/*.desktop
sudo nvim /etc/lightdm/lightdm.conf

# [Seat:*]
# autologin-user=reinaldo
# autologin-session=i3-with-shmlog

# windows virtual machine {{{
# You can download images from: 
# https://developer.microsoft.com/en-us/windows/downloads/virtual-machines/
# **NOTE** host-modules-arch is for when you have a linux kernel installed.
paci --needed virtualbox{,-host-modules-arch}
# As opposed to any other kenerl, like lts, zen, etc... use the one below
paci --needed virtualbox{,-host-dkms}
sudo modprobe vboxdrv
sudo groupadd -r vboxdrv
sudo gpasswd -a reinaldo vboxdrv
# For USB access
sudo gpasswd -a reinaldo vboxusers
paru -Syu virtualbox-ext-oracle
# }}}

# dotnet {{{
paci --needed --noconfirm dotnet-runtime dotnet-sdk
# Installing other versions, first try the aur, if not there do the below
# Use the script: from https://dot.net/v1/dotnet-install.sh
# Use the --dry-run flag if you are not sure
sudo ./dotnet-install.sh --version "4.5xx" --install-dir "/usr/share/dotnet" --architecture "x64" --os "linux"
# }}}

# Benchmarking {{{
paci --needed --noconfirm hyperfine
# }}}

# Development environment {{{
paci --needed --noconfirm neovim cscope ripgrep ctags global xclip
paci --needed --noconfirm lazygit
# Cheatsheets
paci --needed --noconfirm cht.sh-git navi-bin
# Takes forever, rust compilation
paci --needed --noconfirm ripgrep-all
# for diffs
paci --needed --noconfirm meld
# markdown preview
paci --needed --noconfirm glow
# for documentation
paci --needed --noconfirm zeal
paci --needed --noconfirm pandoc-bin
# - run the `dotfiles/scripts/python_neovim_virtualenv.sh` script
# to get `/usr/share/dict` completion
paci --needed --noconfirm plantuml words

## vim
# Sun Jan 17 2021 07:07: Depracated. Install in the pynvim venv
# paci --needed --noconfirm vint


# doomemacs {{{
paci --needed --noconfirm emacs
# Ensure ~/.emacs* does not exists
# symlink <dotfiles>/doom to ~/.config/doom
git clone https://github.com/hlissner/doom-emacs ~/.config/emacs
~/.config/emacs/bin/doom install
# }}}

## cmake{{{
paci --needed --noconfirm cmake{,-lint,-format,-language-server}
# ~~`install cmake-language-server`~~
#}}}

## rust{{{
paci --needed --noconfirm rustup sccache rust-analyzer
rustup toolchain install stable
rustup component add rust-src rustfmt clippy
#}}}

## cpp{{{
paci --needed --noconfirm gtest google-glog rapidjson boost boost-libs websocketpp cmake ninja
paci --needed --noconfirm cppcheck cpplint
paci --needed --noconfirm lldb clang gdb gdb-dashboard-git
# For coloring gcc and compilers output
paci --needed --noconfirm colorgcc
#}}}

## shell{{{
paci --needed --noconfirm shellcheck-bin shfmt
#}}}

## lua{{{
## lua-language-server consumes ton of cpu power. Plus its chinese, don't trust 
## it
## Tue Jun 15 2021 11:21: Giving it another try
paci --needed --noconfirm luajit stylua luacheck lua-language-server-git
#}}}

## java{{{
# Installs java the latest and version 8, still widely used.
paci --needed --noconfirm j{re,re8,dk,dk8}-openjdk
# checkstyle out of date
paci --needed --noconfirm jdtls astyle
#}}}

## python{{{
paci --needed --noconfirm python{,-pip}

# Current python lsp is coded in npm now
paci --needed --noconfirm pyright
# Python modules are control via virtual env
# Run the update-arch.sh script and will create/update such modules
# install python-language-server flake8 python-pylint yapf --noconfirm
# pip install --user stravalib
#}}}

# SSD
paci --needed --noconfirm util-linux
sudo systemctl enable --now fstrim.timer

# Laptops

## Brightness
paci --needed --noconfirm brillo
# Add your user to the video group not to have to use sudo
sudo gpasswd -a reinaldo video
# see `man brillo`

## Touchpad 

paci --needed --noconfirm xorg-xinput xf86-input-libinput brillo
# Also see `synclient.md`

## power{{{
# keyword: battery, powertop, power
paci --needed --noconfirm powertop powerstat cpupower
# Set cpu governor based on laptop charging or not. Please run `cpupower 
# frequency-info` to display the governors your cpu supports
# Read here about cpu governors. Choosing schedutil for battery and performance 
# for charging
# https://forum.xda-developers.com/t/ref-guide-most-up-to-date-guide-on-cpu-governors-i-o-schedulers-and-more.3048957/
# **SET GOVERNOR** by adjusting /etc/laptop-mode/conf.d/cpufreq.conf
# The seeting for on AC is normally NOLM_AC_X, since laptop-mode is disabled in 
# If no LaptopMode set your governor at /etc/default/cpupower
# AC mode
cpupower frequency-info
sudo nvim /etc/laptop-mode/conf.d/cpufreq.conf
sudo powerstat -R -s
sudo powertop --calibrate
# For more info see: `archwiki powertop`
# See also `laptop-mode`
paci --needed --noconfirm acpid
sudo systemctl enable --now acpid
paci --needed --noconfirm laptop-mode-tools
sudo systemctl enable --now laptop-mode
paci --needed --noconfirm hdparm sdparm ethtool wireless_tools hal python-pyqt5
#}}}

### tweaking kernel for battery saving

# Sun Mar 17 2019 14:14 
# Taken from [here](https://wiki.archlinux.org/index.php/Power_management)

#### webcam

# blacklist it.
sudo sudo bash -c 'printf "blacklist uvcvideo" > /etc/modprobe.d/no_webcam.conf'

#### audio power save

# To check audio driver: `lspci -k`
# Sun Jun 06 2021 22:49: These cause trouble!
sudo sudo bash -c 'printf "options snd_had_intel power_save=1" > /etc/modprobe.d/audio.conf'
sudo sudo bash -c 'printf "options snd_had_intel probe_mask=1" > /etc/modprobe.d/audio.conf'
# Disable hdmi output
sudo sudo bash -c 'printf "blacklist snd_hda_codec_hdmi" > /etc/modprobe.d/no_hdmi_audio.conf'

#### wifi

# Add to /etc/modprobe.d/iwlwifi.conf
#options iwlwifi power_save=1 d0i3_disable=0 uapsd_disable=0
#options iwldvm force_cam=0

#### others

# use [this](https://github.com/Hjdskes/powersave) script
# examine the script as it disables bluetooth for example

# Make it pretty
# Dark mode, night
# NOTE: After installing xfce4-settings open the keyboard application and delete 
# all the xfce shortcuts, they interfere with i3, then reboot
paci --needed --noconfirm numix-gtk-theme paper-icon-theme \
  capitaine-cursors lxappearance adapta-gtk-theme paper-gtk-theme-git \
  xfce4-settings qt5-styleplugins bibata-extra-cursor-theme
# Also modify all these files:
nvim ~/.gtkrc-2.0
# gtk-cursor-theme-name="Bibata-Modern-DarkRed"
mkdir ~/.icons/default
nvim ~/.icons/default/index.theme
# [icon theme] 
# Inherits=Bibata-Modern-DarkRed
nvim ~/.config/gtk-3.0/settings.ini
# gtk-cursor-theme-name="Bibata-Modern-DarkRed"

paci --needed --noconfirm papirus-icon-theme
# And then just go to `Customize Look and Feel` 

# Task Manager

paci --needed --noconfirm glances
# ~~`install lxtask stacer-bin glances`~~

# Audio/Music{{{

paci --needed --noconfirm cmus playerctl pipewire
paci --needed --noconfirm pamixer alsa-lib libao libcdio libcddb libvorbis \
  libmpcdec wavpack libmad libmodplug libmikmod pavucontrol
# mpv-mpris is a plugin that adds mpris support to mpv. This allows playerctl to 
# control it
paci --needed --noconfirm mpv mpv-mpris

# Download music
paci --needed --noconfirm python-spotdl

paci --needed --noconfirm spotify
# Spotify theme
paci --needed --noconfirm spicetify-{cli,themes-git}
# https://github.com/morpheusthewhite/spicetify-themes/tree/master/Dribbblish
# Steps to set the theme
cd /usr/share/spicetify-cli/Themes/Dribbblish
# cp dribbblish.js ../../Extensions
spicetify config extensions dribbblish.js
spicetify config current_theme Dribbblish color_scheme base
spicetify config inject_css 1 replace_colors 1 overwrite_assets 1
# https://github.com/khanhas/spicetify-cli/wiki/Installation#spotify-installed-from-aur
sudo chmod a+wr /opt/spotify
sudo chmod a+wr /opt/spotify/Apps -R
# spicetify config color_scheme dracula2
spicetify config color_scheme beach-sunset
spicetify backup
spicetify apply

# Tue Mar 12 2019 07:24
# Gearing towards `mpd`
# Mainly because `cmus` is not working properly in `helios`
# Gonna give it a try
# Fri Jan 29 2021 16:20: !Deprecated!
# paci --needed --noconfirm mpd vimpc-git

#}}}

# email {{{
# neomutt {{{
paci --needed --noconfirm neomutt abook urlscan lynx \
  isync goimapnotify
# Needed to backup emails
# paci --needed --noconfirm offlineimap
mkdir -p ~/.local/share/mail/{molinamail,molinamail_meli,molinamail_mcp}/inbox
/usr/bin/mbsync -D -ac ~/.config/isync/mbsyncrc
#}}}

# evolution {{{
paci --needed --noconfirm evolution gnome-keyring libsecret
# ACTION: setup empty password so that `lightdm` can unlock the `keyring` at login
# Run through the normal setup and when the "Default Keyring" setup comes, just 
# leave empty
evolution
#}}}
# }}}

# calendar/contacts {{{
paci --needed vdirsyncer
mkdir -p ~/.local/share/vdirsyncer/{status,calendar,contacts}
sudo bash -c 'printf "pass show \"\$@\" | head -n 1" > /usr/lib/password-store/extensions/first-line.bash'
sudo chmod +x /usr/lib/password-store/extensions/first-line.bash
vdirsyncer discover {contacts,calendars}
vdirsyncer sync

# Calendar, contacts and todo applications that read from vdir
paci --needed khal khard todoman
# }}}


## Mon Mar 04 2019 22:03 

# I have decided to give `thunderbird` a try.
# Out of frustration for delayed received notifications in `neomutt`
# And wonky `ui`

paci --needed --noconfirm thunderbird birdtray

# Office

paci --needed --noconfirm libreoffice-still hunspell hunspell-en_us

# pdf & resume

paci --needed --noconfirm zathura zathura-pdf-mupdf texlive-most pdfgrep qpdfview
# PDF annotations use:
# Don't install depends on python2
paci --needed --noconfirm xournal
# PDF searching: `install pdfgrep`
# PDF Merging:
# Sat Mar 02 2019 21:18
# **Please do not use `pdftk`**
# You seriously have to compile gcc6 for that 
# pdftk
# pdftk file1.pdf file2.pdf cat output mergedfile.pdf

# windows mount

paci --needed --noconfirm ntfs-3g

## Then you can just do to mount the windows partition
# mount /dev/<your_device> /mnt/win

# android

paci --needed --noconfirm android-tools android-udev

# Bluetooth/Audio {{{
## Pipewire
paci --needed --noconfirm pipewire pipewire-{pulse,jack,alsa}
## PulseAudio
# paci --needed --noconfirm pulseaudio pulseaudio-{bluetooth,jack,alsa,equalizer}

#Blue
paci --needed --noconfirm bluez bluez-libs bluez-utils bluez-firmware
paci --needed --noconfirm blueman
sudo systemctl enable --now bluetooth

# Easyeffects or nice headphones sound
paru -Syu easyeffects lsp-plugins
# Download effects from: 
#   https://github.com/jaakkopasanen/AutoEq/tree/master/results
#   - Search for your headphones
#   - Download the parametrics.txt file
# Apply it to Easyeffects
#   - Click on the Effects button at the bottom
#   - Add an equalizer
#   - Click on Import Preset / Load AOP file
#   - Search for the txt file downloaded
# Start the application in the background:
#   - easyeffects --gapplication-service
# Ensure it's working:
#   - Open pavucontrol
#   - The sink for audio should be Easyeffects Sink
#}}}

# journal

# Tue Mar 26 2019 08:58
# Auto clean up
sudo nvim /etc/systemd/journald.conf
# Add or uncomment `SystemMaxUse=2G`

# Browser{{{

## firefox

paci --needed --noconfirm firefox
# paci --needed --noconfirm firefox-extension-privacybadger`
# paci --needed --noconfirm libnotify speech-dispatcher festival`
paci --needed --noconfirm vdhcoapp-bin
# Move profile to ram, for chrome and firefox
paci --needed --noconfirm profile-sync-daemon
sudo EDITOR=nvim visudo
# Add
# reinaldo ALL=(ALL) NOPASSWD: /usr/bin/psd-overlay-helper
systemctl --user enable --now psd
 # `Video Youtube donwloader extension helper app`
# - Extensions: `noscript, vimium-FF, duckduckgo`

### profiles

# - live at: `~/.mozilla/firefox/XXXXXX.<name>`
# - `firefox -P <name>`
# - `firefox -ProfileManager`

### extensions

# - Cookie AutoDelete
# - NoScript
# - Vimium
# - Disconnect
# - Privacy Badger

# Also I use `qutebrowser` for login website
paci --needed --noconfirm qutebrowser pdfjs

#}}}

# Printing{{{
# keywords: print, hp, cups
paci --noconfirm --needed hplip cups cups-pdf simple-scan gtk3-print-backends
# install most of the optional software that comes along with hplip
# Follow arch `cups` instructions.
# look it up in the arch wiki
sudo systemctl enable --now cups.socket
	# - Then go to the web server interface of cups. Sign in as root.
	# - There you can add printers. Set their default settings.
	# - And also you need to set the users that can have access to the printer.
# - **Note:** If printer doesnt show. Or google-chrome or opera do not print.
	# - You did not `install gtk3-print-backends`
# - **Note:** If you cannot authenticate ensure  your user is a member of the sys group.
# - You can check with: `groups reinaldo`. It should list the sys group.
# - https://wiki.archlinux.org/index.php/CUPS#ConfigurationYou can do this by: `sudo gpasswd -a <user> sys`.
# - Instructions [here](https://wiki.archlinux.org/index.php/CUPS#Configuration)
# - Cups server lives at: `http://localhost:631/`
#}}}

# Misc{{{
 
# anki {{{
# Official
paci --needed --noconfirm anki-official-binary-bundle

# Beta{{{
# https://betas.ankiweb.net/
cd ~/.local/share/pyvenv
python -m venv anki-beta
cd anki-beta
./bin/pip install --upgrade pip
./bin/pip install --upgrade --pre "aqt[qt6]"
./bin/anki
# }}}
# Markdown to anki converter
paci --needed --noconfirm npm
npm install -g md2apkg
#}}}

## 💲 Stonks {{{
paci --needed --noconfirm tickrs
#}}}

## gui mock ups design{{{
# - [here][0]
paci --needed --noconfirm pencil
#}}}

## check files duplicates{{{
# - Mon Jun 10 2019 09:59
paci --needed --noconfirm fdupes
#}}}

## Diagrams{{{
# - Sun Mar 17 2019 18:26
# - keyword: graphics, graph, editor
# - Mainly for stuff that `plantuml` cannot do
paci --needed --noconfirm yed
#}}}

## Preload{{{
# - Wed May 02 2018 06:04
# - Cool application.
paci --needed --noconfirm preload
# - Can be done as user level
sudo systemctl enable --now preload
#}}}

## Youtube-dl{{{
paci --needed --noconfirm youtube-dl ytmdl ytfzf
#}}}

## Screen recording{{{
# -  Application to record and share cools screen captures
paci --needed --noconfirm asciinema
#}}}

## Disk Usage Utility{{{
paci --needed --noconfirm baobab
#}}}

## Steam{{{
paci steam ttf-liberation steam-fonts
## IF AMD
paci xf86-video-amdgpu lib32-mesa mesa
# If NVIDIO
paci lib32-nvidia-utils nvidia-utils
#}}}

## Video playing{{{
paci --needed --noconfirm vlc
#}}}

## wine{{{
# Make sure WINEPREFIX exists
paci --needed --noconfirm wine wine-gecko winetricks wine-mono
paci --needed --noconfirm lib32-lib{pulse,xrandr}
paci --needed --noconfirm dxvk-bin
setup_dxvk install
# Temp directory on tmpfs
rm -r "$WINEPREFIX/drive_c/users/$USER/Temp"
ln -s /tmp/wintemp "$WINEPREFIX/drive_c/users/$USER/Temp"
# Fix fonts
cd ${WINEPREFIX:-~/.wine}/drive_c/windows/Fonts && for i in /usr/share/fonts/**/*.{ttf,otf}; do ln -s "$i" ; done
export FREETYPE_PROPERTIES="truetype:interpreter-version=35"
winetricks corefonts
winetricks settings fontsmooth=rgb
#}}}

## maintenence{{{
paci --needed --noconfirm bleachbit
#}}}

## Android{{{
paci --needed --noconfirm android-tools android-udev
#}}}

## Android-Dev{{{
paci --needed --noconfirm android-studio android-sdk
# - Remember: `~/.bashrc`->`export ANDROID_HOME=<sdk-location>`
#}}}

## syslog{{{
### Fri Oct 25 2019 14:35\
# - `paci --needed --noconfirm syslog-ng`
# - `sudo systemctl enable --now syslog-ng@default.service`
# - now when you log with `openlog()` and/or `syslog()` you can see it in `journalctl`}}}
#}}}

# [0]: https://pencil.evolus.vn/
# [1]: https://wiki.archlinux.org/index.php/Hardware_video_acceleration

# vim: fdm=marker
