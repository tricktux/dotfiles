# Apt
# Ubuntu package manager
# After policy use package name. It will tell you what version of the package
# will get installed
# alias version='apt-cache policy'
# alias install='sudo apt install'
# alias purge='sudo apt purge'
# alias update='sudo apt update'

machine=$(hostname)
server_ip='192.168.128.128'

alias mv="mv --interactive --verbose"
alias cp="cp --recursive --interactive --verbose"
alias mkdir="mkdir --parents --verbose"

alias pacinst='trizen -S'
alias pacup='trizen -Syu'
alias pacver='trizen -Si'
alias pacsearch='trizen -Ss'
alias pacuninst='trizen -Rscn'
alias pacuninstonly='trizen -Rdd'
alias pacbroken='trizen -Qkk'
alias paclistpkgfiles='trizen -Ql'

# git
alias ga='git add'
alias gs='git status'
alias gc='git commit -m'
alias gps='git push origin master'
alias gpl='git pull origin master'

# network
# Check opern ports
alias ports='netstat -tulanp'

# ffmpeg
alias ffmpeg_concat=FuncFfmpegConcat

alias journalctlp='journalctl -o short-precise'

# cd
alias .='cd ..'
alias ..='cd ../..'
alias ...='cd ../../..'

# cp and mv
if [[ -f /usr/bin/advcp ]]; then
  alias cp='advcp -gi'
  alias mv='advmv -gi'
fi

# cp and mv
# if [[ -f /usr/bin/rsync ]]; then
  # alias cp='cpr'
  # alias mv='mvr'
# fi

function cpr() {
  new_args=();
  for i in "$@"; do
      case $i in /) i=/;; */) i=${i%/};; esac
      new_args+=$i;
  done
  /usr/bin/rsync --archive -hh --partial --info=stats1 --info=progress2 \
    --modify-window=1 "${(@)new_args}"
}
function mvr() {
  new_args=();
  for i in "$@"; do
    case $i in /) i=/;; */) i=${i%/};; esac
    new_args+=$i;
  done
  /usr/bin/rsync --archive -hh --partial --info=stats1 --info=progress2 \
    --modify-window=1 --remove-source-files \
    --backup --backup-dir=/tmp "${(@)new_args}"
}

# Do not wait interval 1 second, go fast #
alias ping='ping -c 10 -i .2'
# do not delete / or prompt if deleting more than 3 files at a time #
alias rm='rm -I --preserve-root' # confirmation #
alias ln='ln -i'                 # Parenting changing perms on / #
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'
alias diff='diff --color=auto'
alias grep='grep --color=auto'
alias cat='bat'

# svn
alias va='svn add --force'
alias vs='svn status'
alias vc='svn commit -m'
alias svn-checkout=FuncSvnCheckout
alias svn-create=FuncSvnCreate

# pdf
alias pdf_join=FuncPdfJoin
alias pdf_convert_jpg_pdf=FuncPdfConvert

# mutt
alias neomutt-gmail='neomutt -F ~/.config/neomutt/user.gmail'
alias neomutt-psu='neomutt -F ~/.config/neomutt/user.psu'

# Folder
# UnrealEngineCourse
# alias svn-server=\
# 'cd /home/reinaldo/.mnt/copter-server/mnt/hq-storage/1.Myn/svn-server'

# Mounting remote servers
# alias mount-truck='sshfs reinaldo@truck-server:/ ~/.mnt/truck-server/'
# alias mount-copter='sshfs reinaldo@${server_ip}:/ ~/.mnt/copter-server/'
# alias mount-hq='sshfs reinaldo@HQ:/ ~/.mnt/HQ-server/'

# Misc
# Removing -2 from tmux in order to get truecolor
# alias tmux='tmux -f ~/.config/tmux/conf'
# This is for alt mappings, but it makes zsh hang
# alias vim='stty -ixon && vim'
# Reload rxvt and deamon
# Search help
# alias help=FuncHelp
# alias cpstat=FuncCheckCopy

# ls
if [[ -f /usr/bin/exa ]]; then
  alias ll='exa -bghHliSa'
  alias ls='exa -la'
else
  ## Colorize the ls output ##
  alias ls='ls --color=auto'
  ## Use a long listing format ##
  alias ll='ls -la'
  ## Show hidden files ##
  alias l.='ls -d .* --color=auto'
fi

alias shred_dir=FuncShredDir
alias cmakeclean=FuncCmakeCleanBuild

FuncCmakeCleanBuild() {
  if [ -d ../build ]; then
    cd ..
    rm -rf build
    mkdir build
    cd build
  else
    echo "build directory DOES NOT exist"
  fi
}

FuncShredDir() {
  find $@ -type f -exec shred -n 12 -u {} \;
  rm -r $@
}

# Default to human readable figures
alias df='df -h'
alias du='du -h'

alias mkcdir=FuncMkcdir

FuncHelp() {
  $1 --help 2>&1 | grep $2
}

FuncCheckCopy() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: provide src dir"
    return
  fi
  echo "Calculating size of src folder. Please wait ..."
  local total=$(nice -n -0 du -mhs $1)
  # local total=888888888888
  # echo $total
  # return
  while :; do
    echo "Press [CTRL+C] to stop.."
    local dst=$(sudo nice -n -20 du -mhs)
    echo "$dst of $total"
    sleep 60
  done
}

# TODO-[RM]-(Wed Jan 09 2019 20:59):
# Take care of this
# Not used as anything else other than reference
FuncSomethingElseUpdate() {
  # Get rid of unused packages and optimize first
  sudo pacman -Sc --noconfirm
  sudo pacman-optimize
  # Update list of all installed packages
  sudo pacman -Qnq >~/.config/dotfiles/$machine.native
  sudo pacman -Qmq >~/.config/dotfiles/$machine.aur
  # Tue Sep 26 2017 18:40 Update Mirror list. Depends on `reflector`
  if hash reflector 2>/dev/null; then
    sudo reflector --protocol https --latest 30 --number 20 \
      --sort rate --save /etc/pacman.d/mirrorlist \
      -c 'United States' --verbose
  fi
  # Now update packages
  # When update fails to verify some <package> do:
  # update --ignore <package1>,<package2>
  # Devel is required to update <package-git> stuff
  trizen -Syyu --devel --noconfirm $@
  # To install packages from list:
  # trizen -S - < <pgklist.txt>
}

FuncNvim() {
  if hash nvim 2>/dev/null; then
    nvim "$@"
  elif hash vim 2>/dev/null; then
    vim "$@"
  else
    vi "$@"
  fi
}

FuncSvnCheckout() {
  svn co svn+ssh://reinaldo@$server_ip/mnt/hq-storage/1.Myn/svn-server/$1 $2
}

FuncSvnCreate() {
  ssh reinaldo@$server_ip mkdir -p /mnt/hq-storage/1.Myn/svn-server/$1 $@
  ssh reinaldo@$server_ip svnadmin create \
    /mnt/hq-storage/1.Myn/svn-server/$1 $@
}

FuncMkcdir() {
  mkdir -p -- "$1" &&
    cd -P -- "$1"
}

# $1 - Name of output file
# $@ - Name of pdf files to join
# gs = ghostscript (dependency)
FuncPdfJoin() {
  /usr/bin/gs -q -sPAPERSIZE=a4 -dNOPAUSE -dBATCH \
    -sDEVICE=pdfwrite -sOutputFile=$1 $@
}

# $@ list of *.jpg first arguments then finally name of output pdf file
# Depends on imagemagic
FuncPdfConvert() {
  convert $@
}

FuncUpdate() {
  # Thu Dec 27 2018 23:45
  # Not needed since samba :D
  # Wed Jan 09 2019 21:01
  # Not so fast cowboy. samba didnt work for streaming files
  # Wed Jan 16 2019 20:08
  # Going back to samba since hq odroid died
  # However, this is samba on router
  # Tue Mar 26 2019 19:40
  # Now trying samba from fstab
  # if [[ ! -d /mnt/samba/docs ]]; then
  # sudo mount -t cifs //Linksys05238/samba /mnt/samba -o \
  # credentials=/etc/samba/credentials/share,uid=1000,gid=985,vers=1.0
  # fi
  # sshfs reinaldo@$server_ip:/mnt/hq-storage/1.Myn/samba \
  #	~/.mnt/copter-server/
  # Tue Oct 16 2018 20:10: You really dont want to update your plugins
  # everday. Things break. Very frequently.
  # nvim +PlugUpgrade +PlugUpdate +UpdateRemotePlugins
  local_gits=('~/.config/dotfiles/'
    '~/.password-store/'
    '~/Documents/cpp/ML_SC2/Arrancar0/')
  # if [[ ! -d /mnt/samba/docs ]]; then
  for i in $local_gits; do
    if [[ -d $i ]]; then
      cd $i
      gpl
    fi
  done
  cd
  # Sat Mar 09 2019 20:24
  # When there are 30+ updates to be made
  # trizen -Syu
}

# mylist.txt looks like this:
# file '<relative/full file name.mp4>'
# file '<relative/full file name.mp4>'
FuncFfmpegConcat() {
  ffmpeg -f concat -safe 0 -i mylist.txt -c copy output.mp4
}
