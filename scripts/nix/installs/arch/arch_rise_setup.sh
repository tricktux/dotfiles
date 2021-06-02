# Basics

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
EDITOR=vim visudo
# Search for wheel and uncomment that line
# And underneath add the following:
Defaults rootpw
# This way you only need to enter your pw once per session
# `Defaults:<username> timestamp_timeout=-1`
Defaults:reinaldo timestamp_timeout=7200
# }}}

## 3. Network{{{
# Run this section as root, not using sudo
# su
# ip link`
# # ip link set <wlan0> up`
# dmesg | grep iwlwifi`
# ip link show <interface>`
# wpa_supplicant -B -i <interface> -c <(wpa_passphrase "your_SSID" "your_key")`
# NOTE: Substitute <wlp1s0> with your interface from ip link show
sudo bash -c 'wpa_passphrase "05238_5GHz" "<password>" > /etc/wpa_supplicant/wpa_supplicant-wlan0.conf'
# Delete commented password sudo nvim /etc/wpa_supplicant/wpa_supplicant-wlp1s0.conf

sudo bash -c 'cat >> /etc/wpa_supplicant/wpa_supplicant-wlan0.conf' << EOL
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
sudo systemctl enable --now wpa_supplicant@wlan0 
sudo systemctl status wpa_supplicant@wlan0 
sudo systemctl enable --now dhcpcd@wlan0 
sudo systemctl status dhcpcd@wlan0 
# - `dhcpcd <wlan0>`

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
paci --needed --noconfirm ancient-packages informant 
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

# zsh{{{
paci --needed --noconfirm zsh
# Legacy
# install oh-my-zsh-git zplug pkgfile
# Install zim
export ZIM_HOME=/home/reinaldo/.config/zsh/.zim
curl -kfLo $ZIM_HOME/zimfw.zsh --create-dirs \
  https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
chmod +x $ZIM_HOME/zimfw.zsh
zsh $ZIM_HOME/zimfw.zsh install
# Install plugins
paci --needed --noconfirm pkgfile
# pkgfile needs to be updated
sudo systemctl enable pkgfile-update.timer
# By default it runs daily
# Update /usr/lib/systemd/system/pkgfile-update.timer to run weekly
# Also update it to wait for network by adding to [Unit]
# Wants=network-online.target
# After=network-online.target nss-lookup.target
sudo vim /usr/lib/systemd/system/pkgfile-update.timer
sudo systemctl start pkgfile-update.service

chsh -s /usr/bin/zsh
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
sudo bash -c 'printf "\n--info" >> /etc/xdg/reflector/reflector.conf'
sudo systemctl enable --now reflector.timer
sudo systemctl start reflector.timer
sudo systemctl status reflector.timer
sudo systemctl start reflector.service
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
#}}}

# Video card{{{
lspci -k | grep -A 2 -i "VGA"
# If you happen to see 2 cards here, follow instructions at [this](https://wiki.archlinux.org/index.php/Optimus)
# Should be good
# With the predator you should also do:
# Go to `sudo vim /etc/pacman.conf` and uncomment `multilib` this allows you to
# Now that you are there also uncomment the Color option
# Also add the ParallelDownloads = 5 option
sudo vim /etc/pacman.conf
sudo pacman -Sy
# install 32-bit programs
# Mon Sep 18 2017 22:46: Also dont forget to update and uncomment both lines, multilib and Include 
# **Nvidia drivers**
# [Instructions](https://wiki.archlinux.org/index.php/NVIDIA)
# ***LTS*** needed if you are running linux-lts
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

# terminal utils{{{
paci --needed --noconfirm acpi lm_sensors liquidprompt tldr
paci --needed --noconfirm {ttf,otf}-fira-{code,mono} {ttf,otf}-font-awesome \
  nerd-fonts-inconsolata
paci --needed --noconfirm ttf-inconsolata
paci --needed --noconfirm xorg-xfontsel gtk2fontsel
# Package doesn't exist anymore thumbnailer 
paci --needed --noconfirm atool ranger zip unzip w3m ffmpeg highlight libcaca
# Not installing anymore: advcp 
paci --needed --noconfirm mediainfo odt2txt poppler w3m bat exa fzf fd \
  ripgrep tmux imagemagick ghostscript xclip

# Main languages
paci --needed --noconfirm rust go

# kitty
paci --needed --noconfirm kitty termite
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
sudo bash -c 'printf "192.168.1.138:/volume1/backup /home/reinaldo/.mnt/skynfs nfs _netdev,noauto,user,x-systemd.automount,x-systemd.mount-timeout=10,timeo=14,x-systemd.idle-timeout=1min,vers=3 0 0" >> /etc/fstab'
sudo bash -c 'printf "\n//192.168.1.138/home /home/reinaldo/.mnt/skywafer/home cifs credentials=/etc/samba/credentials/share,workgroup=WORKGROUP,uid=1000,gid=985,nofail,x-systemd.device-timeout=10,noauto,x-systemd.automount,_netdev 0 0" >> /etc/fstab'
sudo bash -c 'printf "\n//192.168.1.138/music /home/reinaldo/.mnt/skywafer/music cifs credentials=/etc/samba/credentials/share,workgroup=WORKGROUP,uid=1000,gid=985,nofail,x-systemd.device-timeout=10,noauto,x-systemd.automount,_netdev 0 0" >> /etc/fstab'

# Try it with
sudo mount -v -t nfs 192.168.1.138:/volume1/backup /home/reinaldo/.mnt/skynfs \
  -o vers=3
mv ~/.gnupg{,_orig}
sudo cp -r \
  /home/reinaldo/.mnt/skynfs/predator/latest/.{ssh,password-store,gnupg} \
  /home/reinaldo
sudo chown -R reinaldo: ~/.{ssh,password-store,gnupg}
chmod 700 ~/.ssh
chmod 600 ~/.ssh/*
chmod 644 -f ~/.ssh/*.pub ~/.ssh/authorized_keys ~/.ssh/known_hosts
# chmod 700 -R ~/.password-store/*
# chmod 700 -R ~/.gnupg/*

sudo mkdir -p /etc/samba/credentials
sudo vim /etc/samba/credentials/share
# - format:
# - `username=X`
# - `password=Y`
# - Obscure the file:
sudo chown root:root /etc/samba/credentials/share
sudo chmod 700 /etc/samba/credentials/share
sudo chmod 600 /etc/samba/credentials/share

paci --needed --noconfirm cifs-utils
sudo mount -t cifs //192.168.1.138/home ~/.mnt/skywafer/home -o credentials=/etc/samba/credentials/share,workgroup=WORKGROUP,uid=1000,gid=985,nofail,x-systemd.device-timeout=10,noauto,x-systemd.automount,_netdev
mkdir -p ~/Documents
ln -s ~/.mnt/skywafer/home/Drive/wiki ~/Documents
#}}}

# openvpn {{{
paci --needed openvpn
# Test it
sudo openvpn ~/Documents/wiki/misc/home.ovpn
sudo cp /home/reinaldo/Documents/wiki/misc/home.ovpn /etc/openvpn/client/home.conf
# Edit config and add pass.conf to the uth-user-pass line
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
# }}}

# password-store{{{
paci --needed --noconfirm --needed rofi-pass
## Passwords
# pass-import most likely you'll have to download from git page
gpg --recv-keys 06A26D531D56C42D66805049C5469996F0DF68EC
paci --needed --noconfirm python-pykeepass
paci --needed --noconfirm pass keepass pass-import
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
pacu networkmanager network-manager-applet networkmanager-openvpn
sudo systemctl enable NetworkManager.service
#}}}

# i3-wm{{{
paci --needed --noconfirm i3-gaps i3blocks i3lock rofi rofi-dmenu i3ass xdotool 
paci --needed --noconfirm feh redshift qrencode xclip dunst libnotify
paci --needed --noconfirm scrot flameshot
# Replacement for htop. Execute: btm
paci --needed --noconfirm bottom-bin
# Compton changed name to picom
paci --needed --noconfirm picom
# Deprecated
# `cbatticon `
# `paystray`
# `blueberry`
#}}}

# rofi extra goodies
paci --needed --noconfirm rofi-{emoji,bluetooth-git} networkmanager-dmenu-git 
paci --needed --noconfirm noto-fonts-emoji

# synology nfs and backups
# paci --needed

# polybar{{{
paci --needed --noconfirm jsoncpp polybar alsa-utils paprefs
paci --needed --noconfirm alsa-lib wireless_tools curl pacman-contrib
paci --needed --noconfirm nerd-fonts-iosevka ttf-weather-icons jq
paci --needed --noconfirm python-pywal
wal --theme base16-google -l -q -o "$HOME/.config/polybar/launch.sh"
# usb automount
# Removing pcmanfm
# There's a polybar module that will be used to mount/umount devices
paci --needed --noconfirm gvfs-mtp gvfs-gphoto2 udisks2
sudo install -Dm644 /home/reinaldo/.config/polybar/scripts/95-usb.rules \
  /etc/udev/rules.d/95-usb.rules
#}}}

# xorg
paci --needed --noconfirm xorg xorg-apps xorg-xinit xorg-drivers xorg-server
# `xorg autologin`
paci --needed --noconfirm lightdm
sudo systemctl enable lightdm

# add your user to the autologin group
sudo groupadd -r autologin
sudo gpasswd -a reinaldo autologin

# Create
# Valid session names under /usr/share/xsessions/*.desktop
sudo vim /etc/lightdm/lightdm.conf

# [Seat:*]
# autologin-user=reinaldo
# autologin-session=i3-with-shmlog

# Development environment {{{
paci --needed --noconfirm neovim-nightly-bin cscope ripgrep ctags global xclip
paci --needed --noconfirm neovim-remote lazygit
# Takes forever, rust compilation
paci --needed --noconfirm ripgrep-all
# for diffs
paci --needed --noconfirm meld
# for documentation
paci --needed --noconfirm zeal
paci --needed --noconfirm pandoc-{,citeproc-,crossref-}bin
# - run the `dotfiles/scripts/python_neovim_virtualenv.sh` script
# to get `/usr/share/dict` completion
paci --needed --noconfirm plantuml words

## vim
# Sun Jan 17 2021 07:07: Depracated. Install in the pynvim venv
# paci --needed --noconfirm vint

## cmake

paci --needed --noconfirm cmake{,-lint,-format}
# ~~`install cmake-language-server`~~

## rust{{{
paci --needed --noconfirm rust{,fmt,-analyzer}
#}}}

## cpp

paci --needed --noconfirm gtest google-glog rapidjson boost boost-libs websocketpp cmake ninja
paci --needed --noconfirm cppcheck cpplint
paci --needed --noconfirm lldb clang gdb gdb-dashboard-git
# For coloring gcc and compilers output
paci --needed --noconfirm colorgcc

## shell

paci --needed --noconfirm shellcheck-bin shfmt

## lua
## lua-language-server consumes ton of cpu power. Plus its chinese, don't trust 
## it
paci --needed --noconfirm luajit lua-format luacheck

## java

# Installs java the latest and version 8, still widely used.
paci --needed --noconfirm j{re,re8,dk,dk8}-openjdk
# checkstyle out of date
paci --needed --noconfirm jdtls astyle

## python

paci --needed --noconfirm python{,-pip} python2{,-pip}
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

## power

- #eyword: battery, powertop, power
paci --needed --noconfirm powertop
sudo powertop --calibrate
# For more info see: `archwiki powertop`
# See also `laptop-mode`
paci --needed --noconfirm acpid
sudo systemctl enable --now acpid
paci --needed --noconfirm laptop-mode-tools
sudo systemctl enable --now laptop-mode
paci --needed --noconfirm hdparm sdparm ethtool wireless_tools hal python-pyqt5

### tweaking kernel for battery saving

# Sun Mar 17 2019 14:14 
# Taken from [here](https://wiki.archlinux.org/index.php/Power_management)

#### webcam

# blacklist it.
sudo sudo bash -c 'printf "blacklist uvcvideo" > /etc/modprobe.d/no_webcam.conf'

#### audio power save

# To check audio driver: `lspci -k`
sudo sudo bash -c 'printf "options snd_had_intel power_save=1" > /etc/modprobe.d/audio.conf'
# Disable hdmi output
sudo sudo bash -c 'printf "blacklist snd_hda_codec_hdmi" > /etc/modprobe.d/no_hdmi_audio.conf.conf'

#### wifi

# Add to /etc/modprobe.d/iwlwifi.conf
#options iwlwifi power_save=1 d0i3_disable=0 uapsd_disable=0
#options iwldvm force_cam=0

#### others

# use [this](https://github.com/Hjdskes/powersave) script
# examine the script as it disables bluetooth for example

# Make it pretty
paci --needed --noconfirm numix-gtk-theme paper-icon-theme capitaine-cursors lxappearance adapta-gtk-theme paper-gtk-theme-git
# And then just go to `Customize Look and Feel` 

# Task Manager

paci --needed --noconfirm glances
# ~~`install lxtask stacer-bin glances`~~

# Audio/Music{{{

paci --needed --noconfirm cmus playerctl pipewire
paci --needed --noconfirm pamixer alsa-lib libao libcdio libcddb libvorbis \
  libmpcdec wavpack libmad libmodplug libmikmod pavucontrol
paci --needed --noconfirm mpv

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
# protonmail-bridge 
paci --needed --noconfirm neomutt abook urlscan lynx \
  isync goimapnotify
# Needed to backup emails
# paci --needed --noconfirm offlineimap
mkdir -p ~/mail/{molinamail,molinamail_meli}/inbox
/usr/bin/mbsync -D -ac ~/.config/isync/mbsyncrc
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

# Bluetooth

paci --needed --noconfirm pipewire-{pulse,jack,alsa} bluez bluez-libs bluez-utils bluez-firmware
sudo systemctl enable --now bluetooth

# journal

# Tue Mar 26 2019 08:58
# Auto clean up
sudo vim /etc/systemd/journald.conf
# Add or uncomment `SystemMaxUse=2G`

# Browser{{{

## firefox

paci --needed --noconfirm firefox
# paci --needed --noconfirm firefox-extension-privacybadger`
# paci --needed --noconfirm libnotify speech-dispatcher festival`
paci --needed --noconfirm vdhcoapp-bin
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
paci hplip cups cups-pdf simple-scan gtk3-print-backends --noconfirm
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

# Misc

## gui mock ups design

- [here][0]
- `paci --needed --noconfirm pencil`

## check files duplicates

- Mon Jun 10 2019 09:59
- `paci --needed --noconfirm fdupes`

## Diagrams

- Sun Mar 17 2019 18:26 
- keyword: graphics, graph, editor
- Mainly for stuff that `plantuml` cannot do
- `paci --needed --noconfirm yed`

## Preload

- Wed May 02 2018 06:04
- Cool application.
- `paci --needed --noconfirm preload`
- Can be done as user level
- `sudo systemctl enable --now preload`

## Youtube-dl

- `~`install youtube-dl-gui-git`~`
- `paci --needed --noconfirm youtube-dl`

## Screen recording

-  Application to record and share cools screen captures
- `paci --needed --noconfirm asciinema`

## Disk Usage Utility
- `paci --needed --noconfirm baobab`

## Steam
paci --needed steam ttf-liberation lib32-mesa mesa lib32-nvidia-utils nvidia-utils steam-fonts

## Video playing
- `paci --needed --noconfirm vlc`

## wine{{{
# Make sure WINEPREFIX exists
paci --needed --noconfirm wine wine-gecko winetricks wine-mono
paci --needed --noconfirm lib32-lib{pulse,xrandr}
paci --needed --noconfirm dxvk-bin
setup_dxvk install
# Temp directory on tmpfs
rm -r "$WINEPREFIX/drive_c/users/$USER/Temp"
ln -s /tmp/ "$WINEPREFIX/drive_c/users/$USER/Temp"
# Fix fonts
cd ${WINEPREFIX:-~/.wine}/drive_c/windows/Fonts && for i in /usr/share/fonts/**/*.{ttf,otf}; do ln -s "$i" ; done
export FREETYPE_PROPERTIES="truetype:interpreter-version=35"
winetricks corefonts
winetricks settings fontsmooth=rgb
#}}}

## maintenence

- `paci --needed --noconfirm bleachbit`

## Android

- `paci --needed --noconfirm android-tools android-udev`

## Android-Dev

- `android-studio android-sdk`
	- Remember: `~/.bashrc`->`export ANDROID_HOME=<sdk-location>`
- If you just want to flash stuff to your phone
- `paci --needed --noconfirm android-udev android-tools`

## syslog

### Fri Oct 25 2019 14:35\

- `paci --needed --noconfirm syslog-ng`
- `sudo systemctl enable --now syslog-ng@default.service`
- now when you log with `openlog()` and/or `syslog()` you can see it in `journalctl`

# [0]: https://pencil.evolus.vn/
# [1]: https://wiki.archlinux.org/index.php/Hardware_video_acceleration

# vim: fdm=marker
