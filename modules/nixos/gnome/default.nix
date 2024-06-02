{ options, config, lib, pkgs, ... }: {
  options = {
    gnome.enable = lib.mkEnableOption {
      default = false;
      description = "Enable GNOME desktop environment";
    };
  };

  config = lib.mkIf config.gnome.enable {
    services.xserver = {
      enable = true;

      desktopManager.gnome.enable = true;
    };

    xdg.portal.enable = true;

    # environment.gnome.excludePackages = (with pkgs; [
    #   gnome-photos
    #   gnome-tour
    # ]);

    environment.systemPackages = with pkgs;[ gnome.adwaita-icon-theme ];

    # nixpkgs.config.allowAliases = false;
    hardware.sensor.iio.enable = true;
    services.gnome.core-shell.enable = true;
  };
}
