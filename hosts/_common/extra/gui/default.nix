{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [ ./hyprland ];

  options = {
    extra.gui.enable = lib.mkEnableOption "Enable GUI tools";
  };

  config = lib.mkIf config.extra.gui.enable {
    home-manager.sharedModules = [ ({ extra.gui.enable = true; }) ];

    services.gvfs.enable = true;
    services.libinput.enable = true;

    programs.dconf.enable = true;

    environment.systemPackages = with pkgs; [
      # Auto Mount
      udisks2
      udiskie
      gparted

      #Amd GPU
      libva
      libva-utils
      vdpauinfo
    ];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;

      extraPackages = with pkgs; [
        vulkan-tools
        mesa
        libva-vdpau-driver
      ];
    };

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
      config = {
        common = {
          default = [ "gtk" ];
        };
      };
    };

    security.polkit.enable = true;

    services.displayManager = {
      enable = true;
      gdm = {
        enable = true;
        autoSuspend = false;
      };
    };

    services.xserver.enable = true;
    services.xserver.xkb = {
      layout = "ro";
      variant = "";
    };
  };
}
