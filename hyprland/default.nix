{ inputs, options, config, lib, pkgs, ... }: {

  options = {
    hyprland.enable = lib.mkEnableOption {
      default = false;
      description = "Enable Hyprland";
    };
  };

  config = lib.mkIf config.hyprland.enable {
    programs.hyprland = {
      enable = true;
      # package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      package = pkgs.unstable.hyprland;

      xwayland.enable = true;
    };

    hardware = {
      opengl = {
        enable = true;
        # package = pkgs.unstable.mesa.drivers;

        driSupport32Bit = true;
        # package32 = pkgs.unstable.pkgsi686Linux.mesa.drivers;
      };
    };

    xdg.portal.enable = true;
    xdg.portal.extraPortals = with pkgs; [
      # xdg-desktop-portal-gtk
      # xdg-desktop-portal-hyprland
    ];

    services.xserver.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };

    services.xserver.enable = true;

    security.polkit.enable = true;

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

    environment.systemPackages = with pkgs; [
      polkit
      sddm

      waybar
      (waybar.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
      }))

      kitty

      rofi-wayland

      dunst
      libnotify

      swww

      unstable.hyprlock
      unstable.hyprshot
      unstable.hypridle
      unstable.hyprcursor

      unstable.kanshi
    ];

    services.xserver.libinput.enable = true;
  };
}
