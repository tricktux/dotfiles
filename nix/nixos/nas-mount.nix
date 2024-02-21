{ config, pkgs, callPackage, ... }:

let
  # TODO: fix uid and gid
  uid = "1000";
  gid = "100";
  credentials = "/etc/samba/credentials/share";
  path = "/home/reinaldo/.mnt/skywafer";
  ip = "192.168.1.139";
  automount_opts = "credentials=${credentials},uid=${uid},gid=${gid},x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,user,users,vers=3.0,workgroup=WORKGROUP";
in
{
  environment.systemPackages = [ pkgs.cifs-utils ];
  fileSystems = {
    "${path}/NetBackup" = {
      device = "//${ip}/NetBackup";
      fsType = "cifs";
      options = [ "${automount_opts}" ];
    };
    "${path}/home" = {
      device = "//${ip}/home";
      fsType = "cifs";
      options = [ "${automount_opts}" ];
    };
    "${path}/music" = {
      device = "//${ip}/music";
      fsType = "cifs";
      options = [ "${automount_opts}" ];
    };
    "${path}/video" = {
      device = "//${ip}/video";
      fsType = "cifs";
      options = [ "${automount_opts}" ];
    };
    "${path}/shared" = {
      device = "//${ip}/shared";
      fsType = "cifs";
      options = [ "${automount_opts}" ];
    };
  };
}
