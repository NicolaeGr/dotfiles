{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    flatpak
  ];

  services.flatpak = {
    enable = true;

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
      "org.gnome.Calculator"
      "org.gnome.Cheese"
      "org.gnome.Loupe"
      {
        appId = "org.gnome.NautilusDevel";
        origin = "gnome-nightly";
      }

      "org.gnome.baobab"

      "com.github.tchx84.Flatseal"

      "io.missioncenter.MissionCenter"

      "org.gtk.Gtk3theme.adw-gtk3"
      "org.gtk.Gtk3theme.adw-gtk3-dark"
    ];

    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };

    overrides.global = {
      Context.filesystems = [
        "xdg-data/themes"
        "xdg-data/icons"
        "xdg-data/fonts"
      ];

      Environment = {
        "GTK_THEME" = "adw-gtk3";
        "QT_STYLE_OVERRIDE" = "adwaita";
      };
    };
  };
}
