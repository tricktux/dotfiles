#!/bin/sh

#The command for starting compton
#always keep the -b argument!
COMPTON="compton -b --paint-on-overlay"

if pgrep -x "compton" > /dev/null
then
	killall compton
else
	$COMPTON
fi
