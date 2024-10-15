{ options, config, lib, pkgs, ... }: {
  options = {
    themes.enable = lib.mkEnableOption {
      default = false;
      description = "Enable themes support";
    };
  };

  config = lib.mkIf config.themes.enable {
    home.packages = with pkgs; [
      gnome3.gnome-tweaks
      gnome.adwaita-icon-theme
      hicolor-icon-theme
      vivid

      adwaita-qt6

      adw-gtk3
      phinger-cursors

      gradience
      dconf
    ];

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };

    gtk = {
      enable = true;
      theme = {
        name = "adw-gtk3-dark";
        package = pkgs.adw-gtk3;
      };

      cursorTheme = {
        name = "phinger-cursors";
        package = pkgs.phinger-cursors;
      };

      iconTheme = {
        name = "Adwaita";
        package = pkgs.gnome.gnome-themes-extra;
      };
    };

    qt = {
      enable = true;
      platformTheme.name = "gtk";
      style.name = "adw-gtk3-dark";
    };

    xdg.configFile = {
      "gtk-4.0/assets".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
      "gtk-4.0/gtk.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
      "gtk-4.0/gtk-dark.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
      "gtk-3.0/gtk.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-3.0/gtk.css";
      "gtk-3.0/gtk-dark.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-3.0/gtk-dark.css";
    };

    home = {
      sessionVariables = {
        GSETTINGS_BACKEND = "keyfile";
        #GTK_THEME = config.gtk.theme.name;
        GTK_USE_PORTAL = "1";
        # LS_COLORS = "$(vivid generate catppuccin-mocha)";
        MICRO_TRUECOLOR = "1";
        NNN_COLORS = "#04020301;4231";
        NNN_FCOLORS = "030304020705050801060301";
        XCURSOR_SIZE = "24";
      };
    };
  };
}
