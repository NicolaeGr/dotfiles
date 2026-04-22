{
  lib,
  configLib,
  pkgs,
  ...
}:
{
  imports = lib.flatten [ (configLib.scanPaths ./.) ];

  boot.kernelModules = [
    "coretemp"
    "nct6775"
  ];
  environment.systemPackages = with pkgs; [
    lm_sensors
  ];
}
