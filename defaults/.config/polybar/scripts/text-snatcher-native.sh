##!/usr/bin/env bash

# Dependencies: tesseract-ocr imagemagick flameshot
# on gnome: gnome-screenshot
# on kde: spectacle
# on x11: xsel
# on wayland: wl-clipboard

die() {
	notify-send "$1"
	exit 1
}
cleanup() {
	[[ -n $1 ]] && rm -rf "$1"
}

folder="$HOME/.screenshots"
[ -d "$folder" ] || mkdir -p "$folder" || die "failed to create folder"
SCR_IMG="${folder}/$(date +%Y%m%d%H%M%S)-img2text"

# shellcheck disable=SC2064
trap "cleanup '$SCR_IMG'" EXIT

notify-send "Select the area of the text"
if which "spectacle" &>/dev/null; then
	spectacle -r -o "$SCR_IMG.png" || die "failed to take screenshot"
else
	flameshot gui -p "$SCR_IMG.png" || die "failed to take screenshot"
fi

[ -f "$SCR_IMG.png" ] || die "failed to take screenshot"

# increase image quality with option -q from default 75 to 100
mogrify -modulate 100,0 -resize 400% "$SCR_IMG.png" || die "failed to convert image"
#should increase detection rate

tesseract "$SCR_IMG.png" "$SCR_IMG" &>/dev/null || die "failed to extract text"
if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
	wl-copy <"$SCR_IMG.txt" || die "failed to copy text to clipboard"
else
	xsel -b -i <"$SCR_IMG.txt" || die "failed to copy text to clipboard"
fi
notify-send "Text extracted at: $SCR_IMG.txt"
exit
