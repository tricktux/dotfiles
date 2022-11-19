#!/usr/bin/bash

hostname=$HOSTNAME

if [[ ! -f /usr/bin/xrandr ]]; then
  notify-send "xrandr" \
    "xrandr program not available" \
    -u critical -a 'Arandr'
  exit 1
fi

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
  echo "found aero"
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
  elif [[ "$1" = "tv" ]]; then
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
  elif [[ "$1" = "home_dock" ]]; then
    echo "setting up home_dock configuration"
    /usr/bin/xrandr \
      --dpi 156 \
      --output eDP --off \
      --output HDMI-A-0 --mode 3840x2160 --rate 60 --pos 3840x0 \
      --output DisplayPort-0 --mode 3840x2160 --rate 60 --pos 0x0 --primary

    echo "Xft.dpi: 156" | xrdb -merge
    # Restart polybar
    "$HOME/.config/polybar/scripts/launch.sh"
    notify-send "xrandr" \
      "Configuration '$1' set!" \
      -a 'arandr'
    exit 0
  elif [[ "$1" = "work_dock" ]]; then
    echo "setting up work_dock configuration"
    xrandr \
      --dpi 156 \
      --output eDP --off \
      --output HDMI-A-0 --off \
      --output DisplayPort-0 --off \
      --output DisplayPort-1 --mode 3840x2160 --rate 60 --pos 3840x0 \
      --output DisplayPort-2 --off \
      --output DisplayPort-3 --mode 3840x2160 --rate 60 --pos 0x0 --primary

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

if [[ "$hostname" = "predator" ]]; then
  echo "found predator"
  if [[ "$1" = "main" ]]; then
    echo "setting up main configuration"
    /usr/bin/xrandr \
      --dpi 156 \
      --output DVI-D-0 --off \
      --output HDMI-0 --off \
      --output DP-2 --mode 3840x2160 --rate 60 --pos 0x0 --primary \
      --output DP-1 --off \
      --output DP-4 --mode 3840x2160 --rate 60 --pos 3840x0 \
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

if [[ "$hostname" = "xps" ]]; then
  echo "found xps"
  if [[ "$1" = "main" ]]; then
    echo "setting up main configuration"

    xrandr \
        --dpi 232 \
        --output eDP-1-1 --mode 3456x2160 --rate 60 --pos 0x0 --primary \
        --output DP-1-1 --off \
        --output HDMI-1-1 --off \
        --output DP-1-2 --off \
        --output DP-1-3 --off \
        --output DP-1-4 --off

    echo "Xft.dpi: 232" | xrdb -merge
    # Restart polybar
    "$HOME/.config/polybar/scripts/launch.sh"
    i3-msg restart

    notify-send "xrandr" \
      "Configuration '$1' set!" \
      -a 'arandr'
    exit 0
  fi

  if [[ "$1" = "home_dock" ]]; then
    echo "setting up home_dock configuration"

    "$HOME"/.screenlayout/home-dock.sh
    xrandr --dpi 156
    echo "Xft.dpi: 156" | xrdb -merge

    # Restart polybar
    "$HOME/.config/polybar/scripts/launch.sh"
    i3-msg restart

    notify-send "xrandr" \
      "Configuration '$1' set!" \
      -a 'arandr'
    exit 0
  fi

  if [[ "$1" = "work_dock" ]]; then
    echo "setting up home_dock configuration"

    "$HOME"/.screenlayout/work-dock.sh
    xrandr --dpi 156
    echo "Xft.dpi: 156" | xrdb -merge

    # Restart polybar
    "$HOME/.config/polybar/scripts/launch.sh"
    i3-msg restart

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
