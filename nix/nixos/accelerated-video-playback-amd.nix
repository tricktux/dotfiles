# https://nixos.wiki/wiki/Accelerated_Video_Playback
{ config, pkgs, callPackage, ... }:
{
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
  	amdvlk
	  driversi686Linux.amdvlk
      vaapiVdpau
      libvdpau-va-gl
      libva-utils # vainfo
    ];
  };
	environment.variables.AMD_VULKAN_ICD = "RADV";
}
