{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  options.extra.hardware.nvidia = {
    enable = lib.mkEnableOption "Enable NVIDIA support";
  };

  config = lib.mkIf config.extra.hardware.nvidia.enable {
    environment.systemPackages = with pkgs; [
      inputs.envycontrol.packages.x86_64-linux.default
      nvtopPackages.full

      glmark2
      glxinfo
    ];
  };
}
