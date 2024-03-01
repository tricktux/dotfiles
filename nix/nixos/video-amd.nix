{ config, pkgs, callPackage, ... }:
{
  environment.systemPackages = with pkgs; [
    pciutils
  ];
  # https://nixos.wiki/wiki/AMD_GPU
  services.xserver.videoDrivers = [ "amdgpu" ];

  # https://nixos.wiki/wiki/Accelerated_Video_Playback
  hardware.opengl = {
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
      amdvlk
      driversi686Linux.amdvlk
      vaapiVdpau
      libvdpau-va-gl
      libva-utils # vainfo
    ];
  };
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];
  environment.variables.AMD_VULKAN_ICD = "RADV";
}
