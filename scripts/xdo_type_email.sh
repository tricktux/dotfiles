#!/bin/bash 

# Sat Nov 25 2017 11:55: This is suppose to work but it doesnt 
WID=`xdotool search --name "Mozilla Firefox" | head -1`
xdotool type --window $WID rmolin88@gmail.com
# xdotool key "Tab"
