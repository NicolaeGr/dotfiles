{ options, config, libs, pkgs, ... }: {
  options = {
    themes.enable = libs.mkEnableOption {
      default = false;
      description = "Enable themes support";
    };
  };

  config = libs.mkIf config.themes.enable {
    # home.packages = with pkgs; [
    #   gnome3.gnome-tweaks

    #   adwaita-qt6

    #   adw-gtk3
    #   phinger-cursors

    #   gradience
    # ];

    # dconf.settings = {
    #   "org/gnome/desktop/interface" = {
    #     color-scheme = "prefer-dark";
    #   };
    # };

    # gtk = {
    #   enable = true;
    #   theme = {
    #     name = "adw-gtk3";
    #     package = pkgs.adw-gtk3;
    #   };

    #   cursorTheme = {
    #     name = "Phinger";
    #     package = pkgs.phinger-cursors;
    #   };

    #   iconTheme = {
    #     name = "Adwaita";
    #     package = pkgs.gnome.gnome-themes-extra;
    #   };
    # };

    # qt = {
    #   enable = true;
    #   platformTheme = "gnome";
    #   style.name = "adwaita-dark";
    # };
  };
}
