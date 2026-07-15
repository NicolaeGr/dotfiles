{
  lib,
  pkgs,
  config,
  inputs,
  configLib,
  ...
}:
{
  imports = (configLib.scanPaths ./.);

  options.local.gui.hypr.enable = lib.mkEnableOption "Enable Hyprland";

  config = lib.mkIf config.local.gui.hypr.enable {
    local.gui.enable = true;

    packages = with pkgs; [
      kitty

      inputs.nosh.packages.${pkgs.stdenv.hostPlatform.system}.default
      awww
    ];

    files = {
      ".config/hypr/hyprland.lua" = {
        text = ''
          require ("modules")
        '';
      };
      ".config/hypr/modules" = {
        source = configLib.outOfStorePath ./modules;
      };
      ".config/hypr/backgrounds" = {
        source = configLib.outOfStorePath ./bgs;
      };
    };
  };
}
