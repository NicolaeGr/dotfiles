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
      boot.kernelModules = [
        "i2c-dev"
        "i2c-piix4"
      ];
      boot.kernelParams = [ "acpi_enforce_resources=lax" ];

      services.hardware.openrgb = {
        enable = true;
        package = pkgs.openrgb-with-all-plugins;
        motherboard = "amd";
        server.port = 6742;
        startupProfile = "default";
      };

      systemd.services.openrgb-suspend = {
        description = "Turn off RGB before sleep";
        before = [ "systemd-suspend.service" ];
        wantedBy = [ "suspend.target" ];

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          StateDirectory = "OpenRGB";
          WorkingDirectory = "/var/lib/OpenRGB";
        };

        script =
          let
            openrgbExe = lib.getExe config.services.hardware.openrgb.package;
            sleepExe = lib.getExe' pkgs.coreutils "sleep";
          in
          ''
            ${openrgbExe} --config /var/lib/OpenRGB --save-profile default
            ${sleepExe} 1
            ${openrgbExe} --config /var/lib/OpenRGB --profile Off
            ${sleepExe} 1
          '';
      };

      systemd.services.openrgb-resume = {
        description = "Restore RGB profile after wake";
        after = [ "systemd-suspend.service" ];
        wantedBy = [ "suspend.target" ];

        serviceConfig = {
          Type = "oneshot";
        };

        script =
          let
            openrgbExe = lib.getExe config.services.hardware.openrgb.package;
            sleepExe = lib.getExe' pkgs.coreutils "sleep";
          in
          ''
            ${sleepExe} 3
            ${pkgs.systemd}/bin/systemctl restart openrgb.service
            ${sleepExe} 2
            ${openrgbExe} --config /var/lib/OpenRGB --profile default
          '';
      };
    }
  ];
}
