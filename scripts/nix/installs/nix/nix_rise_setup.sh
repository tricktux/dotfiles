#!/usr/bin/env bash

# channel setup{{{
sudo nix-channel --add https://channels.nixos.org/nixos-unstable nixos
sudo nixos-rebuild switch --upgrade

sudo nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
sudo nix-channel --update
nix-shell '<home-manager>' -A install
cp /etc/nixos/hardware-configuration.nix ~/.config/dotfiles/<X>
~/.config/dotfiles/scripts/nix/arch.sh -p
# }}}

# install dotfiles{{{
# Download dotfiles
cd
mkdir -p ~/.{config,cache}
mkdir -p ~/Documents
mkdir -p ~/.local/share/Trash/files
cd ~/.config
git clone https://github.com/tricktux/dotfiles
# NOTE: Change link to: ssh://github/tricktux/dotfiles
nvim "$HOME/.config/dotfiles/.git/config"
# Backup current setup
# Make sure no other dotfiles are left
mv ~/.bash_logout{,_bak}
mv ~/.bash_profile{,_bak}
mv ~/.bashrc{,_bak}
# mv ~/.config/paru{,_}
# Install your configs
cd ~/.config/dotfiles
make stow-default
# Check that all went well
ls -als ~/
ls -als ~/.config
# Get your aliases
source ~/.bash_aliases
# Pass nvim config to root user as well to make `sudo nvim` usable
sudo mkdir -p /root/.config
sudo ln -s /home/reinaldo/.config/nvim /root/.config
#}}}


# Setup NetBackup {{{
# This is to get the server's cache to install stuff faster
mkdir -p $HOME/.mnt/skywafer/{home,music,shared,video,NetBackup}
sudo mount -t cifs //192.168.1.139/NetBackup ~/.mnt/skywafer/NetBackup -o credentials=/etc/samba/credentials/share,workgroup=WORKGROUP,uid=1000,gid=985,nofail,x-systemd.device-timeout=10,noauto,x-systemd.automount,_netdev
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


# zsh setup{{{
export ZDOTDIR=$HOME/.config/zsh
zsh
# }}}


# Video card{{{
lspci -k | grep -A 2 -E "(VGA|3D)"
nix-shell -p libva-utils --run "vainfo"
# }}}

# terminal utils{{{
# For ranger to have icons
git clone https://github.com/cdump/ranger-devicons2 ~/.config/ranger/plugins/devicons2
# Atuin
# Either restore the local/share/atuin folder from the backups
# or
# Giving it the path to zhist file
# HISTFILE=/path/to/history/file atuin import zsh
# }}}

# Restore files {{{
pc="surbook"
ls -als ~/.mnt/skywafer/home/bkps/${pc}
mv ~/.gnupg{,_orig}
cp -r /home/reinaldo/.mnt/skywafer/home/bkps/${pc}/latest/.{ssh,password-store,gnupg} /home/reinaldo
cp -r /home/reinaldo/.mnt/skywafer/home/bkps/${pc}/latest/doublecmd /home/reinaldo/.config
sudo chown -R reinaldo: ~/.{ssh,password-store,gnupg}
chmod 700 ~/.ssh
chmod 600 -R ~/.ssh/*
chmod 644 -f ~/.ssh/*.pub ~/.ssh/authorized_keys ~/.ssh/known_hosts
chmod 700 -R ~/.password-store
chmod 700 -R ~/.gnupg
# }}}

# restic restore {{{
# Auto restore all of these files?
    restore_srcs=(
        "$HOME/.gnupg" "$HOME/.ssh" "$HOME/.password-store" "/tmp/pacman_database.tar.bz2"
        "$HOME/.local/share/histfile" "$HOME/.local/share/z" "$HOME/.config/doublecmd"
        "$HOME/.password-store_work" "$HOME/.local/share/atuin"
        "$HOME/.password-store_mine"
        "$HOME/.screenshots"
        "$HOME/.screenlayout"
        "$HOME/.local/share/remmina"
        "$HOME/Documents"
        "$HOME/Downloads"
    )
    repo=""
    pass=""
    # Assign repo based on the current hostname
    case $HOSTNAME in
        "xps")
            repo="$HOME/.mnt/work/drobo-B810n/Public/rmolina/bkps/$HOSTNAME/restic-repo"
            export PASSWORD_STORE_DIR=$HOME/.password-store_work
            pass="pass work/drobo/xps-restic-repo"
            ;;
        *)
            repo="$HOME/.mnt/skywafer/home/bkps/$HOSTNAME/repo"
            pass="pass linux/$HOSTNAME/restic"
            ;;
    esac
    # The latest snapshot can be obtained by running: restic snapshots --json | jq -r '.[-1].id'
    snap_id=<put_latest_snapshot_id_here>
    restore_path="$HOME/restore"
    # Loop through the list of sources and attempt to restore each
    for src in "${restore_srcs[@]}"; do
        target_path="$restore_path${src/$HOME/}"
        if [ -f "$target_path" ] || [ -d "$target_path" ]; then
            # File/directory already exists in the restore location, add a timestamp to the original.
            mv "$target_path" "${target_path}_$(date '+%Y-%m-%d_%H-%M-%S')"
        fi
        echo "Restoring $src from snapshot $snap_id to $restore_path"
        $RESTIC --verbose --cleanup-cache --password-command "$pass" --repo "$repo" restore $snap_id --target="$restore_path" --include="$src"
    done
# }}}

# wireguard {{{
# Get conf file from router linux_pcs
# Put it at /etc/wireguard/home.conf
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


# choose the default application for this MIME type {{{
mimeo --add image/jpeg feh.desktop

# open a file with its default application
mimeo photo.jpeg
# Sample usage
# Deprecated
# `cbatticon `
# `paystray`
# `blueberry`
#}}}

# polybar{{{
# NOTE: For new hostnames you will to tweak polybar/config and 
# polybar/modules.ini
wal --theme base16-google -l -q -o "$HOME/.config/polybar/launch.sh"
# usb automount
# There's a polybar module that will be used to mount/umount devices
paci --needed --noconfirm gvfs-mtp gvfs-gphoto2 udisks2 pcmanfm
sudo install -Dm644 /home/reinaldo/.config/polybar/scripts/95-usb.rules /etc/udev/rules.d/95-usb.rules
#}}}
