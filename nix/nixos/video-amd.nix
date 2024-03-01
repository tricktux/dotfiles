{ config, pkgs, callPackage, ... }:
{
  environment.systemPackages = with pkgs; [
    pciutils
  ];
  services.xserver.videoDrivers = [ "amdgpu" ];
}
