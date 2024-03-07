{ config, pkgs, callPackage, ... }:
{
  environment.systemPackages = with pkgs; [
    sshfs
  ];
  # Client
  programs.ssh = {
    agentTimeout = "2h";
    startAgent = true;
  };
}
