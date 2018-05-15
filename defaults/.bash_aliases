# Apt
# Ubuntu package manager
# After policy use package name. It will tell you what version of the package
# will get installed
# alias version='apt-cache policy'
# alias install='sudo apt install'
# alias purge='sudo apt purge'
# alias update='sudo apt update'

machine=`hostname`

alias install='trizen -Syy && trizen -S --noconfirm'
alias update='trizen -Syyu --devel --noconfirm $@'
alias version='trizen -Si'
alias search='trizen -Ss'
alias remove='trizen -Rscn'
alias remove-only='trizen -Rdd'

# git
alias ga='git add'
alias gs='git status'
alias gc='git commit -m'
alias gps='git push origin master'
alias gpl='git pull origin master'

# svn
alias va='svn add --force'
alias vs='svn status'
alias vc='svn commit -m'
alias svn-checkout=FuncSvnCheckout
alias svn-create=FuncSvnCreate

# mutt
alias neomutt='neomutt -F ~/.config/mutt/account.gmail'
alias neomutt-gmail='neomutt -F ~/.config/mutt/account.gmail'
alias neomutt-psu='neomutt -F ~/.config/mutt/account.psu'

# Folder
# UnrealEngineCourse
alias svn-server='cd /home/reinaldo/.mnt/copter-server/mnt/hq-storage/1.Myn/svn-server'

# Mounting remote servers
alias mount-truck='sshfs reinaldo@truck-server:/ ~/.mnt/truck-server/'
alias mount-copter='sshfs reinaldo@192.168.1.8:/ ~/.mnt/copter-server/'
alias mount-hq='sshfs reinaldo@HQ:/ ~/.mnt/HQ-server/'

# Misc
# Removing -2 from tmux in order to get truecolor
alias tmux='tmux -f ~/.config/tmux/.tmux.conf'
alias ll='exa -bghHliSa'
alias ls='exa -la'
alias vim='stty -ixon && vim'
# Reload rxvt and deamon
# Search help
alias help=FuncHelp
alias cpstat=FuncCheckCopy

# Default to human readable figures
alias df='df -h'
alias du='du -h'

alias mkcdir=mkcdir

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
	# Get rid of unused packages and optimize first
	sudo pacman -Sc --noconfirm
	sudo pacman-optimize
	# Update list of all installed packages
	sudo pacman -Qnq > ~/.config/dotfiles/$machine.native
	sudo pacman -Qmq > ~/.config/dotfiles/$machine.aur
	# Tue Sep 26 2017 18:40 Update Mirror list. Depends on `reflector`
	if hash reflector 2>/dev/null; then
		sudo reflector --protocol https --latest 30 --number 20 --sort rate --save /etc/pacman.d/mirrorlist -c 'United States' --verbose
	fi
	# Now update packages
	# When update fails to verify some <package> do:
	# update --ignore <package1>,<package2>
	# Devel is required to update <package-git> stuff
	trizen -Syyu --devel --noconfirm $@
	# To install packages from list:
	# trizen -S - < <pgklist.txt>
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

FuncSvnCheckout()
{
	svn co svn+ssh://reinaldo@192.168.1.8/mnt/hq-storage/1.Myn/svn-server/$1 $2
}

FuncSvnCreate()
{
	ssh reinaldo@192.168.1.8 mkdir -p /mnt/hq-storage/1.Myn/svn-server/$1 $@
	ssh reinaldo@192.168.1.8 svnadmin create /mnt/hq-storage/1.Myn/svn-server/$1 $@
}

mkcdir ()
{
    mkdir -p -- "$1" &&
      cd -P -- "$1"
}
