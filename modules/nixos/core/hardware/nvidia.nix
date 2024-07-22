{ options, config, lib, pkgs, inputs, ... }: {
  options = {
    nvidia.enable = lib.mkEnableOption {
      default = false;
      description = "Enable NVIDIA support";
    };
  };

  config = lib.mkIf config.nvidia.enable {
    environment.sessionVariables = rec {
      WLD_NO_HARDWARE_CURSORS = "1";

      NIXOS_OZONE_WL = "1";
    };

    environment.systemPackages = with pkgs; [
      inputs.envycontrol.packages.x86_64-linux.default
      nvtopPackages.full


      glmark2
      glxinfo
    ];
  };
}
