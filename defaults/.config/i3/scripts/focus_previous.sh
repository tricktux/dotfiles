#!/bin/bash

# epochMillis: print the amount of millis since epoch time on the std output stream.
epochMillis(){
	echo $(($(date +%s%N)/1000000))
}

# queue: array holding the focused window ids in order, the most recent focus is on index 0. 
queue=( )
queueLimit=8

# pushOnQueue: insert a window id on index 0 of the queue. This function also removes the given id if was already present, the queue is an ordered set.
# arg 1: window id to insert.
pushOnQueue(){
	if [ "$1" = "0x0" ]
	then
		return
	fi
	newQueue=( "$1" )
	for i in "${queue[@]}"
	do
		if [ "$1" = "$i" ]
		then
			continue
		fi
		newQueue=( ${newQueue[@]:0} "$i" )
	done
	queue=( "${newQueue[@]:0:$queueLimit}" )
}

# markQueue: put i3 marks using the window ids stored on the queue. The windows are marked using "_prevFocusX" where X is a integer corresponding with the index of the element on the queue. The previously focused window (the most recent) is marked using "_prevFocus0". This function also cleans the queue from windows that can't be marked (e.g. windows that have been closed).
markQueue(){
	queueCopy=( "${queue[@]}" )
	queue=( )
	j=0
	for i in "${queueCopy[@]}"
	do
		i3-msg "unmark _prevFocus$j" 1>/dev/null 2>&1
		if i3-msg "[id=$i] mark --add _prevFocus$j" 2>/dev/null | grep -i "\"success\":true" 1>/dev/null 2>&1 
		then
			queue=( ${queue[@]:0} "$i" )
			j=$(($j + 1))
		fi
	done
}

lastTime=$(epochMillis)
# permanence: period in millis used to determine if a window is worthy to be saved on the queue. This enables i3 window fast navigation without saving unworthy window ids.
permanence=1000

# main loop: read activated window ids continuously. 
xprop -root -spy _NET_ACTIVE_WINDOW | 
while read line
do
	
	currentTime=$(epochMillis)
	period=$(($currentTime-$lastTime))
	lastTime=$currentTime
	
	# previousFocus: window id of the previously focused (activated) window.
	previousFocus=$currentFocus
	# currentFocus: window id of the window that has just being activated.
	currentFocus=$(echo "$line" | awk -F' ' '{printf $NF}')
	
	# push the previousFocus id to the queue if the time spent on the previous window was greater than permanence. Check also to allow fast switching between two windows.
	if [ $period -gt $permanence -o "$currentFocus" = "${queue[0]}" ] 
	then
		pushOnQueue "$previousFocus"
	fi

	# if the currentFocus is marked as the previous window (_prevFocus0 or queue[0]) then swap the first two elements on the queue to allow switching.
	if [ "${queue[0]}" = "$currentFocus" ]
	then
		queue=( ${queue[1]} ${queue[0]} ${queue[@]:2} )
	fi

	markQueue

done