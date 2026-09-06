{
  lib,
  pkgs,
  config,
  base16-lib,
  ...
}:
let
  mkTarget = import ../../mkTarget.nix { inherit lib; };
  cfg = config.local.theming;
in
mkTarget {
  name = "gtk";
  inherit config;

  switcherScript = ''
    if [ "$VARIANT" = "dark" ]; then
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
      TARGET_THEME="adw-gtk3-dark"
    else
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'default'"
      TARGET_THEME="adw-gtk3"
    fi

    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-theme "'HighContrast'"
    sleep 0.05
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-theme "'$TARGET_THEME'"
  '';

  targetConfig = {
    xdg.config.files = lib.mapAttrs' (
      themeName: theme:
      let
        colors = (base16-lib.mkSchemeAttrs theme.colors).override { };
      in
      lib.nameValuePair "hjem/themes/${themeName}/gtk.css" {
        source = colors {
          template = ./gtk.css.mustache;
          extension = ".css";
        };
      }
    ) cfg.themes;

    packages = [
      pkgs.adw-gtk3
    ];

    files = {
      ".config/gtk-3.0/settings.ini".text = ''
        [Settings]
        gtk-theme-name = adw-gtk3
        gtk-icon-theme-name = ${cfg.iconTheme.name}
        gtk-cursor-theme-name = ${cfg.cursorTheme.name}
        gtk-cursor-theme-size = ${toString cfg.cursorTheme.size}
        gtk-font-name = Sans 10
      '';

      ".config/gtk-4.0/settings.ini".text = ''
        [Settings]
        gtk-theme-name = adw-gtk3
        gtk-icon-theme-name = ${cfg.iconTheme.name}
        gtk-cursor-theme-name = ${cfg.cursorTheme.name}
        gtk-cursor-theme-size = ${toString cfg.cursorTheme.size}
        gtk-font-name = Sans 10
      '';

      ".config/gtk-3.0/gtk.css".text = ''
        @import url("file://${config.directory}/.config/hjem/themes/active/gtk.css");
      '';

      ".config/gtk-4.0/gtk.css".text = ''
        @import url("file://${config.directory}/.config/hjem/themes/active/gtk.css");
      '';
    };
  };
}
