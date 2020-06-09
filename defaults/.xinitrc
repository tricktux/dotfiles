#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap
# You also need to go to the file /etc/sddm.conf
# and change the Session there as well. Values for this
# setup can be found at /usr/share/xsessions/
# export XDG_CURRENT_DESKTOP=Budgie:GNOME
# desktop=budgie-desktop
desktop=startlxde
# desktop=startlxqt
# desktop=gnome-session
extra_resources=$userresources-$(hostname)

# merge in defaults and keymaps
if [ -f $sysresources ]; then
  xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
  xmodmap $sysmodmap
fi

# Give priority to a file like .Xresources-predator
if [ -f "$extra_resources" ]; then
  xrdb -merge "$extra_resources"
# If that file not present then load regular .Xresources
elif [ -f "$userresources" ]; then
  xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
  xmodmap "$usermodmap"
fi

# start some nice programs
if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/?*.sh; do
    [ -x $f ] && . $f
  done
  unset f
fi

# Make sure this is before the 'exec' command or it won't be sourced.
[ -f /etc/xprofile ] && source /etc/xprofile
[ -f ~/.xprofile ] && source ~/.xprofile
[ -f ~/.xmodmap ] && xmodmap ~/.xmodmap

# Activate numlock
[ -f /usr/bin/numlockx ] && numlockx &

exec i3 -V >>~/.cache/i3log-$(date +'%F-%k-%M-%S') 2>&1
