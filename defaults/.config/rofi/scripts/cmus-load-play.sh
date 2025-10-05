#!/usr/bin/env bash
# filepath: $HOME/.config/rofi/scripts/cmus-load-play.sh

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 <music_folder_path>"
  exit 1
fi

music_folder="$1"

# Check if cmus is running
if ! pgrep -x cmus >/dev/null; then
  # Start cmus in a terminal
  $TERMINAL --title cmus-fixed-title cmus &

  # Wait for cmus to be ready to accept commands
  echo "Starting cmus..."
  until cmus-remote -Q >/dev/null 2>&1; do
    sleep 0.1
  done
  echo "cmus is ready!"
fi

# Clear library and load the specified folder
cmus-remote -c -l
cmus-remote -l "$music_folder"

# Enable shuffle and start playing
cmus-remote -C "set repeat"
cmus-remote -C "set shuffle"
cmus-remote -s
cmus-remote -l -n

echo "Loaded and playing: $music_folder"
