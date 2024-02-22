
# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#{{{compinstall
# The following lines were added by compinstall

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' max-errors 2
zstyle ':completion:*' completer _complete _correct _approximate
zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' completer _expand_alias _complete _approximate
zstyle ':completion:*' menu select
zstyle ':completion:*' file-sort name
zstyle ':completion:*' ignore-parents pwd

# Autocompletion for sudo
zstyle ':completion::complete:*' gain-privileges 1

zstyle ':completion:*:pacman:*' force-list always
zstyle ':completion:*:*:pacman:*' menu yes select

zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*'   force-list always

zstyle ':completion:*:*:killall:*' menu yes select
zstyle ':completion:*:killall:*' force-list always
zstyle :compinstall filename '$HOME/.config/zsh/.zshrc'

#}}}

# My Zsh Options{{{
# Prevent double entries in $PATH
typeset -U path

# Avoid duplicates.
# Taken from: https://leetschau.github.io/remove-duplicate-zsh-history.html
setopt PUSHD_IGNORE_DUPS
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
# setopt HIST_BEEP

function chpwd() {
    emulate -L zsh
    if [[ -f /usr/bin/exa ]]; then
      /usr/bin/exa -bghHliSa
      return
    fi
    ls -als --color=auto
}

autoload -Uz compinit promptinit
compinit
promptinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.local/share/histfile
HISTSIZE=100000
SAVEHIST=100000
setopt appendhistory autocd extendedglob nomatch notify
# Allow > redirection to overwrite existing file
setopt clobber
unsetopt beep
setopt correct correct_all
# End of lines configured by zsh-newuser-install
# }}}

# Zimfw options {{{
# Don't check for new version automatically
zstyle ':zim' disable-version-check yes

zstyle ':zim:duration-info' threshold 0.01
zstyle ':zim:duration-info' show-milliseconds yes
zstyle ':zim:completion' dumpfile "/tmp/zcompdump-${ZSH_VERSION}"
# }}}


NIX_PROFILES_PATH=/home/reinaldo/.nix-profile/share
LINUX_PATH=/usr/share/zsh/plugins
ZSH_PLUGIN_PATH=""
if [[ -d $NIX_PROFILES_PATH ]]; then
  ZSH_PLUGIN_PATH=$NIX_PROFILES_PATH
else
  ZSH_PLUGIN_PATH=$LINUX_PATH
fi

# Zsh Plugin Opions {{{

if [[ -f $ZSH_PLUGIN_PATH/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  bindkey '^ ' autosuggest-accept
  source $ZSH_PLUGIN_PATH/zsh-autosuggestions/zsh-autosuggestions.zsh

  # See https://github.com/zsh-users/zsh-autosuggestions/blob/master/README.md#suggestion-highlight-style
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=30'
  ZSH_AUTOSUGGEST_STRATEGY=(history completion match_prev_cmd)
fi

if [[ -f $ZSH_PLUGIN_PATH/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  # See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
  ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor root line)
  # Customize the main highlighter styles.
  # See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md#how-to-tweak-it
  typeset -A ZSH_HIGHLIGHT_STYLES
  ZSH_HIGHLIGHT_STYLES[comment]='fg=4'
  ZSH_HIGHLIGHT_STYLES[builtin]='fg=93'
  ZSH_HIGHLIGHT_STYLES[command]='fg=93'
  ZSH_HIGHLIGHT_STYLES[function]='fg=93'
  ZSH_HIGHLIGHT_STYLES[alias]='fg=magenta,bold'
  ZSH_HIGHLIGHT_STYLES[path]='fg=cyan'
  source $ZSH_PLUGIN_PATH/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# z setup {{{
[[ -r "/usr/share/z/z.sh" ]] && source /usr/share/z/z.sh
# }}}
#
# }}}

# Source plugins{{{
if [[ -f $ZSH_PLUGIN_PATH/zsh-vi-mode/zsh-vi-mode.plugin.zsh ]]; then
  function zvm_config() {
    ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
    # Needed for fzf to work
    ZVM_INIT_MODE=sourcing
  }

  # Inspect the file below for config options
  source $ZSH_PLUGIN_PATH/zsh-vi-mode/zsh-vi-mode.plugin.zsh
fi
# }}}

# zsh-history-substring-search{{{

if [[ -f $ZSH_PLUGIN_PATH/zsh-history-substring-search/zsh-history-substring-search.zsh ]]; then
  # Bind ^[[A/^[[B manually so up/down works both before and after zle-line-init
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down

  # Bind up and down keys
  zmodload -F zsh/terminfo +p:terminfo
  if [[ -n ${terminfo[kcuu1]} && -n ${terminfo[kcud1]} ]]; then
    bindkey ${terminfo[kcuu1]} history-substring-search-up
    bindkey ${terminfo[kcud1]} history-substring-search-down
  fi

  bindkey -M viins '^P' history-substring-search-up
  bindkey -M viins '^N' history-substring-search-down
  bindkey -M vicmd '^P' history-substring-search-up
  bindkey -M vicmd '^N' history-substring-search-down
  bindkey -M emacs '^P' history-substring-search-up
  bindkey -M emacs '^N' history-substring-search-down
  bindkey -M vicmd 'k' history-substring-search-up
  bindkey -M vicmd 'j' history-substring-search-down
  source $ZSH_PLUGIN_PATH/zsh-history-substring-search/zsh-history-substring-search.zsh
fi
# }}}

# Edit commands with editor{{{
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^e' edit-command-line
# }}}

# Exports {{{
export IGNORE_FILE="--ignore-file $HOME/.config/ignore-file"

# reduce timeout
export KEYTIMEOUT=1

export _Z_DATA="$HOME/.local/share/z"

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# }}}

# Oh-My-Zsh Options{{{
# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to disable auto-setting terminal title
DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"
	
# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"
# }}}

# Source files{{{
[[ -f ~/.bash_aliases ]] && source ~/.bash_aliases

# context for resume making
# install context-minimals-git
# mtxrun --generate
[[ -f /opt/context-minimals/setuptex ]] && source /opt/context-minimals/setuptex
# }}}

# fzf setup{{{
if [[ -f /usr/bin/fzf ]]; then
  [[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
  [[ -f /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh

  # Depends on `install fd`
  if [[ -f /usr/bin/fd ]]; then
    export FZF_ALT_C_COMMAND="fd --type directory --hidden --no-ignore-vcs $IGNORE_FILE . $(pwd)"
    export FZF_DEFAULT_COMMAND="fd --type file --hidden --follow $IGNORE_FILE 2> /dev/null"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"
    # Taken from: https://github.com/junegunn/fzf/wiki/Color-schemes
    # Looks really weird with the dark color scheme
    export FZF_DEFAULT_OPTS="--layout=reverse --info=inline"
    # --color fg:240,bg:230,hl:33,fg+:241,bg+:221,hl+:33
    # --color info:33,prompt:33,pointer:166,marker:166,spinner:33
  fi

  # TODO-[RM]-(Wed Oct 25 2017 10:10): Download it
  # https://github.com/urbainvaes/fzf-marks
fi
# }}}

# ssh agent {{{
# Start ssh-agent to cache ssh keys passphrases. Or use an existing one
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
  ssh-agent > "$XDG_RUNTIME_DIR/ssh-agent.env"
fi
if [[ ! "$SSH_AUTH_SOCK" ]]; then
  eval "$(<"$XDG_RUNTIME_DIR/ssh-agent.env")" > /dev/null || echo "Failed to start ssh-agent"
fi
# }}}

# tmux on ssh{{{
# Run tmux automatically on ssh
if [[ "$TMUX" == "" ]] &&
        [[ "$SSH_CONNECTION" != "" ]]; then
    WHOAMI=$(whoami)
    if tmux has-session -t $WHOAMI 2>/dev/null; then
			tmux -2 attach-session -t $WHOAMI
    else
			tmux -2 new-session -s $WHOAMI
    fi
fi
# }}}

# p10k setup {{{
# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
# TODO: Don't source this file, but rather: romkatv/powerlevel10k/config/p10k-lean.zsh
# TODO: Use a suggested font so that there is no that many differences
if [[ -f $ZSH_PLUGIN_PATH/zhs-powerlevel10k/powerlevel10k.zsh-theme ]]; then
  source $ZSH_PLUGIN_PATH/zhs-powerlevel10k/powerlevel10k.zsh-theme
elif [[ -f /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme ]]; then
  source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
fi
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

typeset -g POWERLEVEL9K_DIR_CLASSES=()
typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_FOREGROUND=242
typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR=' '
# Extra line after command runs
typeset -g POWERLEVEL9K_SHOW_RULER=false
typeset -g POWERLEVEL9K_RULER_CHAR=' '
typeset -g POWERLEVEL9K_RULER_FOREGROUND=242
typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false
typeset -g POWERLEVEL9K_MODE=ascii
typeset -g POWERLEVEL9K_VIM_SHELL_VISUAL_IDENTIFIER_EXPANSION='nvim'
typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose
typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=off
typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE=true
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=2
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=0
typeset -g POWERLEVEL9K_STATUS_VERBOSE_SIGNAME=true
typeset -g POWERLEVEL9K_STATUS_ERROR=true
typeset -g POWERLEVEL9K_STATUS_OK=true
typeset -g POWERLEVEL9K_VCS_BRANCH_ICON='\uF126 '
# }}}

[[ -f /usr/bin/direnv ]] && eval "$(direnv hook zsh)"

export ATUIN_NOBIND="true"
if [[ -f /usr/bin/atuin ]]; then
  # Only bind <c-r>, up key is really annoying
  eval "$(atuin init zsh)"
  bindkey '^r' _atuin_search_widget
fi

# vim: fdm=marker ft=sh
