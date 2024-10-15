{ options, config, lib, pkgs, ... }: {

  options = {
    flatpak.enable = lib.mkEnableOption {
      default = false;
      description = "Enable the Flatpak package manager";
    };
  };

  config = lib.mkIf config.flatpak.enable {
    services.flatpak = {
      enable = true;
      uninstallUnmanaged = true;
      update.auto = {
        enable = true;
        onCalendar = "weekly";
      };

      remotes = [
        {
          name = "flathub";
          location = "https://flathub.org/repo/flathub.flatpakrepo";
        }
        {
          name = "flathub-beta";
          location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
        }
        {
          name = "gnome-nightly";
          location = "https://nightly.gnome.org/gnome-nightly.flatpakrepo";
        }
      ];

      packages = [
        "com.gitlab.tipp10.tipp10"
        "com.jetbrains.Rider"
        "io.github.zen_browser.zen"
      ];

      overrides = {
        global = {
          Context = {
            filesystems = [
              "xdg-data/themes:ro"
              "xdg-data/icons:ro"
              "xdg-data/fonts:ro"
              "xdg-config/gtkrc:ro"
              "xdg-config/gtkrc-2.0:ro"
              "xdg-config/gtk-2.0:ro"
              "xdg-config/gtk-3.0:ro"
              "xdg-config/gtk-4.0:ro"
              "nix"
            ];
            sockets = [ "wayland" "!x11" "!fallback-x11" ];
          };

          Environment = {
            "GTK_THEME" = "adw-gtk3-dark";
            "QT_STYLE_OVERRIDE" = "adwaita";
          };
        };
      };
    };
  };
}
