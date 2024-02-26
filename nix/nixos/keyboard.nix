{ config, pkgs, callPackage, ... }:
{
  environment.systemPackages = with pkgs; [
    xorg.xmodmap
  ];
  services.xserver = {
    autoRepeatDelay = 180;
    autoRepeatInterval = 60;

    xkb = {
      layout = "us";
      variant = "";
      options = "caps:ctrl_modifier";
    };
  };
}
