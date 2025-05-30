export HOSTNAME=$(hostname)

# Tue May 19 2020 06:24:
#   Switched to lightdm
export ZDOTDIR=$HOME/.config/zsh

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
export XDG_STATE_HOME="$HOME/.local/state"

# Sat Oct 14 2017 11:12: This will set the i3-sensible-terminal to be used:
# Termite has priority over kitty
[ -x $(command -v urxvtc) ] && export TERMINAL="urxvtc"
[ -x $(command -v termite) ] && export TERMINAL="termite"
[ -x $(command -v kitty) ] && export TERMINAL="kitty"

[ -x $(command -v firefox) ] && export BROWSER="firefox"

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

# export SUDO_ASKPASS=/usr/bin/lxqt-openssh-askpass
# export SSH_ASKPASS=/usr/bin/lxqt-openssh-askpass

# export GDK_SCALE=1.5
# export QT_AUTO_SCREEN_SCALE_FACTOR=1

# Exports
# Man settings
# export MANPATH=/usr/local/man:/usr/local/share/man:/usr/share/man:/usr/man
export MANPAGER='nvim +Man!'

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

# Wine
export WINEPREFIX="$XDG_DATA_HOME/wine"

# npm: https://wiki.archlinux.org/title/Node.js#Node_Packaged_Modules
export npm_config_prefix="$HOME/.local"

export DOOMDIR="$XDG_CONFIG_HOME/doom"

export BAT_THEME="base16"

# QT5 dark mode
if [[ ! -d /etc/nixos/ ]]; then
  export QT_QPA_PLATFORMTHEME=gtk3
  export QT_STYLE_OVERRIDE=
fi

# Less hist file
export LESSHISTFILE="$XDG_DATA_HOME"/lesshst
export LESSHISTSIZE=1000

# CMAKE always export compile json
export CMAKE_EXPORT_COMPILE_COMMANDS=ON

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


# Dotnet
export DOTNET_ROOT="$XDG_DATA_HOME"/dotnet
export PATH="$PATH":"$DOTNET_ROOT"/tools
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_CLI_HOME="$XDG_DATA_HOME"/dotnet

# Cleaning up on home through xdg-ninja
export HISTFILE="${XDG_STATE_HOME}"/bash/history
mkdir -p "${XDG_STATE_HOME}"/bash
export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
export CUDA_CACHE_PATH="$XDG_CACHE_HOME"/nv
export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc
mkdir -p "$XDG_CONFIG_HOME"/gtk-2.0
# TODO: nix?
export XCURSOR_PATH=/usr/share/icons:$XDG_DATA_HOME/icons
export IPYTHONDIR="$XDG_CONFIG_HOME/ipython"
export MYPY_CACHE_DIR="$XDG_CACHE_HOME"/mypy
export NUGET_PACKAGES="$XDG_CACHE_HOME"/NuGetPackages
export OMNISHARPHOME="$XDG_CONFIG_HOME"/omnisharp
export PASSWORD_STORE_DIR="$XDG_DATA_HOME"/password-store
export INPUTRC="$XDG_CONFIG_HOME"/readline/inputrc
mkdir -p "$XDG_CONFIG_HOME"/readline
export VAGRANT_HOME="$XDG_DATA_HOME"/vagrant
mkdir -p "$XDG_DATA_HOME"/vagrant
export W3M_DIR="$XDG_DATA_HOME"/w3m
export XSERVERRC="$XDG_CONFIG_HOME"/X11/xserverrc
export XINITRC="$XDG_CONFIG_HOME"/X11/xinitrc
mkdir -p "$XDG_CONFIG_HOME"/X11
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME"/npm/npmrc
export TERMINFO="$XDG_DATA_HOME"/terminfo
export TERMINFO_DIRS="$XDG_DATA_HOME"/terminfo:/usr/share/terminfo
export TEXMFVAR="$XDG_CACHE_HOME"/texlive/texmf-var
export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME"/java
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME"/jupyter
export JUPYTERLAB_DIR="$XDG_CONFIG_HOME"/jupyter/lab
export ANDROID_USER_HOME="$XDG_DATA_HOME"/android

# git clone https://github.com/microsoft/vcpkg --depth 1 $VCPKG_ROOT
export VCPKG_ROOT=$HOME/.local/share/vcpkg

# Nix local fix for arch
export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive

[[ -f "$HOME"/.local/etc/xprofile-extra ]] && source $HOME/.local/etc/xprofile-extra
