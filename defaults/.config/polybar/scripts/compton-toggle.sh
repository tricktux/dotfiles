#!/bin/sh

if pgrep -x "picom" > /dev/null
then
	killall picom
else
	picom -cCGF -b --vsync
fi
