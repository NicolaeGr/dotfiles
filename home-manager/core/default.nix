{ pkgs, outputs, libs, ... }: {

  imports = [
    ./zsh
    # ./themes

    ./xdg.nix
  ];

  # themes.enable = libs.mkDefault true;

  home.packages = with pkgs; [
    gnome3.gnome-tweaks

    adwaita-qt6

    adw-gtk3
    phinger-cursors

    gradience
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
    platformTheme = "gtk";
    style.name = "adw-gtk3-dark";
  };


  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  # setup keyboard layout to be us with alt being romanian
  # home.keyboard.layout = "us";
  # home.keyboard.variant = "alt-intl";
}
