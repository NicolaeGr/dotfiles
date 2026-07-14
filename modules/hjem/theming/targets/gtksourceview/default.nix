{
  lib,
  config,
  base16-lib,
  ...
}:
with lib;
let
  cfg = config.local.theming;
  targetCfg = config.local.theming.targets.gtksourceview;
in
{
  options.local.theming.targets.gtksourceview = {
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
      nameValuePair "hjem/themes/${themeName}/gtksourceview.xml" {
        source = colors {
          template = ./gtksourceview.xml.mustache;
          extension = ".xml";
        };
      }
    ) cfg.themes;
  };
}
