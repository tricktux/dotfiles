#!/usr/bin/env bash


destination_dir="$XDG_DATA_HOME/screenshots"
mkdir -p "$destination_dir"
sleep 0.2 &&
	scrot -fz -q 10 --line style=dash,width=3,color='red' \
		-s "$destination_dir/%Y-%m-%d_%T_scrot.png" \
		-e 'xclip -selection clipboard -target image/png -i $f'
