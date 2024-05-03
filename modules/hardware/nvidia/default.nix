{ lib, config, pkgs, username, inputs, ... }:
{

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

    extraPackages = with pkgs; [
      amdvlk
    ];

    extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
    ];
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

    open = false;
    nvidiaSettings = true;

    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Cooling management
  services.thermald.enable = lib.mkDefault true;

  # tlp defaults to "powersave", which doesn't exist on this laptop
  services.tlp.settings = {
    CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";
  };
}
