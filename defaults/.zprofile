#
# ~/.zprofile
#

# Global exports

# Prevent double entries in $PATH
typeset -U path

# Creating local bin folder
# If user ID is greater than or equal to 1000 & if ~/.local/bin exists and is a
# directory & if ~/.local/bin is not already in your $PATH
# then export ~/.local/bin to your $PATH.
if [[ $UID -ge 1000 && -d $HOME/.local/bin && -z $(echo $PATH \
	| grep -o $HOME/.local/bin) ]]
then
	export PATH="$HOME/.local/bin:${PATH}"
fi

# Sat Oct 14 2017 11:12: This will set the i3-sensible-terminal to be used:
# Termite has priority over kitty
[ -f /usr/bin/urxvtc ] && export TERMINAL="urxvtc"
[ -f /usr/bin/termite ] && export TERMINAL="termite"
[ -f /usr/bin/kitty ] && export TERMINAL="kitty"

[ -f /usr/bin/firefox ] && export BROWSER="/usr/bin/firefox"

# Thu Feb 01 2018 05:21: For oracle database crap for school
if [[ -d  "/home/reinaldo/app" ]]; then
	export ORACLE_HOME=/home/reinaldo/app/reinaldo/product/12.2.0/client_1
fi

export NVIM_LISTEN_ADDRESS=/tmp/nvimsocket

# Ranger load only ~/.config/ranger/rc.conf
export RANGER_LOAD_DEFAULT_RC=FALSE

# Fixes git weird issue
export GIT_TERMINAL_PROMPT=1

# urxvtd
export RXVT_SOCKET="/tmp/rxvt_socket"

export SUDO_ASKPASS=/usr/bin/lxqt-openssh-askpass
export SSH_ASKPASS=/usr/bin/lxqt-openssh-askpass

# export GDK_SCALE=1.5
# export QT_AUTO_SCREEN_SCALE_FACTOR=1

# Exports
# Man settings
export MANPATH=/usr/local/man:/usr/local/share/man:/usr/share/man:/usr/man
# export MANPAGER="nvim -c 'set ft=man' -"

# Adb, fastboot
# Fixes vim-javacomplete2 issues
# Remember to launch nvim at the code base
export JAVA_HOME=/usr/lib/jvm/default
if [[ -d "$HOME/Downloads/packages/android-sdk-linux" ]]; then
	export ANDROID_HOME=$HOME/Downloads/packages/android-sdk-linux
	export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
fi

# Depends on nvr being installed
# Mon Jun 25 2018 21:51: Basically what this does is to ensure a unique global 
# instance of neovim. No matter from where you call nvim. If there is one open 
# it will open files there. the original option looked like this:
# export VISUAL="nvr -cc tabedit --remote-wait +'set bufhidden=wipe'"
# However, that wipe will delete the buffer if you exit it. I dont like that.
if [[ -n "$NVIM_LISTEN_ADDRESS" && -f "$HOME/.local/bin/nvr" ]]; then
	export VISUAL="nvr -s $@"
else
	export VISUAL="nvim"
fi

# Allow me to have multiple instances
# alias nvim="$VISUAL"
# export VISUAL=nvim
export EDITOR=$VISUAL

# i3 position and size variables
if [ `hostname` = "predator" ]; then
  # Terminal
  terminal_width=3840
  terminal_height=800
  terminal_posy=48
  # Htop
  htop_width=3640
  htop_height=1024
else
  # Assumes helios here
  # Terminal
  terminal_width=1920
  terminal_height=440
  terminal_posy=32
  # Htop
  htop_width=1820
  htop_height=880
fi

# Delete existing setup
# NOTE: If you add more variables update the number of lines to delete
sed -i '44,48d' ~/.config/i3/config
# Now add the new values
sed -i '44s/^/set $terminal_width '"$terminal_width"'\n/' ~/.config/i3/config
sed -i '44s/^/set $terminal_height '"$terminal_height"'\n/' ~/.config/i3/config
sed -i '44s/^/set $terminal_posy '"$terminal_posy"'\n/' ~/.config/i3/config
sed -i '44s/^/set $htop_width '"$htop_width"'\n/' ~/.config/i3/config
sed -i '44s/^/set $htop_height '"$htop_height"'\n/' ~/.config/i3/config

# Thu Feb 22 2018 08:59: Can't figure out how to set locale properly on arch. 
# Result:
# Wed May 02 2018 04:57: Not needed anymore
# export LANG=en_US.UTF-8

if [ -z "$DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ]; then
	exec startx
	# XKB_DEFAULT_LAYOUT=us exec sway
fi
