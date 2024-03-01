{ inputs
, outputs
, lib
, config
, pkgs
, ...
}:
let
  postSwitch = ''
    notify-send -i display "Display profile" "$AUTORANDR_CURRENT_PROFILE"

    # Restart i3/polybar
    i3-msg restart
    sleep 0.1
    "$HOME/.config/polybar/scripts/launch.sh"
    "$HOME/.config/i3/scripts/i3-workspace-output";
    "$HOME/.config/i3/scripts/xset.sh";
  '';
  dpi192 = ''
    xrandr --dpi 192;
    sleep 0.1;
    echo "Xft.dpi: 192" | xrdb -merge;
  '';
  dpi156 = ''
    xrandr --dpi 156;
    sleep 0.1;
    echo "Xft.dpi: 156" | xrdb -merge;
  '';
  noscreenoff = ''
    xset -dpms
    xset s off
  '';

  aero = ''
    case "$AUTORANDR_CURRENT_PROFILE" in
    default)
        DPI=120
        ;;
    home)
        DPI=156
        ${noscreenoff}
        ;;
    work)
        DPI=144
        ;;
    *)
    echo "Unknown profile: $AUTORANDR_CURRENT_PROFILE"
    exit 1
    esac

    xrandr --dpi $DPI;
    echo "Xft.dpi: $DPI" | ${pkgs.xorg.xrdb}/bin/xrdb -merge
  '';
in
{
  home.packages = with pkgs;
    [
      arandr
      xlayoutdisplay
    ];
  # From here
  services.autorandr.enable = true;
  programs.autorandr = {
    enable = true;
    hooks.postswitch = {
      "shared" = postSwitch;
      # "change-background" = builtins.readFile ./change-background.sh;
      "change-dpi" = aero;
    };
  };
}
