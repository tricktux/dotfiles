{ config, pkgs, callPackage, ... }:

{
  # https://nixos.wiki/wiki/Bluetooth
  environment.systemPackages = with pkgs; [
    pavucontrol
    blueman
  ];

  services.blueman.enable = true;
  hardware = {
    pulseaudio.extraConfig = "
      load-module module-switch-on-connect
      ";
    bluetooth = {
      # rtkit is optional but recommended
      enable = true; # enables support for Bluetooth
      powerOnBoot = true; # powers up the default Bluetooth controller on boot
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
      };
    };
  };
}
