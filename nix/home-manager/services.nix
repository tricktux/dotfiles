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

  # TODO
  # sudo install -Dm644 /home/reinaldo/.config/polybar/scripts/95-usb.rules /etc/udev/rules.d/95-usb.rules
  # home.file."95-usb.rules".source = ./95-usb.rules;

}
