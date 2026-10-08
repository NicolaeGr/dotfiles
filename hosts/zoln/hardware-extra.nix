{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
{
  imports = [
    inputs.hardware.nixosModules.common-cpu-amd-pstate
    inputs.hardware.nixosModules.common-pc-ssd
  ];

  config = lib.mkMerge [
    {
      local.hw.audio.enable = true;

      local.hw.splitKb = true;

      boot.kernelPackages = pkgs.linuxPackages_7_2;
    }
    {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      services.xserver.videoDrivers = lib.mkDefault [ "nvidia" ];
      hardware.nvidia = {
        open = true;
        modesetting.enable = true;

        powerManagement.enable = true;
        nvidiaSettings = lib.mkIf config.local.gui.enable true;
      };

      boot.kernelParams = [
        "nvidia-drm.modeset=1"
        "nvidia_drm.fbdev=1"
        "nvidia.NVreg_TemporaryFilePath=/var/tmp"
      ];
    }
    {
      hardware.i2c.enable = true;
      boot.extraModulePackages = [ config.boot.kernelPackages.it87 ];

      boot.kernelModules = [
        "i2c-dev"
        "i2c-piix4"

        "it87"
      ];

      boot.kernelParams = [ "acpi_enforce_resources=lax" ];
      boot.extraModprobeConfig = ''
        options it87 ignore_resource_conflict=1 force_id=0x8689
      '';

      services.hardware.openrgb = {
        enable = true;
        package = pkgs.openrgb;
        motherboard = "amd";
        server.port = 6742;
      };
    }
  ];
}
