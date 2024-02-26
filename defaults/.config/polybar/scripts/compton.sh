#!/usr/bin/env bash

#The icon that would change color
icon="  "

if pgrep -x "picom" > /dev/null
then
	echo "%{F#00AF02}$icon" #Green
else
	echo "%{F#65737E}$icon" #Gray
fi
