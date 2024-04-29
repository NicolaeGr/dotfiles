{ config, pkgs, username, inputs, ... }: {

  environment.sessionVariables = rec {
    WLD_NO_HARDWARE_CURSORS = "1";

    NIXOS_OZONE_WL = "1";
  };

  environment.systemPackages = with pkgs; [
    inputs.envycontrol.packages.x86_64-linux.default
    nvtop-amd

    glmark2
  ];

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };

      nvidiaBusId = "PCI:1:0:0";
      amdgpuBusId = "PCI:5:0:0";
    };

    powerManagement.enable = false;
    powerManagement.finegrained = false;

    open = true;
    nvidiaSettings = true;

    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
