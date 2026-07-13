{
  lib,
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
    };

    xdg.portal.config.hyprland = {
      default = [
        "hyprland"
        "gtk"
      ];
      "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
    };

    programs.hyprlock.enable = true;
    services.hypridle.enable = true;

    security.pam.services.hyprlock = { };
  };
}
