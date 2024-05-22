{ lib, config, pkgs, username, inputs, ... }:
{
  environment.sessionVariables = rec {
    WLD_NO_HARDWARE_CURSORS = "1";

    NIXOS_OZONE_WL = "1";
  };

  environment.systemPackages = with pkgs; [
    inputs.envycontrol.packages.x86_64-linux.default
    nvtop
    nvtop-amd
    nvtop-nvidia

    glmark2
    glxinfo
  ];
}
