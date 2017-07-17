#!/usr/bin/env bash

# File:					unmount.sh
# Description:			Utility to mount/umount usb devices
# Author:				https://gist.github.com/anonymous/a69093a51f83b53d9fc5
# Version:				0.0.0
# Last Modified: Jul 16 2017 19:17
# Created: Jul 16 2017 19:17

# Unmounting devices mounted with udev or systemd/udev
# This script requires that you have sudo installed and that you have sudo rights.
# Create an executable file, e.g. /usr/local/bin/unmount.sh

# Global variables
TITLE="Unmount Utility"
COLUMNS=3 # TARGET,SOURCE,FSTYPE
#IFS=$'\n'

# Populate list of unmountable devices
deviceList=($(findmnt -Do TARGET,SOURCE,FSTYPE | grep -e "sd[b-z]"))
deviceCount=$((${#deviceList[@]} / $COLUMNS))

# Start of program output
echo $TITLE

# Display list of devices that can be unmounted
for ((device=0; device<${#deviceList[@]}; device+=COLUMNS))
do
	printf "%4s)   %-25s%-13s%-10s\n"\
		"$(($device / $COLUMNS))"\
		"${deviceList[$device]}"\
		"${deviceList[$(($device + 1))]}"\
		"${deviceList[$(($device + 2))]}"
done

printf "%4s)   Exit\n" "x"

# Get input from user
read -p "Choose a menu option: " input

# Input validation
if [ "$input" = "X" ] || [ "$input" = "x" ]
then
	echo "Exiting"
	exit 0
fi

if (( $input>=0 )) && (( $input<$deviceCount ))
then
	echo "Unmounting: ${deviceList[$(($input * $deviceCount))]}"
	sudo umount "${deviceList[$(($input * $deviceCount))]}"
	exit 0
else
	echo "Invalid menu choice"
	exit 1
fi
