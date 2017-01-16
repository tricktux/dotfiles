# Apt
# Ubuntu package manager
# After policy use package name. It will tell you what version of the package
# will get installed
# alias version='apt-cache policy'
# alias install='sudo apt install'
# alias purge='sudo apt purge'
# alias update='sudo apt update'

machine=`hostname`

alias install='pacaur -S --noconfirm'
alias update=FuncUpdate
alias version='pacaur -Si'
alias search='pacaur -Ss'
alias remove='pacaur -Rscn'
alias remove-only='pacaur -Rdd'

# Git
alias ga='git add'
alias gs='git status'
alias gc='git commit -m'
alias gps='git push origin master'
alias gpl='git pull origin master'

# svn
alias va='svn add --force'
alias vs='svn status'
alias vc='svn commit -m'
alias svn-chekcout='svn co svn+ssh://odroid@copter-server/mnt/hq-storage/1.Myn/svn-server/'

# Mounting remote servers
alias mount-truck='sshfs odroid@truck-server:/ /home/$USER/.mnt/truck-server/'
alias mount-copter='sshfs odroid@copter-server:/ /home/$USER/.mnt/copter-server/'
alias mount-hq='sshfs reinaldo@HQ:/ /home/$USER/.mnt/HQ-server/'

# Misc
alias tmux='tmux -2'
alias ll='ls -als'
alias vim=FuncNvim
# Reload rxvt and deamon
# Search help
alias help=FuncHelp
alias cpstat=FuncCheckCopy
FuncHelp()
{
  $1 --help 2>&1 | grep $2 
}

FuncCheckCopy()
{
	if [[ $# -lt 1 ]]; then
		echo "Usage: provide src dir"
		return
	fi
	echo "Calculating size of src folder. Please wait ..."
	local total=`nice -n -0 du -mhs $1`
	# local total=888888888888
	# echo $total
	# return
	while :
	do
		echo "Press [CTRL+C] to stop.."
		local dst=`sudo nice -n -20 du -mhs`
		echo "$dst of $total"
		sleep 60
	done
}

FuncUpdate()
{
	# Update list of all installed packages
	pacman -Qe > ~/.dotfiles/$machine-arch-packages
	pacman -Qm >> ~/.dotfiles/$machine-arch-packages
	# Now update packages
	pacaur -Syu --noconfirm
}

FuncNvim()
{
	if hash nvim 2>/dev/null; then
		nvim "$@"
	elif hash vim 2>/dev/null; then
		vim "$@"
	else
		vi "$@"
	fi
}
