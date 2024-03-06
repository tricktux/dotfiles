{ config, pkgs, callPackage, ... }:
{
  # Client
  programs.ssh = {
    agentTimeout = "2h";
    startAgent = true;
  };
}
