# Apt
# Ubuntu package manager
# After policy use package name. It will tell you what version of the package
# will get installed
# alias version='apt-cache policy'
# alias install='sudo apt install'
# alias purge='sudo apt purge'
# alias update='sudo apt update'

machine=$(hostname)
aur_helper='paru'

[[ -x /usr/bin/wget ]] && alias wget="wget --hsts-file=\"$XDG_DATA_HOME/wget-hsts\""
[[ -x /usr/bin/yarn ]] && alias yarn="yarn --use-yarnrc $XDG_CONFIG_HOME/yarn/config"

# gpg
if [[ -x /usr/bin/gpg ]]; then
  alias gpg-encrypt="gpg --encrypt"
  alias gpg-decrypt="gpg --decrypt"
fi

#ranger
[[ -x /usr/bin/ranger ]] && alias r=ranger_cd

#tar
alias tar_create="tar -cvf"
alias tar_extract="tar -xvf"
alias tar_list="tar -tvf"
alias tar_create_gz="tar -czvf"
alias tar_extract_gz="tar -xzvf"
alias tar_extract_skip="tar --skip-old-files -xvf"

# ytfzf
if [[ -x /usr/bin/ytfzf ]]; then
  alias ytfzf-tonymcguiness="ytfzf -mr -c youtube-playlist 'https://www.youtube.com/playlist?list=PL6RLee9oArCC9V1FlRexG_6F2KNo143I8'"
  alias ytfzf-noraenpure="ytfzf -mr -c youtube-playlist 'https://www.youtube.com/playlist?list=PL-Wt-lDOPUzHBDXm8ODmax9oHhVX6YtEb'"
  alias ytfzf-liquicityyearmixes="ytfzf -mr -c youtube-playlist 'https://www.youtube.com/playlist?list=PLNE3b80YbdklT_fHeWNw99re6ESyIn4DW'"
  alias ytfzf-cercle="ytfzf -mr -c youtube-playlist 'https://www.youtube.com/playlist?list=PLDitloyBcHOm_Q06fztzSfLp19AJYX141'"
  alias ytfzf-kushsessions="ytfzf -mr -c youtube-playlist 'https://www.youtube.com/playlist?list=PLC419BC3954CB6D58'"
  alias ytfzf-lofi="ytfzf -mr -c youtube-playlist 'https://www.youtube.com/playlist?list=PLzJ-3MmUlWJnglv91qBj8gfSXdAIfj5Y4'"
fi

alias mv="mv --interactive --verbose"
alias cp="cp --recursive --interactive --verbose"
alias mkdir="mkdir --parents --verbose"

if [[ -f /usr/bin/todo ]]; then
  alias todomine='vdirsyncer sync && todo list --sort -due,priority --due 72'
fi

if [[ -f /usr/bin/khal ]]; then
  alias cal='vdirsyncer sync && khal list --format "{start-date-long} {start-time} {title}" --day-format "" today 7d'
fi

if [[ -f /usr/bin/advcp ]]; then
  alias cp='advcp -gi'
  alias mv='advmv -gi'
fi

if [[ -f /usr/bin/kitty ]]; then
  alias ssh="kitty +kitten ssh"
  alias kstt="kitty @set-tab-title"
  alias kswt="kitty @set-window-title"
  alias kitty-save-session=save_kitty_session
  function save_kitty_session() {
    if [ -z "\$1" ]; then
      echo "Please provide a session name."
      return 1
    else
      kitty @ ls | python ~/.local/bin/kitty-save-session.py >~/.config/kitty/"$1".kitty
    fi
  }
fi

if [[ -f /usr/bin/paru ]]; then
  # Install
  alias paci="\$HOME/.config/dotfiles/scripts/nix/arch/upkeep.sh -i"
  # Update
  alias pacu="\$HOME/.config/dotfiles/scripts/nix/arch/upkeep.sh -u"
  # Version
  alias pacv="\$aur_helper -Si"
  # Search
  alias pacsf="\$aur_helper -Slq | fzf --multi --preview '\$aur_helper -Si {1}' | xargs -ro \$aur_helper -S"
  alias pacs="\$aur_helper -Ss"
  # Remove
  alias pacr="\$aur_helper -Rscn"
  # Remove only
  alias pacro="\$aur_helper -Rdd"
  alias pacuo="\$aur_helper -Rdd"
  alias pacbroken="\$aur_helper -Qkk"
  # List files of package
  alias pacll="\$aur_helper -Ql"
fi

# network
# Check opern ports
alias ports='netstat -tulanp'

# ffmpeg
alias ffmpeg_concat=FuncFfmpegConcat

alias journalctlp='journalctl -o short-precise'

# cd
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# cp and mv
if [[ -x /usr/bin/advcp ]]; then
  alias cp='advcp -gi'
  alias mv='advmv -gi'
fi

# Do not wait interval 1 second, go fast #
alias ping='ping -c 10 -i .2'
# do not delete / or prompt if deleting more than 3 files at a time #
alias rm='rm -I --preserve-root' # confirmation #
alias ln='ln -i'                 # Parenting changing perms on / #
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'
alias diff='diff --color=auto'
alias grep='grep --color=auto'
alias ip='ip -color=auto'
[[ -f /usr/bin/bat ]] && alias cat='bat'

# pdf
#
if [[ -x /usr/bin/gs ]]; then
  alias pdf_join=FuncPdfJoin
  alias pdf_reduce=FuncPdfReduce
fi

if [[ -x /usr/bin/convert ]]; then
  alias pdf_convert_jpg_pdf=FuncPdfConvert
fi

# mutt
if [[ -x /usr/bin/neomutt ]]; then
  alias neomutt-gmail='neomutt -F ~/.config/neomutt/user.gmail'
  alias neomutt-psu='neomutt -F ~/.config/neomutt/user.psu'
fi

# ls
if [[ -f exa ]]; then
  alias ll='exa -bghHliSa'
  alias ls='exa -la'
else
  ## Colorize the ls output ##
  alias ls='ls --color=auto'
  ## Use a long listing format ##
  alias ll='ls -als'
  ## Show hidden files ##
  alias l.='ls -d .* --color=auto'
fi

alias shred_dir=FuncShredDir

FuncShredDir() {
  find $@ -type f -exec shred -n 12 -u {} \;
  rm -r $@
}

# Default to human readable figures
alias df='df -h'
alias du='du -h'

alias pass='EDITOR="nvim --clean" pass'

FuncNvim() {
  if hash nvim 2>/dev/null; then
    nvim "$@"
  elif hash vim 2>/dev/null; then
    vim "$@"
  else
    vi "$@"
  fi
}

# $1 - Name of output file
# $@ - Name of pdf files to join
# gs = ghostscript (dependency)
FuncPdfJoin() {
  gs -q -sPAPERSIZE=a4 -dNOPAUSE -dBATCH \
    -sDEVICE=pdfwrite -sOutputFile=$1 $@
}

# $1 - Name of output file
# $@ - Name of pdf file to reduce
# gs = ghostscript (dependency)
FuncPdfReduce() {
  gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 \
    -dPDFSETTINGS=/screen -dNOPAUSE -dQUIET \
    -dBATCH -sOutputFile="$1" "$@"
}
# $@ list of *.jpg first arguments then finally name of output pdf file
# Depends on imagemagic
FuncPdfConvert() {
  convert "$@"
}

# Comes from /usr/share/doc/ranger/examples/shell_automatic_cd.sh
ranger_cd() {
  temp_file="$(mktemp -t "ranger_cd.XXXXXXXXXX")"
  ranger --choosedir="$temp_file" -- "${@:-$PWD}"
  if chosen_dir="$(cat -- "$temp_file")" && [ -n "$chosen_dir" ] && [ "$chosen_dir" != "$PWD" ]; then
    cd -- "$chosen_dir"
  fi
  rm -f -- "$temp_file"
}

# mylist.txt looks like this:
# file '<relative/full file name.mp4>'
# file '<relative/full file name.mp4>'
FuncFfmpegConcat() {
  ffmpeg -f concat -safe 0 -i mylist.txt -c copy output.mp4
}

bkp() {
  if [ -z "$1" ]; then
    echo "Usage: bkp <file_directory_path>"
    return 1
  fi

  if [ -e "$1" ]; then
    cp "$1"{,.bkp.$(date +%s)}
  else
    echo "Error: $1 is not a directory."
    return 1
  fi
}
