{ inputs
, outputs
, lib
, config
, pkgs
, ...
}: {
  home.packages = with pkgs; [
    # Auto-mount USB drives
    gphoto2fs
    mtpfs
    udisks
    udiskie
  ];

  services.blueman-applet.enable = true;
  # TODO
  # sudo install -Dm644 /home/reinaldo/.config/polybar/scripts/95-usb.rules /etc/udev/rules.d/95-usb.rules
  # home.file."95-usb.rules".source = ./95-usb.rules;

  systemd.user.services.wallpaperpy = {
    Unit = {
      Description = "Change wallpapers every so often";
      Wants = [ "network-online.target" ];
      After = [ "network-online.target" ];
    };
    Service = {
      Type = "oneshot";
      Environment = "DISPLAY=:0";
      ExecStart = "${pkgs.wallpaperpy}/bin/wallpaper.py";
    };
    Install = { WantedBy = [ "default.target" ]; };
  };
  systemd.user.timers.wallpaperpy = {
    Unit = { Description = "Change wallpapers every so often"; };
    Timer = {
      OnBootSec = "30";
      OnUnitActiveSec = "24h";
    };
    Install = { WantedBy = [ "timers.target" ]; };
  };
}
