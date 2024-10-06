{ inputs, options, config, lib, pkgs, ... }:
let
  pkgs-unstable = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{

  options = {
    hyprland.enable = lib.mkEnableOption {
      default = false;
      description = "Enable Hyprland";
    };
  };

  config = lib.mkIf config.hyprland.enable {
    programs.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      # package = pkgs.unstable.hyprland;
      # package = pkgs.hyprland;

      xwayland.enable = true;
    };

    hardware = {
      opengl = {
        enable = true;
        # package = pkgs.unstable.mesa;
        package = pkgs-unstable.mesa.drivers;

        driSupport32Bit = true;
        # package32 = pkgs.unstable.pkgsi686Linux.mesa;
        package32 = pkgs-unstable.pkgsi686Linux.mesa.drivers;
      };
    };

    xdg.portal.enable = true;
    xdg.portal.extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      # xdg-desktop-portal-hyprland
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
      unstable.sddm

      unstable.waybar
      # (unstable.waybar.overrideAttrs (oldAttrs: {
      #   mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
      # }))

      kitty

      unstable.rofi-wayland

      dunst
      libnotify

      swww

      hyprlock
      hyprshot
      hypridle
      hyprcursor

      unstable.kanshi

      unstable.gnome-calculator
      unstable.nautilus
      unstable.cheese
      unstable.baobab
      unstable.loupe

      unstable.libinput
    ];

    services.libinput.enable = true;
  };
}
