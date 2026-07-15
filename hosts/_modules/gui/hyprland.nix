{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
with lib;
let
  cfg = config.local.gui.hypr;
in
{
  imports = [
    inputs.nosh.nixosModules.nosh
  ];

  options.local.gui.hypr.enable = mkEnableOption "Enable Hyprland";

  config = mkIf cfg.enable {
    local.gui.enable = true;
    hjem.extraModules = [ { local.gui.hypr.enable = true; } ];

    programs.hyprland = {
      enable = true;
      withUWSM = true;

      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage =
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    };

    services.hypridle.enable = true;

    security.pam.services.hyprlock = { };
  };
}
