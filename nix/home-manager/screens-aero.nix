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
    xset -dpms;
    xset s off;
  '';
in
{
  home.packages = with pkgs; [
    arandr
    xlayoutdisplay
  ];
  # From here
  services.autorandr.enable = true;
  programs.autorandr = {
    enable = true;
    profiles = {
      "main" = {
        fingerprint = {
          eDP = "00ffffffffffff0030e4ad0600000000001e0104a51d127807bbe5a5534c9e270b505400000001010101010101010101010101010101ec6800a0a0402e60302036001eb31000001af34500a0a0402e60302036001eb31000001a00000000000000000000000000000000000000000002000726ff0a3cc80f0b26c80000000073";
        };
        config = {
          eDP = {
            enable = true;
            primary = true;
            position = "0x0";
            mode = "2560x1600";
          };
        };
        hooks.postswitch = postSwitch + " " + dpi156;
      };
      "home" = {
        fingerprint = {
          eDP = "00ffffffffffff0030e4ad0600000000001e0104a51d127807bbe5a5534c9e270b505400000001010101010101010101010101010101ec6800a0a0402e60302036001eb31000001af34500a0a0402e60302036001eb31000001a00000000000000000000000000000000000000000002000726ff0a3cc80f0b26c80000000073";
          DisplayPort-3 = "00ffffffffffff0005e3902764f20000201f0103803c22782a67a1a5554da2270e5054bfef00d1c0b30095008180814081c00101010122cc0050f0703e801810350055502100001aa36600a0f0701f803020350055502100001a000000fc005532373930420a202020202020000000fd0017501ea03c000a20202020202001f8020333f14c9004031f1301125d5e5f000023090707830100006d030c001000187820006001020367d85dc401788001e30f000c565e00a0a0a029503020350055502100001e023a801871382d40582c450055502100001e011d007251d01e206e28550055502100001e4d6c80a070703e8030203a0055502100001a0000000031";
          DisplayPort-2 = "00ffffffffffff001e6d085b08aa0400081b0103803c2278ea3035a7554ea3260f50542108007140818081c0a9c0d1c0810001010101b8ce0050f0705a8018108a0058542100001e04740030f2705a80b0588a0058542100001a000000fd00383d1e873c000a202020202020000000fc004c4720556c7472612048440a200180020330714d902220050403020100005d5e5f230907076d030c001000983c20006001020367d85dc401788001e30f0006023a801871382d40582c450058542100001a565e00a0a0a029503020350058542100001a000000000000000000000000000000000000000000000000000000000000000000000000000000000000008d";
        };
        config = {
          DisplayPort-3 = {
            crtc = 0;
            enable = true;
            primary = true;
            position = "2560x0";
            rate = "60.00";
            mode = "3840x2160";
          };
          eDP = {
            enable = true;
            crtc = 1;
            mode = "2560x1600";
            position = "0x280";
            rate = "59.99";
          };
          DisplayPort-2 = {
            enable = true;
            crtc = 2;
            primary = true;
            position = "2560x0";
            rate = "60.00";
            mode = "3840x2160";
          };
        };
        hooks.postswitch = postSwitch + " " + dpi156 + " " + noscreenoff;
      };
    };
  };
}
