# Apt
alias install='sudo apt install'
alias update='sudo apt update'
alias purge='sudo apt purge'

# Git
alias ga='git add'
alias gs='git status'
alias gc='git commit -m'
alias gps='git push origin master'
alias gpl='git pull origin master'

# Mounting remote servers
alias mount-truck='sshfs odroid@truck-server:/ /home/reinaldo/.mnt/truck-server/'
alias mount-copter='sshfs odroid@copter-server:/ /home/reinaldo/.mnt/copter-server/'
alias mount-hq='sshfs reinaldo@HQ:/ /home/reinaldo/.mnt/HQ-server/'

# Misc
# After policy use package name. It will tell you what version of the package
# will get installed
alias version='apt-cache policy'
alias tmux='tmux -2'
# Reload rxvt and deamon
# Search help
alias help=FuncHelp
FuncHelp()
{
  $1 --help 2>&1 | grep $2 
}

