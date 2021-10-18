#/usr/bin/bash

hostname=$HOSTNAME

if [[ "$hostname" = "surbook" ]]; then
  echo "found surbook"
  if [[ "$1" = "main" ]]; then
    echo "setting up main configuration"
    /usr/bin/xrandr \
      --dpi 192 \
      --output eDP1 --mode 2736x1824 --rate 60 --pos 0x0 --primary \
      --output DP1 --off \
      --output HDMI1 --off \
      --output HDMI2 --off \
      --output VIRTUAL1 --off

    echo "Xft.dpi: 192" | xrdb -merge
    # Restart polybar
    "$HOME/.config/polybar/scripts/launch.sh"
    notify-send "xrandr" \
      "Configuration '$1' set!" \
      -a 'arandr'
    exit 0
  fi
  if [[ "$1" = "tv" ]]; then
    echo "setting up tv configuration"
    /usr/bin/xrandr \
      --dpi 96 \
      --output eDP1 --off \
      --output DP1 --mode "1920x1080tv" --rate 60 --pos 0x0 --primary \
      --output HDMI1 --off \
      --output HDMI2 --off \
      --output VIRTUAL1 --off

    echo "Xft.dpi: 96" | xrdb -merge
    # Restart polybar
    "$HOME/.config/polybar/scripts/launch.sh"
    notify-send "xrandr" \
      "Configuration '$1' set!" \
      -a 'arandr'
    exit 0
  fi

  notify-send "xrandr" \
    "Configuration '$1' not valid" \
    -u critical -a 'Arandr'
  exit 2
fi

if [[ "$hostname" = "aero" ]]; then
  echo "found surbook"
  if [[ "$1" = "main" ]]; then
    echo "setting up main configuration"
    /usr/bin/xrandr \
      --dpi 192 \
      --output eDP --mode 2560x1600 --rate 60 --pos 0x0 --primary \
      --output HDMI-A-0 --off \
      --output DisplayPort-0 --off

    echo "Xft.dpi: 192" | xrdb -merge
    # Restart polybar
    "$HOME/.config/polybar/scripts/launch.sh"
    notify-send "xrandr" \
      "Configuration '$1' set!" \
      -a 'arandr'
    exit 0
  fi
  if [[ "$1" = "tv" ]]; then
    echo "setting up tv configuration"
    /usr/bin/xrandr \
      --dpi 96 \
      --output eDP --off \
      --output HDMI-A-0 --off \
      --output DisplayPort-0 --mode 3840x2160 --rate 30 --pos 0x0 --primary

    echo "Xft.dpi: 96" | xrdb -merge
    # Restart polybar
    "$HOME/.config/polybar/scripts/launch.sh"
    notify-send "xrandr" \
      "Configuration '$1' set!" \
      -a 'arandr'
    exit 0
  fi

  notify-send "xrandr" \
    "Configuration '$1' not valid" \
    -u critical -a 'Arandr'
  exit 2
fi

if [[ "$hostname" = "predator" ]]; then
  echo "found predator"
  if [[ "$1" = "main" ]]; then
    echo "setting up main configuration"
    /usr/bin/xrandr \
      --dpi 156 \
      --output DP-2 --mode 3840x2160 --rate 60 --pos 0x0 --primary \
      --output HDMI-0 --mode 1920x1080 --rate 60 --pos 3840x0 \
      --output DVI-D-0 --off \
      --output DP-0 --off \
      --output DP-1 --off \
      --output DP-3 --off \
      --output DP-4 --off \
      --output DP-5 --off

    echo "Xft.dpi: 156" | xrdb -merge

    # Restart polybar
    "$HOME/.config/polybar/scripts/launch.sh"
    notify-send "xrandr" \
      "Configuration '$1' set!" \
      -a 'arandr'
    exit 0
  fi

  notify-send "xrandr" \
    "Configuration '$1' not valid" \
    -u critical -a 'Arandr'
  exit 2
fi

if [[ "$hostname" = "helios" ]]; then
  echo "found helios"
  if [[ "$1" = "main" ]]; then
    echo "setting up main configuration"
    /usr/bin/xrandr \
      --dpi 144 \
      --output eDP1 --mode 1920x1080 --rate 144 --pos 0x0 --primary \
      --output VIRTUAL1 --off

    echo "Xft.dpi: 144" | xrdb -merge
    # Restart polybar
    "$HOME/.config/polybar/scripts/launch.sh"
    notify-send "xrandr" \
      "Configuration '$1' set!" \
      -a 'arandr'
    exit 0
  fi

  notify-send "xrandr" \
    "Configuration '$1' not valid" \
    -u critical -a 'Arandr'
  exit 2
fi

notify-send "xrandr" \
  "Hostname '$hostname' not valid" \
  -u critical -a 'Arandr'
exit 1
