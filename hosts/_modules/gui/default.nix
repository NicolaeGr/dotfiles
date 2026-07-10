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
    xdg.portal = {
      enable = true;
      config.common.default = [ "gtk" ];
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    services.dbus.enable = true;

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          user = "greeter";
        };
      };
    };

    programs.regreet = {
      enable = true;
      cageArgs = [ "-s" ];
      settings = {
        background = {
          fit = "Cover";
        };
        GTK = {
          application_prefer_dark_theme = true;
          font_name = "Cantarell 16";
          icon_theme_name = "Adwaita";
          theme_name = mkDefault "Adwaita-dark";
        };
      };
    };

    systemd.services.greetd.serviceConfig = {
      Restart = lib.mkForce "always";
      RestartSec = "3";
    };

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
