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
aur_helper='paru'

# gpg
alias gpg-encrypt="gpg --encrypt --recipient 3D8AA5DEB1ADAA960488A4ED670B48EF8DF28C77"
alias gpg-decrypt="gpg --decrypt"

#ranger
alias r=ranger_cd

# ytfzf
alias ytfzf-tonymcguiness="ytfzf -mr -c youtube-playlist 'https://www.youtube.com/playlist?list=PL6RLee9oArCC9V1FlRexG_6F2KNo143I8'"
alias ytfzf-noraenpure="ytfzf -mr -c youtube-playlist 'https://www.youtube.com/playlist?list=PL-Wt-lDOPUzHBDXm8ODmax9oHhVX6YtEb'"
alias ytfzf-liquicityyearmixes="ytfzf -mr -c youtube-playlist 'https://www.youtube.com/playlist?list=PLNE3b80YbdklT_fHeWNw99re6ESyIn4DW'"
alias ytfzf-cercle="ytfzf -mr -c youtube-playlist 'https://www.youtube.com/playlist?list=PLDitloyBcHOm_Q06fztzSfLp19AJYX141'"

alias mv="mv --interactive --verbose"
alias cp="cp --recursive --interactive --verbose"
alias mkdir="mkdir --parents --verbose"

# Fix for kitty ssh
alias ssh="kitty +kitten ssh"
alias kstt="kitty @set-tab-title"
alias kswt="kitty @set-window-title"
alias kitty-save-session=save_kitty_session
function save_kitty_session() {
   if [ -z "\$1" ]
   then
       echo "Please provide a session name."
       return 1
   else
       kitty @ ls | python ~/.local/bin/kitty-save-session.py > ~/.config/kitty/"$1".kitty
   fi
}

# Install
alias paci="\$HOME/.config/dotfiles/scripts/nix/arch.sh -i"
# Update
alias pacu="\$HOME/.config/dotfiles/scripts/nix/arch.sh -u"
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
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# cp and mv
if [[ -f advcp ]]; then
	alias cp='advcp -gi'
	alias mv='advmv -gi'
fi

# cp and mv
# if [[ -f /usr/bin/rsync ]]; then
# alias cp='cpr'
# alias mv='mvr'
# fi

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
alias cat='bat'

# svn
alias va='svn add --force'
alias vs='svn status'
alias vc='svn commit -m'
alias svn-checkout=FuncSvnCheckout
alias svn-create=FuncSvnCreate

# pdf
alias pdf_join=FuncPdfJoin
alias pdf_reduce=FuncPdfReduce
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
if [[ -f exa ]]; then
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
alias gitup=FuncUpdate

alias pass='EDITOR=vi pass'

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
	convert $@
}

FuncUpdate() {
	local local_gits=(~/.config/dotfiles/
		~/.password-store/
		~/Documents/scripts)
	for i in ${local_gits[@]}; do
		if [[ -d $i ]]; then
			cd $i
			git pull origin master
		else
			echo "Invalid directory: '$i'"
		fi
	done
	cd
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
