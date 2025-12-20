#
# ~/.zprofile
#

# Global exports

# Tue May 19 2020 06:32: Since using a desktop manager this file is not sourced
# Sun Oct 26 2025 18:16 Not using a desktop manager again
if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
    # Wayland
    # if uwsm check may-start; then
    #   exec uwsm start hyprland.desktop
    # fi

    # Set desktop environment for Sway
    export XDG_CURRENT_DESKTOP=sway
    export XDG_SESSION_DESKTOP=sway
    exec sway > /tmp/sway_debug.log 2>&1

    # Xorg
    # Will source ~/.xinitrc and ~/.xserverrc
    # exec startx
fi
