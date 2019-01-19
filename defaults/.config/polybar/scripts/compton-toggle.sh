#!/bin/sh

if pgrep -x "compton" > /dev/null
then
	killall compton
else
	compton --fading --daemon
fi
