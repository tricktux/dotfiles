# Basics

# You could start here:
# https://github.com/ahmedelhori/install-arch

# If you have problems with wifi, nvidia, or the kernel restore to a known state
# by downgrading all of the following packages
# linux-api-headers linux-lts-headers linux-firmware linux-firware-whence
# linux-lts nvidia-lts nvidia-utils nvidia-settings

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
sudo EDITOR=nvim visudo
# Search for wheel and uncomment that line
# And underneath add the following:
Defaults rootpw
# This way you only need to enter your pw once per session
# `Defaults:<username> timestamp_timeout=-1`
Defaults:reinaldo timestamp_timeout=7200
su reinaldo
# }}}

## 3. Network{{{
# Use nmtui or iwctl
# Network Manager{{{
paru -Syu --needed --noconfirm networkmanager network-manager-applet networkmanager-openvpn networkmanager-dmenu-git 
pacu networkmanager network-manager-applet networkmanager-openvpn networkmanager-dmenu-git 
sudo systemctl enable --now NetworkManager.service
sudo systemctl status NetworkManager.service
# }}}

#}}}

# Copy your `mirrorlist`: {{{
scp /etc/pacman.d/mirrorlist reinaldo@192.168.1.194:/home/reinaldo/mirrorlist
sudo mv /etc/pacman.d/mirrorlist{,.bak}
sudo mv /home/reinaldo/mirrorlist /etc/pacman.d/mirrorlist
cd
# On computer that is setting up pc follow these steps
cp /etc/pacman.d/mirrorlist /tmp/mirrorlist
scp reinaldo@192.168.1.148:/tmp/mirrorlist .
sudo mv mirrorlist /etc/pacman.d/mirrorlist
# }}}

# install `paru`{{{
# From this point on you need to login as your user
# You should not run `paru` or `makepkg` as `root`
sudo pacman -S --needed git
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
# ccache to speed up compilations
sudo pacman -Syu --needed ccache mold
cd
mkdir -p ~/.{config,cache}
mkdir -p ~/Documents
mkdir -p ~/.local/share/Trash/files
cd ~/.config
git clone https://github.com/tricktux/dotfiles
# NOTE: Change link to: ssh://github/tricktux/dotfiles
nvim "$HOME/.config/dotfiles/.git/config"
# Install needed software
paru -Syu stow
# So that you don't loose the hostname command
paru -Syu inetutils
# Backup current setup
# Make sure no other dotfiles are left
mv ~/.bash_logout{,_bak}
mv ~/.bash_profile{,_bak}
mv ~/.bashrc{,_bak}
# mv ~/.config/paru{,_}
# Install your configs
cd ~/.config/dotfiles
make
# Check that all went well
ls -als ~/ 
ls -als ~/.config
# Get your aliases
source ~/.bash_aliases 
#}}}

# fix time:{{{
paru -Syu ntp
sudo timedatectl set-ntp true
#}}}

# SSD {{{
paru -Syu --needed --noconfirm util-linux
sudo systemctl enable --now fstrim.timer
# }}}

# Setup NetBackup {{{
# NOTE: this is from the advanced section
# But it's useful to do early on if advanced to leverage caching pacman packages
# This is to get the server's cache to install stuff faster
mkdir -p $HOME/.mnt/skywafer/{home,music,shared,video,NetBackup}
sudo bash -c 'printf "\n//192.168.1.139/NetBackup /home/reinaldo/.mnt/skywafer/NetBackup cifs credentials=/etc/samba/credentials/share,workgroup=WORKGROUP,uid=1000,gid=1000,nofail,x-systemd.device-timeout=10,noauto,x-systemd.automount,_netdev,vers=3.0 0 0" >> /etc/fstab'
paru -Syu --needed cifs-utils
sudo mount -t cifs //192.168.1.139/NetBackup ~/.mnt/skywafer/NetBackup -o credentials=/etc/samba/credentials/share,workgroup=WORKGROUP,uid=1000,gid=1000,nofail,x-systemd.device-timeout=10,noauto,x-systemd.automount,_netdev,vers=3.0
sudo mkdir -p /etc/samba/credentials
sudo nvim /etc/samba/credentials/share
# Just copy the info for now from local pc
# - format:
# - `username=X`
# - `password=Y`
# - Obscure the file:
sudo chown root:root /etc/samba/credentials/share
sudo chmod 700 /etc/samba/credentials/share
sudo chmod 600 /etc/samba/credentials/share
# }}}

# Update arch mirrors {{{
paru -S --needed --noconfirm reflector
sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist_king
# Put options in config file
sudo bash -c 'printf "\n--latest 30" >> /etc/xdg/reflector/reflector.conf'
sudo bash -c 'printf "\n--number 5" >> /etc/xdg/reflector/reflector.conf'
sudo bash -c 'printf "\n--sort rate" >> /etc/xdg/reflector/reflector.conf'
sudo bash -c 'printf "\n--country \"United States\"" >> /etc/xdg/reflector/reflector.conf'
sudo bash -c 'printf "\n--verbose" >> /etc/xdg/reflector/reflector.conf'
sudo nvim /etc/xdg/reflector/reflector.conf
# Ensure root owns mirrorlist, otherwise reflector service will fail
# If service fails, ensure that root owns the file
sudo chown root /etc/pacman.d/mirrorlist
sudo chown root:root /etc/pacman.d/mirrorlist
sudo chmod 644 /etc/pacman.d/mirrorlist
sudo systemctl enable --now reflector.timer
sudo systemctl start reflector.timer
sudo systemctl status reflector.timer
sudo systemctl start reflector.service
sudo systemctl status reflector.service
sudo reflector --country "United States" --latest 30 --number 5 \
  --sort rate --protocol https --save /etc/pacman.d/mirrorlist
  sudo nvim /etc/pacman.d/mirrorlist
#}}}

# Configure pacman {{{
# Go to `sudo vim /etc/pacman.conf` and uncomment `multilib` this allows you to
# Now that you are there also uncomment the Color option
# Also add the ParallelDownloads = 5 option
# Also uncomment Color option
# Also add ILoveCandy option
# Also add:
# CacheDir    = /home/reinaldo/.mnt/skywafer/NetBackup/pacman_cache/x86_64
# CacheDir    = /var/cache/pacman/pkg/
# Prevent pacman from updating sensitive stuff:
# IgnorePkg   = linux-api-headers linux-firmware linux-firmware-whence linux-lts linux-lts-headers nvidia-lts nvidia-utils nvidia-settings lib32-nvidia-utils virtualbox virtualbox-host-dkms virtualbox-guest-iso
sudo nvim /etc/pacman.conf
sudo pacman -Sy
# install 32-bit programs
# Mon Sep 18 2017 22:46: Also dont forget to update and uncomment both lines, multilib and Include 
# }}}

# Linux kernel{{{
# NOTE: Otherwise you wont be able to boot
# Update /boot/loader/entries/arch.conf
sudo nvim /boot/loader/entries/arch.conf
# Below for lts
# linux /vmlinuz-linux-lts
# initrd /initramfs-linux-lts.img
# Just remove the -lts for regular linux
# NOTE: while you are there add mitigations=off
# Installing LTS
paru -Syu --needed --noconfirm linux-lts{,-headers} nvidia-lts
paru -Syu --needed --noconfirm linux-lts{,-headers}
# If you need to remove linux
pacu linux{,-headers} nvidia
#}}}

## power{{{
# keyword: battery, powertop, power
paru -Syu --needed --noconfirm cpupower laptop-mode-tools
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
# See also `laptop-mode`
paru -Syu --needed --noconfirm acpid
sudo systemctl enable --now acpid
sudo systemctl status acpid
sudo systemctl enable --now laptop-mode
sudo systemctl status laptop-mode
#}}}

# Install old packages???: {{{
# NOTE: ONLY do this on computers already setup, DONOT copy packages from another PC
# NOTE: Go to `sudo vim /etc/pacman.conf` and uncomment `multilib`
# Also add the ParallelDownloads = 5 option
# Also uncomment Color option
# Also add ILoveCandy option
# Also add:
# CacheDir    = /home/reinaldo/.mnt/skywafer/NetBackup/pacman_cache/x86_64
# CacheDir    = /var/cache/pacman/pkg/
sudo nvim /etc/pacman.conf
# NOTE: This will take a long time
sudo pacman-key --refresh-keys
sudo pacman -Syu archlinux-keyring && sudo pacman -Syu
sudo pacman -S --needed - < ~/.config/dotfiles/pkg/aero/pacman-list.pkg
paru -S --needed - < ~/.config/dotfiles/pkg/aero/aur-list.pkg
# NOTE: You still need to go through the rest of these steps to enable systemctl
# stuff
# }}}

# Setup Terminal {{{
# Install a decent neovim
$HOME/.config/dotfiles/scripts/nix/installs/arch/coding/coding.sh -z
$HOME/.config/dotfiles/scripts/nix/installs/arch/coding/neovim.sh
$HOME/.config/dotfiles/scripts/nix/installs/arch/coding/coding.sh -e
# }}}

# Protects from running out of memory{{{
paru -Syu --needed --noconfirm earlyoom
sudo systemctl enable --now earlyoom
sudo systemctl status earlyoom
#}}}

# lightdm{{{
paru -Syu --needed lightdm
sudo systemctl enable lightdm

# add your user to the autologin group
sudo groupadd -r autologin
sudo gpasswd -a reinaldo autologin

# Create
# Valid session names under /usr/share/xsessions/*.desktop
sudo nvim /etc/lightdm/lightdm.conf

# [Seat:*]
# autologin-user=reinaldo
# autologin-session=i3-with-shmlog
#}}}

# Video card{{{
# xorg{{{
# Multi Monitor setup, or for HiDPI displays it's best to auto calculate 
# resolution
paru -Syu --needed xorg-xrandr arandr xlayoutdisplay
paru -Syu --needed --noconfirm xorg xorg-apps xorg-xinit xorg-drivers xorg-server
/usr/bin/xlayoutdisplay
# NOTE: Follow instructions to setup the 52-monitors.conf and .Xresources
nvim $HOME/.config/dotfiles/scripts/nix/xorg-monitor-settings
# Set DPI in .Xresources
# Set resolution in 52-monitors.conf
cp $HOME/.config/dotfiles/scripts/nix/xorg-monitor-settings/.Xresources $HOME
sudo cp $HOME/.config/dotfiles/scripts/nix/xorg-monitor-settings/52-monitors.conf \
    /etc/X11/xorg.conf.d
#}}}

# Follow instructions and configure xorg
lspci -k | grep -A 2 -E "(VGA|3D)"
# If you happen to see 2 cards here, follow instructions at [this](https://wiki.archlinux.org/index.php/Optimus)
# Should be good
# With the predator you should also do:
# **Nvidia drivers**
# [Instructions](https://wiki.archlinux.org/index.php/NVIDIA)
# ***LTS*** needed if you are running linux-lts
# NVIDIA {{{
paru -Syu --needed --noconfirm nvidia-lts
# Otherwise use this one....**DO NOT USE BOTH**
paru -Syu --needed --noconfirm nvidia
paru -Syu --needed --noconfirm nvidia-libgl lib32-nvidia-libgl lib32-nvidia-utils \
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
paru -Syu --needed --noconfirm bumblebee mesa \
  lib32-{virtualgl,nvidia-utils,primus} primus
paru -Syu --needed --noconfirm bbswitch
# Add your user to the `bumblebee` group:
gpasswd -a <user> bumblebee
gpasswd -a reinaldo bumblebee
sudo systemctl enable --now bumblebeed
# manually turn on/off gpu
sudo tee /proc/acpi/bbswitch <<< {ON,OFF}
# checkout [this][1] link for hardware acceleration
#}}}

# hardware {{{
paru -Syu --needed --noconfirm fwupd
# }}}

# AMD
paru -Syu --needed --noconfirm lib32-mesa mesa
paru -Syu --needed --noconfirm xf86-video-amdgpu
paru -Syu --needed --noconfirm lib32-vulkan-radeon vulkan-radeon vulkan-mesa-layers
paru -Syu --needed --noconfirm lib32-libva-mesa-driver libva-mesa-driver \
  mesa-vdpau lib32-mesa-vdpau
paru -Syu --needed --noconfirm radeontop

#}}}

# nfs/samba {{{
paru -Syu --needed --noconfirm nfs-utils texlive
mkdir -p $HOME/.mnt/skynfs
mkdir -p $HOME/.mnt/skywafer/{home,music,shared,video}
sudo bash -c 'printf "\n//192.168.1.139/NetBackup /home/reinaldo/.mnt/skywafer/NetBackup cifs workgroup=WORKGROUP,uid=1000,gid=985,nofail,x-systemd.device-timeout=10,noauto,x-systemd.automount,_netdev 0 0" >> /etc/fstab'
sudo bash -c 'printf "\n//192.168.1.139/home /home/reinaldo/.mnt/skywafer/home cifs credentials=/etc/samba/credentials/share,workgroup=WORKGROUP,uid=1000,gid=985,nofail,x-systemd.device-timeout=10,noauto,x-systemd.automount,_netdev 0 0" >> /etc/fstab'
sudo bash -c 'printf "\n//192.168.1.139/music /home/reinaldo/.mnt/skywafer/music cifs credentials=/etc/samba/credentials/share,workgroup=WORKGROUP,uid=1000,gid=985,nofail,x-systemd.device-timeout=10,noauto,x-systemd.automount,_netdev 0 0" >> /etc/fstab'

# Try it with
sudo mount -v -t nfs 192.168.1.139:/volume1/backup /home/reinaldo/.mnt/skynfs \
  -o vers=3
sudo mount -t cifs //192.168.1.139/home ~/.mnt/skywafer/home -o credentials=/etc/samba/credentials/share,workgroup=WORKGROUP,uid=1000,gid=985,nofail,x-systemd.device-timeout=10,noauto,x-systemd.automount,_netdev,vers=3.0
mv ~/.gnupg{,_orig}
cp -r /home/reinaldo/.mnt/skywafer/home/bkps/aero/latest/.{ssh,password-store,gnupg} /home/reinaldo
cp -r /home/reinaldo/.mnt/skywafer/home/bkps/aero/latest/doublecmd /home/reinaldo/.config
sudo chown -R reinaldo: ~/.{ssh,gnupg}
chmod 700 ~/.ssh
chmod 600 -R ~/.ssh/*
chmod 644 -f ~/.ssh/*.pub ~/.ssh/authorized_keys ~/.ssh/known_hosts
sudo chown -R reinaldo: ~/.local/share/password-store
chmod 700 -R ~/.local/share/password-store
chmod 700 -R ~/.gnupg
sudo mount -t cifs //192.168.1.139/home ~/.mnt/skywafer/home -o credentials=/etc/samba/credentials/share,workgroup=WORKGROUP,uid=1000,gid=985,nofail,x-systemd.device-timeout=10,noauto,x-systemd.automount,_netdev
mkdir -p ~/Documents
# ln -s ~/.mnt/skywafer/home/Drive/wiki ~/Documents
paru -Syu --needed --noconfirm synology-drive
#}}}

#############################################################################
########## At this point is a good idea to login and continue with ssh ######
#############################################################################
# Otherwise, you'll have to enter root password infinitely,
# also systemctl stuff wont work
# If you don't get a login prompt use Ctrl-Alt-FX to get one

# `ssh` {{{
paru -Syu --needed --noconfirm openssh mosh
# - Actually use `mosh` is much faster
# - If you want this setup to be `ssh` accessible:
# - `systemctl enable sshd.socket`
# - `systemctl enable sshd`
# - Add to `.ssh/config`
# - `AddKeysToAgent yes`
# }}}

# install polkit {{{
paru -Syu --needed --noconfirm lxqt-policykit
# }}}

# Tue Mar 26 2019 21:49
# The rest is taken care of at `.xinitrc`
paru -Syu --needed --noconfirm numlockx

# i3-wm{{{
# Desktop
# screenshots, i3
# After this steps you should have a working `i3` setup.
paru -Syu --needed --noconfirm i3-wm i3lock-fancy-git rofi rofi-dmenu alttab-git xdotool jq
paru -Syu --needed --noconfirm archlinux-wallpaper
paru -Syu --needed --noconfirm feh redshift qrencode xclip dunst libnotify
paru -Syu --needed --noconfirm scrot flameshot tdrop ncpamixer qalculate-qt
paru -Syu --needed --noconfirm playerctl xfce4-settings python-pywal
paru -Syu --needed --noconfirm paper-icon-theme
paru -Syu --needed --noconfirm lxappearance pcmanfm
paru -Syu --needed --noconfirm bibata-extra-cursor-theme xfce4-settings
# Replacement for htop. Execute: btm
paru -Syu --needed --noconfirm htop-vim
# Compton changed name to picom
paru -Syu --needed --noconfirm picom
paru -Syu --needed --noconfirm xss-lock
paru -Syu --needed --noconfirm firefox

# Laptops
## Brightness
paru -Syu --needed --noconfirm brillo
# Add your user to the video group not to have to use sudo
sudo gpasswd -a reinaldo video
# see `man brillo`

# mimeo to handle default applications
# keyword: xdg-open
paru -Syu --needed --noconfirm mimeo xdg-utils-mimeo
# determine a file's MIME type
mimeo -m photo.jpeg
photo.jpeg
  image/jpeg

# choose the default application for this MIME type
mimeo --add image/jpeg feh.desktop

# open a file with its default application
mimeo photo.jpeg
# Sample usage
# Deprecated
# `cbatticon `
# `paystray`
# `blueberry`
#}}}

# fonts {{{
sudo pacman -S "$(pacman -Ssq noto-fonts-\*)"
# }}}

# Bluetooth/Audio {{{
## Pipewire
# Do replace pipewire-media-sessions for wireplumber
paru -Syu --needed pipewire pipewire-{pulse,jack,alsa,audio} lib32-pipewire wireplumber
## PulseAudio
# paru -Syu --needed --noconfirm pulseaudio pulseaudio-{bluetooth,jack,alsa,equalizer}

#Blue
paru -Syu --needed --noconfirm bluez bluez-libs bluez-utils bluez-firmware
paru -Syu --needed --noconfirm blueman
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

#############################################################################
########## At this point you should have a basic system ######
#############################################################################
# From this point onward everything is considered advanced or fancy

# resilio {{{
# See `random.md resilio` section
# }}}

## firefox {{{
paru -Syu --needed --noconfirm firefox speech-dispatcher festival festival-us
paru -Syu --needed --noconfirm hunspell-en_us
# paru -Syu --needed --noconfirm firefox-extension-privacybadger`
# paru -Syu --needed --noconfirm libnotify speech-dispatcher festival`
paru -Syu --needed --noconfirm vdhcoapp-bin
# Move profile to ram, for chrome and firefox
paru -Syu --needed --noconfirm profile-sync-daemon
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
paru -Syu --needed --noconfirm qutebrowser pdfjs
#}}}

# evolution {{{
paru -Syu --needed --noconfirm evolution gnome-keyring libsecret
# NOTE: you want to setup a "Collection Account", not just a regular email
# account. This way it pulls calendar and tasks
# ACTION: setup empty password so that `lightdm` can unlock the `keyring` at login
# Run through the normal setup and when the "Default Keyring" setup comes, just 
# leave empty
evolution
# }}}

# password-store {{{
paru -Syu --needed --noconfirm --needed pass rofi-pass
## Passwords
# pass-import most likely you'll have to download from git page
paru -Syu --needed --noconfirm python-pykeepass
paru -Syu --needed --noconfirm pass keepassxc pass-import pass-update
## Root passwd
# - ~~`install openssh-askpass`~~
# - Tue Mar 26 2019 08:53
paru -Syu --needed --noconfirm lxqt-openssh-askpass
#}}}

# pipewire {{{
paru -Syu --needed --noconfirm pipewire
paru -Syu --needed --noconfirm pamixer alsa-lib libao libcdio libcddb libvorbis \
    libmpcdec wavpack libmad libmodplug libmikmod
    # }}}

# polybar{{{
# NOTE: For new hostnames you will to tweak polybar/config and 
# polybar/modules.ini
paru -Syu --needed --noconfirm jsoncpp polybar alsa-utils paprefs
paru -Syu --needed --noconfirm alsa-lib wireless_tools curl pacman-contrib
paru -Syu --needed --noconfirm ttf-weather-icons jq
paru -Syu --needed --noconfirm ttf-iosevka
paru -Syu --needed --noconfirm python-pywal galendae-git
wal --theme base16-google -l -q -o "$HOME/.config/polybar/launch.sh"
# usb automount
# There's a polybar module that will be used to mount/umount devices
paru -Syu --needed --noconfirm gvfs-mtp gvfs-gphoto2 udisks2 pcmanfm
sudo install -Dm644 /home/reinaldo/.config/polybar/scripts/95-usb.rules /etc/udev/rules.d/95-usb.rules
#}}}

# windows virtual machine {{{
# You can download images from: 
# https://developer.microsoft.com/en-us/windows/downloads/virtual-machines/
# **NOTE** host-modules-arch is for when you have a linux kernel installed.
# **NOTE** If you have an intel 11th gen CPU add `ibt=off` to boot kernel params
paru -Syu --needed vagrant virtualbox{,-host-modules-arch}
# As opposed to any other kenerl, like lts, zen, etc... use the one below
paru -Syu --needed virtualbox{,-host-dkms} virtualbox-guest-iso
sudo modprobe vboxdrv
sudo groupadd -r vboxdrv
sudo gpasswd -a reinaldo vboxdrv
# For USB access
sudo gpasswd -a reinaldo vboxusers
# Not needed anymore for USB3 access
# paru -Syu virtualbox-ext-oracle
# }}}

# quickemu virtual machines {{{
paru -Syu quickemu qemu-full
quickget nixos 23.11 minimal
quickemu --vm nixos-23.11-minimal.conf --display none
# }}}

# Audio/Music{{{
paru -Syu --needed --noconfirm cmus playerctl pipewire
paru -Syu --needed --noconfirm pamixer alsa-lib libao libcdio libcddb libvorbis \
  libmpcdec wavpack libmad libmodplug libmikmod pavucontrol
# mpv-mpris is a plugin that adds mpris support to mpv. This allows playerctl to 
# control it
paru -Syu --needed --noconfirm mpv mpv-mpris

# Download music
paru -Syu --needed --noconfirm python-spotdl

paru -Syu --needed --noconfirm spotify
# Spotify theme
paru -Syu --needed --noconfirm spicetify-{cli,themes-git}
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
#}}}

# email {{{
# neomutt {{{
paru -Syu --needed --noconfirm neomutt abook urlscan lynx \
  isync goimapnotify
# Needed to backup emails
# paru -Syu --needed --noconfirm offlineimap
mkdir -p ~/.local/share/mail/{molinamail,molinamail_meli,molinamail_mcp}/inbox
/usr/bin/mbsync -D -ac ~/.config/isync/mbsyncrc
#}}}

# calendar/contacts {{{
paru -Syu --needed vdirsyncer
mkdir -p ~/.local/share/vdirsyncer/{status,calendar,contacts}
sudo bash -c 'printf "pass show \"\$@\" | head -n 1" > /usr/lib/password-store/extensions/first-line.bash'
sudo chmod +x /usr/lib/password-store/extensions/first-line.bash
vdirsyncer discover {contacts,calendars}
vdirsyncer sync

# Calendar, contacts and todo applications that read from vdir
paru -Syu --needed khal khard todoman
# }}}


# VPN {{{
paru -Syu --needed --noconfirm riseup-vpn
# wireguard
# Get conf file from router linux_pcs
# Put it at /etc/wireguard/home.conf
paru -Syu --needed --noconfirm wireguard-tools systemd-resolvconf
sudo systemctl status systemd-resolved.service
# The value for this ip is given by the ip assigned to the peer
# You can find it in the config file
# Not needed anymore
# sudo bash -c 'echo "nameserver 10.4.0.7" >> /etc/resolv.conf'
# sudo reboot
# Try it with:
sudo wg-quick up home
sudo wg-quick down home
sudo systemctl start wg-quick@home.service
sudo systemctl status wg-quick@home.service
sudo systemctl stop wg-quick@home.service
sudo chmod 700 /etc/wireguard/home.conf
sudo chmod 600 /etc/wireguard/home.conf
# }}}

## Mon Mar 04 2019 22:03 

# I have decided to give `thunderbird` a try.
# Out of frustration for delayed received notifications in `neomutt`
# And wonky `ui`

paru -Syu --needed --noconfirm thunderbird birdtray

# Office

paru -Syu --needed --noconfirm libreoffice-still hunspell hunspell-en_us

# pdf & resume
paru -Syu --needed --noconfirm zathura zathura-pdf-mupdf texlive pdfgrep qpdfview
# PDF annotations use:
# Don't install depends on python2
paru -Syu --needed --noconfirm xournal
# PDF searching: `install pdfgrep`
# PDF Merging:
# Sat Mar 02 2019 21:18
# **Please do not use `pdftk`**
# You seriously have to compile gcc6 for that 
# pdftk
# pdftk file1.pdf file2.pdf cat output mergedfile.pdf

# windows mount

paru -Syu --needed --noconfirm ntfs-3g

## Then you can just do to mount the windows partition
# mount /dev/<your_device> /mnt/win

# android

paru -Syu --needed --noconfirm android-tools android-udev

# journal

# Tue Mar 26 2019 08:58
# Auto clean up
sudo nvim /etc/systemd/journald.conf
# Add or uncomment `SystemMaxUse=2G`

# Browser{{{

# Printing{{{
# keywords: print, hp, cups
paru -Syu --noconfirm --needed hplip cups cups-pdf simple-scan gtk3-print-backends
# install most of the optional software that comes along with hplip
# Follow arch `cups` instructions.
# look it up in the arch wiki
sudo systemctl enable --now cups.socket cups.service
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

# docker
# https://wiki.archlinux.org/title/docker#With_NVIDIA_Container_Toolkit_(recommended)
paru -Syu --needed --noconfirm docker docker-buildx docker-compose nvidia-container-toolkit distrobox
# See here for fix performance issue building docker images
# https://mikeshade.com/posts/docker-native-overlay-diff/
sudo systemctl enable --now docker
# Rootless docker, needed for distrobox
sudo groupadd docker
sudo usermod -aG docker $USER
 
# anki {{{
# Official
paru -Syu --needed --noconfirm anki-official-binary-bundle

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
paru -Syu --needed --noconfirm npm
npm install -g md2apkg fast-cli
#}}}

## 💲 Stonks {{{
paru -Syu --needed --noconfirm tickrs
#}}}

## gui mock ups design{{{
# - [here][0]
paru -Syu --needed --noconfirm pencil
#}}}

## check files duplicates{{{
# - Mon Jun 10 2019 09:59
paru -Syu --needed --noconfirm fdupes
#}}}

## Diagrams{{{
# - Sun Mar 17 2019 18:26
# - keyword: graphics, graph, editor
# - Mainly for stuff that `plantuml` cannot do
paru -Syu --needed --noconfirm yed
#}}}

## Preload{{{
# - Wed May 02 2018 06:04
# - Cool application.
paru -Syu --needed --noconfirm preload
# - Can be done as user level
sudo systemctl enable --now preload
#}}}

## Youtube-dl{{{
paru -Syu --needed --noconfirm youtube-dl ytmdl ytfzf
#}}}

## Screen recording{{{
# -  Application to record and share cools screen captures
paru -Syu --needed --noconfirm asciinema
#}}}

## Disk Usage Utility{{{
paru -Syu --needed --noconfirm baobab
#}}}

## Steam{{{
paru -Syu steam ttf-liberation steam-fonts
## IF AMD
paru -Syu xf86-video-amdgpu lib32-mesa mesa
# If NVIDIO
paru -Syu lib32-nvidia-utils nvidia-utils
#}}}

## Video playing{{{
paru -Syu --needed --noconfirm vlc
#}}}

## wine{{{
# Make sure WINEPREFIX exists
paru -Syu --needed --noconfirm wine wine-gecko winetricks wine-mono
paru -Syu --needed --noconfirm lib32-lib{pulse,xrandr}
paru -Syu --needed --noconfirm dxvk-bin
setup_dxvk install
# Temp directory on tmpfs
rm -r "$WINEPREFIX/drive_c/users/$USER/Temp"
ln -s /tmp/wintemp "$WINEPREFIX/drive_c/users/$USER/Temp"
# Fix fonts
bash -c 'cd ${WINEPREFIX:-~/.wine}/drive_c/windows/Fonts && for i in /usr/share/fonts/**/*.{ttf,otf}; do ln -s "$i" ; done'
export FREETYPE_PROPERTIES="truetype:interpreter-version=35"
winetricks corefonts
winetricks settings fontsmooth=rgb
#}}}

## maintenence{{{
paru -Syu --needed --noconfirm bleachbit
#}}}

## Android{{{
paru -Syu --needed --noconfirm android-tools android-udev
#}}}

## Android-Dev{{{
paru -Syu --needed --noconfirm android-studio android-sdk
# - Remember: `~/.bashrc`->`export ANDROID_HOME=<sdk-location>`
#}}}

# Xilinx {{{
# Download instructions: https://wiki.hevs.ch/uit/index.php5/Tools/Xilinx_ISE/Installation_Linux
# Actually follow instructions on wiki
# Download software from: https://www.xilinx.com/support/download.html
# Put the software tar file next to the xilinx-ise PKBUILD
# Then follow instructions for xilinx jtag-usb programmer
paru -Syu ncurses5-compat-libs xilinx-ise
# }}}

## syslog{{{
### Fri Oct 25 2019 14:35\
# - `paru -Syu --needed --noconfirm syslog-ng`
# - `sudo systemctl enable --now syslog-ng@default.service`
# - now when you log with `openlog()` and/or `syslog()` you can see it in `journalctl`}}}
#}}}

# [0]: https://pencil.evolus.vn/
# [1]: https://wiki.archlinux.org/index.php/Hardware_video_acceleration

# pihole-server {{{

paru -Syu --needed pi-hole-server php-sqlite lighttpd php-cgi
# Web interface
# enable relevant sections
sudo nvim /etc/php/php.ini
# NOTE: Search extensions, and add these below to the end
extension=pdo_sqlite
extension=sockets
extension=sqlite3

# NOTE: search for open_basedir
open_basedir = /srv/http/pihole:/run/pihole-ftl/pihole-FTL.port:/run/log/pihole/pihole.log:/run/log/pihole-ftl/pihole-FTL.log:/etc/pihole:/etc/hosts:/etc/hostname:/etc/dnsmasq.d/02-pihole-dhcp.conf:/etc/dnsmasq.d/03-pihole-wildcard.conf:/etc/dnsmasq.d/04-pihole-static-dhcp.conf:/var/log/lighttpd/error-pihole.log:/proc/loadavg:/proc/meminfo:/proc/cpuinfo:/sys/class/thermal/thermal_zone0/temp:/tmp

sudo cp /usr/share/pihole/configs/lighttpd.example.conf /etc/lighttpd/lighttpd.conf
sudo systemctl enable --now lighttpd
sudo systemctl status lighttpd

# Fix hosts, NOTE: change surbook for hostname
sudo nvim /etc/hosts
127.0.0.1              localhost
ip.address.of.pihole   pi.hole surbook

# NOTE: make sure the dns service is running fine
sudo systemctl enable pihole-FTL
sudo systemctl restart pihole-FTL
sudo systemctl status pihole-FTL

# Fix settings
sudo nvim /etc/pihole/pihole-FTL.conf
# NOTE: find MAXDBDAYS and set it to 45
# NOTE: find DBINTERVAL and set it to 10.0

# NOTE: Important fix for forgetting the upstream DNS even though is set in the
# gui
pihole_dns="127.0.0.1#5335"
pihole_srvc="pihole-dns-fix.service"
pihole_scr="/etc/systemd/system/${pihole_srvc}"
sudo bash -c "cat >> ${pihole_scr}" << EOL
[Unit]
Description=PiHole set upstream DNS
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/bin/pihole -a setdns ${pihole_dns}

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl daemon-reload
sudo systemctl enable --now ${pihole_srvc}
sudo systemctl status ${pihole_srvc}
journalctl -u ${pihole_srvc}
# }}}

# unbound {{{

paru -Syu --needed unbound
wget https://www.internic.net/domain/named.root -qO- | sudo tee /var/lib/unbound/root.hints
# Automate above setting
unbound_srvc="unbound-root-hints.service"
unbound_scr="/etc/systemd/system/${unbound_srvc}"
sudo bash -c "cat >> ${unbound_scr}" << EOL
[Unit]
Description=Unbound download latests root hints
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/bin/wget https://www.internic.net/domain/named.root -O /var/lib/unbound/root.hints

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl daemon-reload
sudo systemctl start ${unbound_srvc}
sudo systemctl status ${unbound_srvc}
journalctl -u ${unbound_srvc}

unbound_timer="unbound-root-hints.timer"
unbound_scr="/etc/systemd/system/${unbound_timer}"
sudo bash -c "cat >> ${unbound_scr}" << EOL
[Unit]
Description=Unbound download latests root hints once a month

[Timer]
# Run at midnight on the first day of each month
OnCalendar=*-*-01 00:00:00
Persistent=true

[Install]
WantedBy=timers.target
EOL

sudo systemctl daemon-reload
sudo systemctl enable --now ${unbound_timer}
sudo systemctl status ${unbound_timer}
journalctl -u ${unbound_timer}

# NOTE: ensure unbound main config includes pi hole config
sudo nvim /etc/unbound/unbound.conf
# NOTE: By adding the below line if not there
include: /etc/unbound/unbound.conf.d/*.conf

# Then follow instructions here: https://docs.pi-hole.net/guides/dns/unbound/
sudo mkdir -p /etc/unbound/unbound.conf.d
sudo nvim /etc/unbound/unbound.conf.d/pi-hole.conf

sudo systemctl enable --now unbound
sudo systemctl restart unbound
sudo systemctl status unbound

# Test it
dig pi-hole.net @127.0.0.1 -p 5335
# This one should fail
dig fail01.dnssec.works @127.0.0.1 -p 5335
# This one should pass
dig dnssec.works @127.0.0.1 -p 5335
dig google.com @127.0.0.1 -p 5335
# NOTE: now configure pihole Upstream DNS Server to
# 127.0.0.1#5335

# Ensure not active
systemctl is-active unbound-resolvconf.service
# }}}

# vim: fdm=marker
