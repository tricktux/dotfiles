# Apt
# Ubuntu package manager
# After policy use package name. It will tell you what version of the package
# will get installed
# alias version='apt-cache policy'
# alias install='sudo apt install'
# alias purge='sudo apt purge'
# alias update='sudo apt update'

alias install='pacaur -S --noconfirm'
alias update='pacaur -Syu --noconfirm'
alias version='pacaur -Si'
alias search='pacaur -Ss'

# Git
alias ga='git add'
alias gs='git status'
alias gc='git commit -m'
alias gps='git push origin master'
alias gpl='git pull origin master'

# Mounting remote servers
alias mount-truck='sshfs odroid@truck-server:/home/odroid/ /home/reinaldo/.mnt/truck-server/'
alias mount-copter='sshfs odroid@copter-server:/home/odroid/ /home/reinaldo/.mnt/copter-server/'
alias mount-hq='sshfs reinaldo@HQ:/home/reinaldo/ /home/reinaldo/.mnt/HQ-server/'

# Misc
alias tmux='tmux -2'
alias ll='ls -als'
alias vim='nvim'
# Reload rxvt and deamon
# Search help
alias help=FuncHelp
FuncHelp()
{
  $1 --help 2>&1 | grep $2 
}
