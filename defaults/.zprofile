#
# ~/.zprofile
#

typeset -U path
path=(~/.local/bin $path[@])

if [ -z "$DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ]; then
	exec startx
fi
