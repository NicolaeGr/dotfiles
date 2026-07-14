{
  lib,
  config,
  base16-lib,
  ...
}:
with lib;
let
  cfg = config.local.theming;
  targetCfg = config.local.theming.targets.kitty;
in
{
  options.local.theming.targets.kitty = {
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
      nameValuePair "hjem/themes/${themeName}/kitty.conf" {
        source = colors {
          template = ./kitty.conf.mustache;
          extension = ".conf";
        };
      }
    ) cfg.themes;
  };
}
