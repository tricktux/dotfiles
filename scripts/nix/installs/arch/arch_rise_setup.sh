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
#}}}

# fix time:{{{
install ntp
sudo timedatectl set-ntp true
#}}}

# ccache to speed up compilations
pacinst ccache

# Beautiful arch wallpapers
pacinst archlinux-wallpaper --noconfirm

# `arch-audit`
install arch-audit
# - Enable the `pacman` hook to auto check for vulnerabilities
# - Not needed anymore:
# - `sudo cp /usr/share/arch-audit/arch-audit.hook /etc/pacman.d/hooks`

# `ssh`
install openssh mosh
# - Actually use `mosh` is much faster
# - If you want this setup to be `ssh` accessible:
# - `systemctl enable sshd.socket`
# - `systemctl enable sshd`
# - Add to `.ssh/config`
# - `AddKeysToAgent yes`

# zsh{{{
install zsh
# Legacy
# install oh-my-zsh-git zplug pkgfile
# Install zim
curl -kfLo $ZIM_HOME/zimfw.zsh --create-dirs \
  https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
chmod +x $ZIM_HOME/zimfw.zsh
zsh $ZIM_HOME/zimfw.zsh install
# Install plugins
install pkgfile
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
pacinst reflector
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

pacinst earlyoom
sudo systemctl enable --now earlyoom

# Video card
lspci -k | grep -A 2 -i "VGA"
# If you happen to see 2 cards here, follow instructions at [this](https://wiki.archlinux.org/index.php/Optimus)
# Should be good
# With the predator you should also do:
# Go to `sudo vim /etc/pacman.conf` and uncomment `multilib` this allows you to
# install 32-bit programs
# Mon Sep 18 2017 22:46: Also dont forget to update and uncomment both lines, multilib and Include 
install nvidia nvidia-libgl lib32-nvidia-libgl lib32-nvidia-utils nvidia-utils nvidia-settings nvtop
# **Nvidia drivers**
sudo pacman -S nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader
# **Intel drivers**
sudo pacman -S lib32-mesa mesa vulkan-intel lib32-vulkan-intel \
  vulkan-icd-loader lib32-vulkan-icd-loader xf86-video-intel
# **Hybrid Card**
# If you have one:
install bumblebee mesa lib32-{virtualgl,nvidia-utils,primus} primus
install bbswitch
# Add your user to the `bumblebee` group:
gpasswd -a <user> bumblebee
gpasswd -a reinaldo bumblebee
sudo systemctl enable --now bumblebeed
# manually turn on/off gpu
sudo tee /proc/acpi/bbswitch <<< {ON,OFF}

# checkout [this][1] link for hardware acceleration

# terminal utils{{{
pacinst acpi lm_sensors liquidprompt tldr --noconfirm
pacinst {ttf,otf}-fira-{code,mono} {ttf,otf}-font-awesome nerd-fonts-inconsolata --noconfirm
pacinst ttf-inconsolata --noconfirm
pacinst xorg-xfontsel gtk2fontsel --noconfirm
# Package doesn't exist anymore thumbnailer 
pacinst atool ranger zip unzip w3m ffmpeg highlight libcaca --noconfirm
# Not installing anymore: advcp 
pacinst mediainfo odt2txt poppler w3m bat exa fzf fd ripgrep tmux imagemagick ghostscript xclip --noconfirm

# kitty
pacinst kitty --noconfirm
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
pacinst nfs-utils
mkdir -p $HOME/.mnt/skynfs
sudo bash -c 'printf "192.168.1.138:/volume1/backup /home/reinaldo/.mnt/skynfs nfs _netdev,noauto,user,x-systemd.automount,x-systemd.mount-timeout=10,timeo=14,x-systemd.idle-timeout=1min,vers=3 0 0" >> /etc/fstab'
# Try it with
sudo mount -v -t nfs 192.168.1.138:/volume1/backup /home/reinaldo/.mnt/skynfs -o vers=3
#}}}

# password-store{{{
install rofi-pass --noconfirm
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
install numlockx --noconfirm
		
# Desktop

# screenshots, i3
# After this steps you should have a working `i3` setup.

# Network Manager
install networkmanager network-manager-applet networkmanager-openvpn --noconfirm
sudo systemctl enable NetworkManager.service

# i3-wm
pacinst i3-gaps i3blocks i3lock rofi rofi-dmenu i3ass xdotool dunst --noconfirm
pacinst pcmanfm feh cbatticon redshift --noconfirm
pacinst scrot flameshot --noconfirm
# Compton changed name to picom
install picom --noconfirm
# Deprecated
# `paystray`
# `blueberry`

# rofi extra goodies
pacinst rofi-{emoji,bluetooth-git} networkmanager-dmenu-git 
pacinst noto-fonts-emoji

# synology nfs and backups
pacinst rsync nfs-utils --noconfirm

# polybar
install jsoncpp polybar alsa-utils paprefs --noconfirm
install alsa-lib wireless_tools curl pacman-contrib --noconfirm
install nerd-fonts-iosevka ttf-weather-icons jq --noconfirm

# xorg
install xorg xorg-apps xorg-xinit xorg-drivers xorg-server --noconfirm
# `xorg autologin`
install lightdm --noconfirm
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

install neovim cscope ripgrep universal-ctags-git global xclip vim --noconfirm
install neovim-remote --noconfirm
# for diffs
install meld --noconfirm
# for documentation
install zeal --noconfirm
install pandoc-{,citeproc-,crossref-}bin --noconfirm
# - run the `dotfiles/scripts/python_neovim_virtualenv.sh` script
# to get `/usr/share/dict` completion
install plantuml look words --noconfirm

## vim

install vint --noconfirm

## cmake

install cmake-{lint,format} --noconfirm
# ~~`install cmake-language-server`~~

## cpp

install gtest google-glog rapidjson boost boost-libs websocketpp cmake ninja --noconfirm
install cppcheck cpplint --noconfirm
install clang lldb gdb --noconfirm
# For coloring gcc and compilers output
install colorgcc --noconfirm

## shell

install shellcheck-static shfmt --noconfirm

## lua
## lua-language-server consumes ton of cpu power. Plus its chinese, don't trust 
## it
install luajit lua-format luacheck --noconfirm

## java

# Installs java the latest and version 8, still widely used.
install j{re,re8,dk,dk8}-openjdk --noconfirm
install jdtls checkstyle astyle --noconfirm

## python

install python{,-pip} python2{,-pip} --noconfirm
# Python modules are control via virtual env
# Run the update-arch.sh script and will create/update such modules
# install python-language-server flake8 python-pylint yapf --noconfirm
# pip install --user stravalib

# SSD

install util-linux --noconfirm
sudo systemctl enable --now fstrim.timer

# Laptops

## Brightness
install brillo
# see `man brillo`

## Touchpad 

install xorg-xinput xf86-input-libinput brillo
# Also see `synclient.md`

## power

- #eyword: battery, powertop, power
install powertop
sudo powertop --calibrate
# For more info see: `archwiki powertop`
# See also `laptop-mode`
install acpid
sudo systemctl enable --now acpid
install laptop-mode-tools
sudo systemctl enable --now laptop-mode
install hdparm sdparm ethtool wireless_tools hal python-pyqt5

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
install numix-gtk-theme paper-icon-theme capitaine-cursors lxappearance adapta-gtk-theme paper-gtk-theme-git --noconfirm
# And then just go to `Customize Look and Feel` 

# Task Manager

install glances
# ~~`install lxtask stacer-bin glances`~~

# Audio/Music

install cmus playerctl --noconfirm
install libpulse pamixer alsa-lib libao libcdio libcddb libvorbis libmpcdec wavpack libmad libmodplug libmikmod pavucontrol --noconfirm
install mpv --noconfirm

# Tue Mar 12 2019 07:24
# Gearing towards `mpd`
# Mainly because `cmus` is not working properly in `helios`
# Gonna give it a try
install mpd vimpc-git --noconfirm

# Email
# protonmail-bridge 
install neomutt abook urlscan lynx --noconfirm

## Mon Mar 04 2019 22:03 

# I have decided to give `thunderbird` a try.
# Out of frustration for delayed received notifications in `neomutt`
# And wonky `ui`

install thunderbird birdtray

# Office

install libreoffice-still hunspell hunspell-es_US

# pdf & resume

install zathura zathura-pdf-mupdf texlive-most pdfgrep qpdfview --noconfirm
# PDF annotations use:
install xournal
# PDF searching: `install pdfgrep`
# PDF Merging:
# Sat Mar 02 2019 21:18
# **Please do not use `pdftk`**
# You seriously have to compile gcc6 for that 
# pdftk
# pdftk file1.pdf file2.pdf cat output mergedfile.pdf

# usb automount

install gvfs-mtp gvfs-gphoto2 pcmanfm --noconfirm

# windows mount

install ntfs-3g --noconfirm

## Then you can just do to mount the windows partition
# mount /dev/<your_device> /mnt/win

# android

install android-tools android-udev

# Bluetooth

install pulseaudio-alsa pulseaudio-bluetooth bluez bluez-libs bluez-utils bluez-firmware --noconfirm
sudo systemctl enable --now bluetooth

# journal

# Tue Mar 26 2019 08:58
# Auto clean up
# modify `/etc/systemd/journald.conf`
# Add or uncomment `SystemMaxUse=2G`

# Browser

# See `random.md firefox`
# Also I use `qutebrowser` for login website
install qutebrowser pdfjs

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
- `install pencil`

## check files duplicates

- Mon Jun 10 2019 09:59
- `install fdupes`

## Diagrams

- Sun Mar 17 2019 18:26 
- keyword: graphics, graph, editor
- Mainly for stuff that `plantuml` cannot do
- `install yed`

## Preload

- Wed May 02 2018 06:04
- Cool application.
- `install preload`
- Can be done as user level
- `sudo systemctl enable --now preload`

## Youtube-dl

- `~`install youtube-dl-gui-git`~`
- `install youtube-dl`

## Screen recording

-  Application to record and share cools screen captures
- `install asciinema`

## Disk Usage Utility
- `install baobab`

## Steam
- `install steam ttf-liberation {lib32-}mesa {lib32-}nvidia-utils steam-fonts`

## Video playing
- `install vlc`

## Passwords
- pass-import most likely you'll have to download from git page
- `install pass keepass pass-import`

## Root passwd

- ~~`install openssh-askpass`~~
- Tue Mar 26 2019 08:53 
- `install lxqt-openssh-askpass`

## wine

- `install wine_gecko wine winetricks wine-mono`

## maintenence

- `install bleachbit`

## Android

- `install android-tools android-udev`

## Android-Dev

- `android-studio android-sdk`
	- Remember: `~/.bashrc`->`export ANDROID_HOME=<sdk-location>`
- If you just want to flash stuff to your phone
	- `install android-udev android-tools`

## syslog

### Fri Oct 25 2019 14:35\

- `install syslog-ng`
- `sudo systemctl enable --now syslog-ng@default.service`
- now when you log with `openlog()` and/or `syslog()` you can see it in `journalctl`

# [0]: https://pencil.evolus.vn/
# [1]: https://wiki.archlinux.org/index.php/Hardware_video_acceleration

# vim: fdm=marker
