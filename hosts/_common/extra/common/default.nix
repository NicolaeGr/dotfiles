{
  lib,
  config,
  configLib,
  pkgs,
  ...
}:
{
  imports = lib.flatten [ (configLib.scanPaths ./.) ];

  options = {
    extra.common.enable = lib.mkEnableOption {
      default = false;
      description = "Enable common extra packages";
    };
  };

  config = lib.mkIf config.extra.common.enable {
    extra.common.devMode.enable = true;

    environment.systemPackages =
      with pkgs;
      lib.mkIf config.extra.gui.enable [
        discord
      ];
  };
}
