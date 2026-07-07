{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    inputs.nosh.nixosModules.nosh
  ];

  options = {
    extra.gui.hyprland.enable = lib.mkEnableOption "Enable Hyprland";
  };

  config = lib.mkIf config.extra.gui.hyprland.enable {
    home-manager.sharedModules = [
      ({
        extra.hyprland.enable = true;
      })
    ];

    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;

      package = pkgs.unstable.hyprland;
      portalPackage = pkgs.unstable.xdg-desktop-portal-hyprland;
    };

    xdg.portal.config.hyprland = {
      default = [
        "hyprland"
        "gtk"
      ];
    };

    services.nosh.enable = true;

    services.displayManager = {
      sessionPackages = with pkgs.unstable; [ hyprland ];
    };

    systemd = {
      user.services.polkit-gnome-authentication-agent-1 = {
        description = "polkit-gnome-authentication-agent-1";
        wantedBy = [ "graphical-session.target" ];
        wants = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
    };

    programs.seahorse.enable = true;
    services.gnome.gnome-keyring.enable = true;
    environment.systemPackages = with pkgs; [
      seahorse
      gnome-keyring
      libsecret

      wl-clipboard

      ddcutil
    ];

    hardware.i2c.enable = true;

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      WLD_NO_HARDWARE_CURSORS = "1";

      QT_QPA_PLATFORM = "wayland";
      QT_QPA_PLATFORMTHEME = "qt5ct";
      MOZ_ENABLE_WAYLAND = "1";
      MOZ_WEBRENDER = "1";
      WLR_RENDERER_ALLOW_SOFTWARE = "1";

      GDK_BACKEND = "wayland";
    };
  };
}
