{
  lib,
  pkgs,
  config,
  configLib,
  ...
}:
with lib;
let
  cfg = config.local.gui;
in
{
  imports = (configLib.scanPaths ./.);

  options.local.gui = {
    enable = mkEnableOption "Enable base GUI support";
  };

  config = mkIf cfg.enable {
    hjem.extraModules = [ { local.gui.enable = true; } ];

    xdg.autostart.enable = true;
    xdg.portal = {
      enable = true;
      config.common.default = [ "gtk" ];
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    services.dbus.enable = true;
    programs.dconf.enable = true;

    environment.systemPackages = with pkgs; [
      xdg-utils
      shared-mime-info

      wl-clipboard

    ];

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";

      QT_QPA_PLATFORM = "wayland;xcb";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

      SDL_VIDEODRIVER = "wayland";

      CLUTTER_BACKEND = "wayland";

      _JAVA_AWT_WM_NONREPARENTING = "1";
    };
  };
}
