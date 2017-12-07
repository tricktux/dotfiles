# File:					scratchpad_switch.sh
# Description:			Script to toggle a program in scratchpad. If the program is not running
#    					start it
# Author:				Reinaldo Molina <rmolin88@gmail.com>
# Version:				0.0.0
# Last Modified: Sep 30 2017 18:19
# Created: Sep 30 2017 18:19
# Note: Argument is the name of the program

if [ $# -lt 1 ]
then
	echo "Usage: Should have 1 command-line argument. The name of the program to put in the
	scratchpad"
fi

if pgrep -x $1 > /dev/null
then
	# echo "Running"
	i3-msg [instance="$1"] scratchpad show
else
	# i3-msg exec i3-sensible-terminal -e $1 -name $1
	i3-msg exec "termite -e $1" $1
	i3-msg for_window [instance="$1"] move to scratchpad
fi


