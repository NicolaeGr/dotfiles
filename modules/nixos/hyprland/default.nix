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
      xwayland.enable = true;
    };

    hardware = {
      opengl = {
        enable = true;

        driSupport32Bit = true;
      };
    };

    xdg.portal.enable = true;
    xdg.portal.extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];

    services.displayManager.sddm = {
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

      kitty

      rofi-wayland

      dunst
      libnotify

      swww
      waybar

      hyprlock
      hyprshot
      hypridle

      unstable.kanshi

      unstable.gnome-calculator
      unstable.nautilus
      unstable.cheese
      unstable.baobab
      unstable.loupe
    ];

    services.libinput.enable = true;
  };
}
