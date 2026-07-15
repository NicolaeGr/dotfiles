{
  lib,
  pkgs,
  config,
  base16-lib,
  ...
}:
with lib;
let
  cfg = config.local.theming;
  targetCfg = config.local.theming.targets.gtk;
in
{
  options.local.theming.targets.gtk = {
    enable = mkOption {
      type = types.bool;
      default = cfg.enable;
    };
  };

  config = mkIf targetCfg.enable {
    xdg.config.files = mapAttrs' (
      themeName: theme:
      let
        colors = (base16-lib.mkSchemeAttrs theme.colors).override { };
      in
      nameValuePair "hjem/themes/${themeName}/gtk.css" {
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
