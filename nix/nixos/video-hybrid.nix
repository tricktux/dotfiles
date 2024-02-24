{ config, pkgs, callPackage, ... }:

{
  #https://nixos.wiki/wiki/Laptop
  specialisation = {
    nvidia.configuration = {
      # Nvidia Configuration 
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware = {
        opengl.enable = true;
        nvidia = {

          # Optionally, you may need to select the appropriate driver version for your specific GPU. 
          package = config.boot.kernelPackages.nvidiaPackages.stable;

          # nvidia-drm.modeset=1 is required for some wayland compositors, e.g. sway 
          modesetting.enable = true;

          prime = {
            sync.enable = true;

            # TODO: Adjust here
            # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA 
            nvidiaBusId = "PCI:1:0:0";

            # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA 
            intelBusId = "PCI:0:2:0";
          };
        };
      };
    };
  };
}
