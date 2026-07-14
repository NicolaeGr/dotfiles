{
  lib,
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
  };
}
