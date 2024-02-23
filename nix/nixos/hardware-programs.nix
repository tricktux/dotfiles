{ config, pkgs, callPackage, ... }:
{
  environment.systemPackages = with pkgs; [
    fwupd
  ];
}
