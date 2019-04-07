#!/bin/bash

file_path=/tmp/kb_layout_is_dvorak

if [[ -f $file_path ]] ; then
	setxkbmap -layout us
	rm $file_path
else
	setxkbmap -layout us -variant dvorak
	touch $file_path
fi 
