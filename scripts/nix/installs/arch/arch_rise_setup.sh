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

# Copy your `mirrorlist`:
scp /etc/pacman.d/mirrorlist reinaldo@192.168.1.194:/home/reinaldo/mirrorlist

# install `trizen`{{{
# From this point on you need to login as your user
# You should not run `trizen` or `makepkg` as `root`
pacman -S git
su reinaldo
cd /tmp
git clone https://aur.archlinux.org/trizen.git --depth 1
cd trizen
makepkg -si
#}}}

# install dotfiles{{{
# Download dotfiles
mkdir -p ~/.config
mkdir -p ~/.cache
cd ~/.config
git clone https://github.com/tricktux/dotfiles
# Install needed software
trizen -S stow
# So that you don't loose the hostname command
trizen -S inetutils
# Backup current setup
# Make sure no other dotfiles are left
mv ~/.bash_logout{,_bak}
mv ~/.bash_profile{,_bak}
mv ~/.bashrc{,_bak}
mv ~/.config/trizen{,_}
# Install your configs
cd ~/.config/dotfiles
stow -t /home/reinaldo -S defaults 
# Check that all went well
ls -als ~/ 
# Get your aliases
source ~/.bash_aliases 
# Pass nvim config to root user as well to make `sudo nvim` usable
sudo mkir -p /root/.config
sudo ln -s /home/reinaldo/.config/nvim /root/.config
#}}}

# fix time:{{{
install ntp
sudo timedatectl set-ntp true
#}}}

# ccache to speed up compilations
pacinst --needed --noconfirm ccache

# Beautiful arch wallpapers
pacinst --needed --noconfirm archlinux-wallpaper

# `arch-audit`
pacinst --needed --noconfirm arch-audit
# - Enable the `pacman` hook to auto check for vulnerabilities
# - Not needed anymore:
# - `sudo cp /usr/share/arch-audit/arch-audit.hook /etc/pacman.d/hooks`

# `ssh`
pacinst --needed --noconfirm openssh mosh
# - Actually use `mosh` is much faster
# - If you want this setup to be `ssh` accessible:
# - `systemctl enable sshd.socket`
# - `systemctl enable sshd`
# - Add to `.ssh/config`
# - `AddKeysToAgent yes`

# zsh{{{
pacinst --needed --noconfirm zsh
# Legacy
# install oh-my-zsh-git zplug pkgfile
# Install zim
curl -kfLo $ZIM_HOME/zimfw.zsh --create-dirs \
  https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
chmod +x $ZIM_HOME/zimfw.zsh
zsh $ZIM_HOME/zimfw.zsh install
# Install plugins
pacinst --needed --noconfirm pkgfile
# pkgfile needs to be updated
sudo systemctl enable pkgfile-update.timer
# By default it runs daily
# Update /usr/lib/systemd/system/pkgfile-update.timer to run weekly
# Also update it to wait for network by adding to [Unit]
# Wants=network-online.target
# After=network-online.target nss-lookup.target
sudo systemctl start pkgfile-update.service

chsh -s /usr/bin/zsh
# symlink all the `zsh*` files
#}}}

# Update arch mirrors {{{
pacinst --needed --noconfirm reflector
sudo mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist_king
# Put options in config file
sudo bash -c 'printf "\n--latest 30" >> /etc/xdg/reflector/reflector.conf'
sudo bash -c 'printf "\n--number 5" >> /etc/xdg/reflector/reflector.conf'
sudo bash -c 'printf "\n--sort rate" >> /etc/xdg/reflector/reflector.conf'
sudo bash -c 'printf "\n--country \"United States\"" >> /etc/xdg/reflector/reflector.conf'
sudo bash -c 'printf "\n--info" >> /etc/xdg/reflector/reflector.conf'
sudo systemctl enable --now reflector.timer
sudo systemctl start reflector.service
#}}}

pacinst --needed --noconfirm earlyoom
sudo systemctl enable --now earlyoom

# Video card{{{
lspci -k | grep -A 2 -i "VGA"
# If you happen to see 2 cards here, follow instructions at [this](https://wiki.archlinux.org/index.php/Optimus)
# Should be good
# With the predator you should also do:
# Go to `sudo vim /etc/pacman.conf` and uncomment `multilib` this allows you to
# install 32-bit programs
# Mon Sep 18 2017 22:46: Also dont forget to update and uncomment both lines, multilib and Include 
pacinst --needed --noconfirm nvidia nvidia-libgl lib32-nvidia-libgl lib32-nvidia-utils nvidia-utils nvidia-settings nvtop
# **Nvidia drivers**
sudo pacman -S --needed --noconfirm nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader
# **Intel drivers**
sudo pacman -S --needed --noconfirm lib32-mesa mesa vulkan-intel lib32-vulkan-intel \
  vulkan-icd-loader lib32-vulkan-icd-loader xf86-video-intel
# **Hybrid Card**
# If you have one:
pacinst --needed --noconfirm bumblebee mesa lib32-{virtualgl,nvidia-utils,primus} primus
pacinst --needed --noconfirm bbswitch
# Add your user to the `bumblebee` group:
gpasswd -a <user> bumblebee
gpasswd -a reinaldo bumblebee
sudo systemctl enable --now bumblebeed
# manually turn on/off gpu
sudo tee /proc/acpi/bbswitch <<< {ON,OFF}
# checkout [this][1] link for hardware acceleration
#}}}

# terminal utils{{{
pacinst --needed --noconfirm acpi lm_sensors liquidprompt tldr
pacinst --needed --noconfirm {ttf,otf}-fira-{code,mono} {ttf,otf}-font-awesome nerd-fonts-inconsolata
pacinst --needed --noconfirm ttf-inconsolata
pacinst --needed --noconfirm xorg-xfontsel gtk2fontsel
# Package doesn't exist anymore thumbnailer 
pacinst --needed --noconfirm atool ranger zip unzip w3m ffmpeg highlight libcaca
# Not installing anymore: advcp 
pacinst --needed --noconfirm mediainfo odt2txt poppler w3m bat exa fzf fd ripgrep tmux imagemagick ghostscript xclip

# kitty
pacinst --needed --noconfirm kitty
# Depends on rust
# Causes all kinds of problems
# pacinst page-git
#}}}
# Essentials

# resilio
# See `random.md resilio` section
# samba
# See `random.md samba-manual` section

# nfs{{{
pacinst --needed --noconfirm nfs-utils
mkdir -p $HOME/.mnt/skynfs
sudo bash -c 'printf "192.168.1.138:/volume1/backup /home/reinaldo/.mnt/skynfs nfs _netdev,noauto,user,x-systemd.automount,x-systemd.mount-timeout=10,timeo=14,x-systemd.idle-timeout=1min,vers=3 0 0" >> /etc/fstab'
# Try it with
sudo mount -v -t nfs 192.168.1.138:/volume1/backup /home/reinaldo/.mnt/skynfs -o vers=3
#}}}

# password-store{{{
pacinst --needed --noconfirm --needed rofi-pass
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
pacinst --needed --noconfirm numlockx
		
# Desktop

# screenshots, i3
# After this steps you should have a working `i3` setup.

# Network Manager{{{
pacinst --needed --noconfirm networkmanager network-manager-applet networkmanager-openvpn
sudo systemctl enable NetworkManager.service
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
  rise'printf "[Unit]" >> /etc/systemd/system/wpa_supplicant.service.d/override.conf'
sudo bash -c \
  'printf "\nAfter=dbus.service" >> /etc/systemd/system/wpa_supplicant.service.d/override.conf'
#}}}

# i3-wm{{{
pacinst --needed --noconfirm i3-gaps i3blocks i3lock rofi rofi-dmenu i3ass xdotool dunst
pacinst --needed --noconfirm feh cbatticon redshift
pacinst --needed --noconfirm scrot flameshot
# Compton changed name to picom
pacinst --needed --noconfirm picom
# Deprecated
# `paystray`
# `blueberry`
#}}}

# rofi extra goodies
pacinst --needed --noconfirm rofi-{emoji,bluetooth-git} networkmanager-dmenu-git 
pacinst --needed --noconfirm noto-fonts-emoji

# synology nfs and backups
pacinst --needed

# polybar{{{
pacinst --needed --noconfirm jsoncpp polybar alsa-utils paprefs
pacinst --needed --noconfirm alsa-lib wireless_tools curl pacman-contrib
pacinst --needed --noconfirm nerd-fonts-iosevka ttf-weather-icons jq
# usb automount
# Removing pcmanfm
# There's a polybar module that will be used to mount/umount devices
pacinst --needed --noconfirm gvfs-mtp gvfs-gphoto2 udisks2
sudo install -Dm644 /home/reinaldo/.config/polybar/scripts/95-usb.rules \
  /etc/udev/rules.d/95-usb.rules
#}}}

# xorg
pacinst --needed --noconfirm xorg xorg-apps xorg-xinit xorg-drivers xorg-server
# `xorg autologin`
pacinst --needed --noconfirm lightdm
sudo systemctl enable lightdm

# add your user to the autologin group
sudo groupadd -r autologin
sudo gpasswd -a reinaldo autologin

# Create
# Valid session names under /usr/share/xsessions/*.desktop
# /etc/lightdm/lightdm.conf

# [Seat:*]
# autologin-user=reinaldo
# autologin-session=i3-with-shmlog

# Editor

pacinst --needed --noconfirm neovim cscope ripgrep universal-ctags-git global xclip vim
pacinst --needed --noconfirm neovim-remote
# for diffs
pacinst --needed --noconfirm meld
# for documentation
pacinst --needed --noconfirm zeal
pacinst --needed --noconfirm pandoc-{,citeproc-,crossref-}bin
# - run the `dotfiles/scripts/python_neovim_virtualenv.sh` script
# to get `/usr/share/dict` completion
pacinst --needed --noconfirm plantuml look words

## vim

pacinst --needed --noconfirm vint

## cmake

pacinst --needed --noconfirm cmake-{lint,format}
# ~~`install cmake-language-server`~~

## cpp

pacinst --needed --noconfirm gtest google-glog rapidjson boost boost-libs websocketpp cmake ninja
pacinst --needed --noconfirm cppcheck cpplint
pacinst --needed --noconfirm clang lldb gdb
# For coloring gcc and compilers output
pacinst --needed --noconfirm colorgcc

## shell

pacinst --needed --noconfirm shellcheck-static shfmt

## lua
## lua-language-server consumes ton of cpu power. Plus its chinese, don't trust 
## it
pacinst --needed --noconfirm luajit lua-format luacheck

## java

# Installs java the latest and version 8, still widely used.
pacinst --needed --noconfirm j{re,re8,dk,dk8}-openjdk
pacinst --needed --noconfirm jdtls checkstyle astyle

## python

pacinst --needed --noconfirm python{,-pip} python2{,-pip}
# Python modules are control via virtual env
# Run the update-arch.sh script and will create/update such modules
# install python-language-server flake8 python-pylint yapf --noconfirm
# pip install --user stravalib

# SSD

pacinst --needed --noconfirm util-linux
sudo systemctl enable --now fstrim.timer

# Laptops

## Brightness
pacinst --needed --noconfirm brillo
# see `man brillo`

## Touchpad 

pacinst --needed --noconfirm xorg-xinput xf86-input-libinput brillo
# Also see `synclient.md`

## power

- #eyword: battery, powertop, power
pacinst --needed --noconfirm powertop
sudo powertop --calibrate
# For more info see: `archwiki powertop`
# See also `laptop-mode`
pacinst --needed --noconfirm acpid
sudo systemctl enable --now acpid
pacinst --needed --noconfirm laptop-mode-tools
sudo systemctl enable --now laptop-mode
pacinst --needed --noconfirm hdparm sdparm ethtool wireless_tools hal python-pyqt5

### tweaking kernel for battery saving

# Sun Mar 17 2019 14:14 
# Taken from [here](https://wiki.archlinux.org/index.php/Power_management)

#### webcam

# blacklist it.
sudo echo "blacklist uvcvideo" > /etc/modprobe.d/no_webcam.conf

#### audio power save

# To check audio driver: `lspci -k`
sudo echo "options snd_had_intel power_save=1" > /etc/modprobe.d/audio.conf
# Disable hdmi output
sudo echo "blacklist snd_hda_codec_hdmi" > /etc/modprobe.d/no_hdmi_audio.conf.conf

#### wifi

# Add to /etc/modprobe.d/iwlwifi.conf
#options iwlwifi power_save=1 d0i3_disable=0 uapsd_disable=0
#options iwldvm force_cam=0

#### others

# use [this](https://github.com/Hjdskes/powersave) script
# examine the script as it disables bluetooth for example

# Make it pretty
pacinst --needed --noconfirm numix-gtk-theme paper-icon-theme capitaine-cursors lxappearance adapta-gtk-theme paper-gtk-theme-git
# And then just go to `Customize Look and Feel` 

# Task Manager

pacinst --needed --noconfirm glances
# ~~`install lxtask stacer-bin glances`~~

# Audio/Music

pacinst --needed --noconfirm cmus playerctl
pacinst --needed --noconfirm libpulse pamixer alsa-lib libao libcdio libcddb libvorbis libmpcdec wavpack libmad libmodplug libmikmod pavucontrol
pacinst --needed --noconfirm mpv

# Tue Mar 12 2019 07:24
# Gearing towards `mpd`
# Mainly because `cmus` is not working properly in `helios`
# Gonna give it a try
pacinst --needed --noconfirm mpd vimpc-git

# Email
# protonmail-bridge 
pacinst --needed --noconfirm neomutt abook urlscan lynx

## Mon Mar 04 2019 22:03 

# I have decided to give `thunderbird` a try.
# Out of frustration for delayed received notifications in `neomutt`
# And wonky `ui`

pacinst --needed --noconfirm thunderbird birdtray

# Office

pacinst --needed --noconfirm libreoffice-still hunspell hunspell-es_US

# pdf & resume

pacinst --needed --noconfirm zathura zathura-pdf-mupdf texlive-most pdfgrep qpdfview
# PDF annotations use:
pacinst --needed --noconfirm xournal
# PDF searching: `install pdfgrep`
# PDF Merging:
# Sat Mar 02 2019 21:18
# **Please do not use `pdftk`**
# You seriously have to compile gcc6 for that 
# pdftk
# pdftk file1.pdf file2.pdf cat output mergedfile.pdf

# windows mount

pacinst --needed --noconfirm ntfs-3g

## Then you can just do to mount the windows partition
# mount /dev/<your_device> /mnt/win

# android

pacinst --needed --noconfirm android-tools android-udev

# Bluetooth

pacinst --needed --noconfirm pulseaudio-alsa pulseaudio-bluetooth bluez bluez-libs bluez-utils bluez-firmware
sudo systemctl enable --now bluetooth

# journal

# Tue Mar 26 2019 08:58
# Auto clean up
# modify `/etc/systemd/journald.conf`
# Add or uncomment `SystemMaxUse=2G`

# Browser

# See `random.md firefox`
# Also I use `qutebrowser` for login website
pacinst --needed --noconfirm qutebrowser pdfjs

# Printing{{{
# keywords: print, hp, cups
pacinst hplip cups cups-pdf simple-scan gtk3-print-backends --noconfirm
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
- `pacinst --needed --noconfirm pencil`

## check files duplicates

- Mon Jun 10 2019 09:59
- `pacinst --needed --noconfirm fdupes`

## Diagrams

- Sun Mar 17 2019 18:26 
- keyword: graphics, graph, editor
- Mainly for stuff that `plantuml` cannot do
- `pacinst --needed --noconfirm yed`

## Preload

- Wed May 02 2018 06:04
- Cool application.
- `pacinst --needed --noconfirm preload`
- Can be done as user level
- `sudo systemctl enable --now preload`

## Youtube-dl

- `~`install youtube-dl-gui-git`~`
- `pacinst --needed --noconfirm youtube-dl`

## Screen recording

-  Application to record and share cools screen captures
- `pacinst --needed --noconfirm asciinema`

## Disk Usage Utility
- `pacinst --needed --noconfirm baobab`

## Steam
pacinst --needed steam ttf-liberation lib32-mesa mesa lib32-nvidia-utils nvidia-utils steam-fonts

## Video playing
- `pacinst --needed --noconfirm vlc`

## Passwords
# pass-import most likely you'll have to download from git page
- `pacinst --needed --noconfirm pass keepass pass-import`

## Root passwd

- ~~`install openssh-askpass`~~
- Tue Mar 26 2019 08:53 
- `pacinst --needed --noconfirm lxqt-openssh-askpass`

## wine

- `pacinst --needed --noconfirm wine_gecko wine winetricks wine-mono`

## maintenence

- `pacinst --needed --noconfirm bleachbit`

## Android

- `pacinst --needed --noconfirm android-tools android-udev`

## Android-Dev

- `android-studio android-sdk`
	- Remember: `~/.bashrc`->`export ANDROID_HOME=<sdk-location>`
- If you just want to flash stuff to your phone
- `pacinst --needed --noconfirm android-udev android-tools`

## syslog

### Fri Oct 25 2019 14:35\

- `pacinst --needed --noconfirm syslog-ng`
- `sudo systemctl enable --now syslog-ng@default.service`
- now when you log with `openlog()` and/or `syslog()` you can see it in `journalctl`

# [0]: https://pencil.evolus.vn/
# [1]: https://wiki.archlinux.org/index.php/Hardware_video_acceleration

# vim: fdm=marker
