#!/usr/bin/env bash

# This script was created to have more control over startup applications. i3
# starts them all at the same time, here they are synchronous

if [[ -x $(command -v feh) ]]; then
	feh --randomize --no-fehbg --bg-fill \
		/usr/share/backgrounds/archlinux/*
else
	printf "\n==X Please install feh\n"
fi

# xfsettingsd is needed by flux, must remain before it
if [[ -x $(command -v xfsettingsd) ]]; then
	xfsettingsd --replace --daemon
else
	printf "\n==X Please install xfsettingsd\n"
fi
# Setup config for current time of day at startup
[[ -f //tmp/flux ]] && rm /tmp/flux
flux="$HOME"/.config/polybar/scripts/flux_
if [[ -f $flux/flux ]]; then
	"$flux"/flux -v -c "$flux"/flux_init_config.lua \
		>/tmp/fluxinit.log 2>&1
else
	printf "\n==X Please install '%s'\n" "$flux"
fi

if [[ -x $(command -v alttab) ]]; then
	alttab -w 1 -d 2 -frame rgb:26/8b/d2 -bg rgb:f1/f1/f1 \
		-fg rgb:55/55/55 -t 120x120 -i 120x120 &
else
	printf "\n==X Please install alttab\n"
fi

if [[ -x $(command -v uair) ]]; then
	uair --socket /tmp/uair_pomo.socket >/tmp/uair_pomo.file &
else
	printf "\n==X Please install uair\n"
fi

if [[ -x $(command -v noisetorch) ]]; then
	noisetorch -i &
else
	printf "\n==X Please install noisetorch\n"
fi

if [[ -x $(command -v blueman-applet) ]]; then
    blueman-applet &
else
    printf "\n==X Please install blueman-applet\n"
fi

if [[ -x $(command -v nm-applet) ]]; then
    nm-applet &
else
    printf "\n==X Please install network-manager-applet\n"
fi
poly="$HOME"/.config/polybar/scripts/launch.sh
if [[ -f $poly ]]; then
	source "$poly"
else
	printf "\n==X Please install '%s'\n" "$poly"
fi
