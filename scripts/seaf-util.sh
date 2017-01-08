# File:seaf-util.sh
# Description: Shortcut to allow start, stoping and restarting seaf server
# Requirements: Requieres to be run as root and provide one of the following
# arguments: start, stop, restart.
# Author:Reinaldo Molina <rmolin88@gmail.com>
# Version:1.0.0
# Last modified: Jan 07 2017 16:00

server_path=~/Documents/HQ/seafile-server-latest

if [[ $# -lt 1 ]]; then
	echo "Please provide at least one argument. Like start, stop, restart"
	exit
fi

# If ordered to start and HDD is not mounted. Mount it
if [[ $1 = "start" && ! -d /mnt/hq-storage/1.Myn ]]; then
	echo "Mounting HDD"
	sudo mount /dev/sda1 /mnt/hq-storage/
	# Check to see that HDD mounted properly
	if [[ $? -ne 0 ]]; then
		echo "Failed to Mount HDD"
		exit
	fi
fi

cd $server_path
sudo ./seafile.sh $1
if [[ $? -ne 0 ]]; then
	echo "Failed to start seafile server"
	exit
fi
sudo ./seahub.sh $1
if [[ $? -ne 0 ]]; then
	echo "Failed to start seahub server"
	exit
fi

if [[ $1 = "stop" && -d /mnt/hq-storage/1.Myn ]]; then
	echo "Unmounting HDD"
	sudo umount /mnt/hq-storage/
fi

