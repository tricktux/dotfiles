#!/usr/bin/env bash

sleep 0.2 &&
	scrot -fz -q 10 --line style=dash,width=3,color='red' \
		-s "$HOME/.cache/%Y-%m-%d_%T_scrot.png" \
		-e 'xclip -selection clipboard -target image/png -i $f'
