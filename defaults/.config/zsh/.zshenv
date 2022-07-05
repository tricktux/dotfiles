
#
# ~/.zshenv
#
# Important note: zshenv is sourced everytime you open a new terminal
# Only export things from zshenv host
if [ -f "$ZDOTDIR/.zshenv_$HOST" ]; then
  source "$ZDOTDIR/.zshenv_$HOST"
fi

# Creating local bin folder
# If user ID is greater than or equal to 1000 & if ~/.local/bin exists and is a
# directory & if ~/.local/bin is not already in your $PATH
# then export ~/.local/bin to your $PATH.
if [[ $UID -ge 1000 && -d $HOME/.local/bin && \
  -z $(echo $PATH | grep -o $HOME/.local/bin) ]]
then
  export PATH="$HOME/.local/bin:${PATH}"
fi

# XDG settings: https://wiki.archlinux.org/index.php/XDG_Base_Directory
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_DATA_DIRS="/usr/local/share:/usr/share"
export XDG_CONFIG_DIRS="/etc/xdg"

# Sat Oct 14 2017 11:12: This will set the i3-sensible-terminal to be used:
# Termite has priority over kitty
[ -f /usr/bin/urxvtc ] && export TERMINAL="/usr/bin/urxvtc"
[ -f /usr/bin/termite ] && export TERMINAL="/usr/bin/termite"
[ -f /usr/bin/kitty ] && export TERMINAL="/usr/bin/kitty"

[ -f /usr/bin/firefox ] && export BROWSER="/usr/bin/firefox"

# Thu Feb 01 2018 05:21: For oracle database crap for school
if [[ -d  "/home/reinaldo/app" ]]; then
  export ORACLE_HOME=/home/reinaldo/app/reinaldo/product/12.2.0/client_1
fi

# Ranger do not load the default rc.conf
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

# Firefox variables
export MOZ_WEBRENDER=1
export MOZ_X11_EGL=1

# Depends on nvr being installed
# Mon Jun 25 2018 21:51: Basically what this does is to ensure a unique global
# instance of neovim. No matter from where you call nvim. If there is one open
# it will open files there. the original option looked like this:
# export VISUAL="nvr -cc tabedit --remote-wait +'set bufhidden=wipe'"
# However, that wipe will delete the buffer if you exit it. I dont like that.
# Tue Oct 20 2020 08:43: Can't get the command to work with `pass`. Therefore 
# changing it to regular nvim. Anyways git and ranger use different commands
# if [[ -n "$NVIM_LISTEN_ADDRESS" && -f "/usr/bin/nvr" ]]; then
  # export VISUAL="/usr/bin/nvr --remote-tab-wait-silent +'set bufhidden=delete' $@"
# else
  # export VISUAL="nvim"
# fi
export VISUAL="nvim"

# Allow me to have multiple instances
# alias nvim="$VISUAL"
# export VISUAL=nvim
export EDITOR=$VISUAL

# Don't put stuff in home dir go
export GOPATH="$XDG_DATA_HOME/go"

# Don't put stuff in home dir rust
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"

if [[ -d /usr/lib/ccache/bin ]]; then
  export PATH="/usr/lib/ccache/bin/:$PATH"
  export CCACHE_DIR=/tmp/ccache
  export CCACHE_SLOPPINESS=file_macro,locale,time_macros 
  export CCACHE_MAXSIZE=5.0G
fi

# Fix typos in cli
ENABLE_CORRECTION="true"

# root directory for bytecode cache (pyc) files.
export PYTHONPYCACHEPREFIX="/tmp/pycache"
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc"
# This can come back to hunt you down. No asserts or docstrings
# Tue Dec 22 2020 14:39: Ohhh and it did! So hard. gdb stopped working 
# export PYTHONOPTIMIZE=2

# pacdiff variables
export DIFFPROG="nvim -d"
export DIFFSEARCHPATH="/boot /etc /usr"

# jupyter
export JUPYTERLAB_DIR=$HOME/.local/share/jupyter/lab

# As given by the output of tzselect
export TZ='America/New_York'

# Wine
export WINEPREFIX="$XDG_DATA_HOME/wine"

# npm: https://wiki.archlinux.org/title/Node.js#Node_Packaged_Modules
export npm_config_prefix="$HOME/.local"

export DOOMDIR="$XDG_CONFIG_HOME/doom"

# Thu Feb 22 2018 08:59: Can't figure out how to set locale properly on arch.
# Result:
# Wed May 02 2018 04:57: Not needed anymore
# export LANG=en_US.UTF-8

export BAT_THEME="base16"

# QT5 dark mode
export QT_QPA_PLATFORMTHEME=gtk2

# Less hist file
export LESSHISTFILE="$HOME"/.local/share/lesshst
export LESSHISTSIZE=1000

# vim: fdm=marker
