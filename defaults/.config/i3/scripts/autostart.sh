# This script was created to have more control over startup applications. i3 
# starts them all at the same time, here they are synchronous

/usr/bin/feh --randomize --no-fehbg --bg-fill \
  /usr/share/backgrounds/archlinux/*

# xfsettingsd is needed by flux, must remain before it
/usr/bin/xfsettingsd --replace --daemon
# Setup config for current time of day at startup
rm /tmp/flux || echo "file did not exist"
$HOME/.config/polybar/scripts/flux_/flux \
  -v -c $HOME/.config/polybar/scripts/flux_/flux_init_config.lua \
  > /tmp/fluxinit.log 2>&1

# https://pastebin.com/tfqSNjti
# See :Man picom
picom --daemon
playerctld daemon
tmux start-server
alttab -w 1 -d 2 -frame rgb:26/8b/d2 -bg rgb:f1/f1/f1 \
  -fg rgb:55/55/55 -t 120x120 -i 120x120&
/usr/bin/synology-drive
/usr/bin/blueman-applet&
# xss-lock grabs a logind suspend inhibit lock and will use i3lock to lock the
# screen before suspend. Use loginctl lock-session to lock your screen.
xss-lock --transfer-sleep-lock -- i3lock-fancy --nofork&
$HOME/.config/polybar/scripts/launch.sh
