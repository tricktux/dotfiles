#!/usr/bin/env bash

# This script was created to have more control over startup applications. i3
# starts them all at the same time, here they are synchronous

# xfsettingsd is needed by flux, must remain before it
if [[ -x $(command -v xfsettingsd) ]]; then
	xfsettingsd --replace --daemon
else
	printf "\n==X Please install xfsettingsd\n"
fi

if [[ -x $(command -v playerctld) ]]; then
	playerctld daemon
else
	printf "\n==X Please install playerctld\n"
fi

if [[ -x $(command -v alttab) ]]; then
	alttab -w 1 -d 2 -frame rgb:26/8b/d2 -bg rgb:f1/f1/f1 \
		-fg rgb:55/55/55 -t 120x120 -i 120x120 &
else
	printf "\n==X Please install alttab\n"
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

if [[ -f /usr/bin/lxqt-policykit-agent ]]; then
	/usr/bin/lxqt-policykit-agent &
else
	printf "\n==X Please install lxqt-policykit-agent\n"
fi

if [[ -f /usr/bin/easyeffects ]]; then
	easyeffects --gapplication-service &
else
	printf "\n==X Please install easyeffects\n"
fi

if [[ -x $(command -v noisetorch) ]]; then
	noisetorch -i &
else
	printf "\n==X Please install noisetorch\n"
fi

touch /tmp/airplane_mode
$HOME/.config/polybar/scripts/get_activities -d 10 $HOME/.config/polybar/scripts/strava.ini
