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

  local.hw.audio.enable = true;

  local.hw.splitKb = true;

  services.xserver.videoDrivers = lib.mkDefault [ "nvidia" ];
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;

    powerManagement.enable = true;
    nvidiaSettings = lib.mkIf config.local.gui.enable true;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  boot.kernelModules = [
    "it87"
    "i2c-dev"
  ];
  boot.extraModprobeConfig = ''
    options it87 ignore_resource_conflict=1
  '';
  boot.kernelParams = [ "acpi_enforce_resources=lax" ];

  hardware.i2c.enable = true;
  boot.extraModulePackages = [ config.boot.kernelPackages.it87 ];

  services.hardware.openrgb = {
    enable = true;
    package = pkgs.openrgb-with-all-plugins;
    motherboard = "amd";
    server.port = 6742;
  };

  environment.systemPackages = with pkgs; [
    lm_sensors
  ];
  programs.coolercontrol.enable = true;

}
