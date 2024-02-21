{ config, pkgs, callPackage, ... }:
{
  services.xserver.videoDrivers = [ "modesetting" ];
}
