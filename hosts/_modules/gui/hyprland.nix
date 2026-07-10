{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.local.gui.hypr;
in
{
  options.local.gui.hypr.enable = mkEnableOption "Enable Hyprland";

  config = mkIf cfg.enable {
    local.gui.enable = true;

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

    # programs.regreet.settings = {
    #   remember = true;
    #   remember_session = true;

    #   default_session.command = "Hyprland";
    # };

    programs.hyprlock.enable = true;
    services.hypridle.enable = true;

    security.pam.services.hyprlock = { };
  };
}
