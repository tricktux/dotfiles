{ config, pkgs, callPackage, ... }:
{
  users.extraGroups.vboxusers.members = [ "reinaldo" ];
  virtualisation.virtualbox = {
    host = {
      enable = true;
      enableExtensionPack = true;
    };
    guest = {
      enable = true;
      x11 = true;
    };
  };
}
