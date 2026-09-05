{
  lib,
  config,
  base16-lib,
  ...
}:
with lib;
let
  cfg = config.local.theming;
  targetCfg = config.local.theming.targets.bat;
in
{
  options.local.theming.targets.bat = {
    enable = mkOption {
      type = types.bool;
      default = cfg.enable;
    };
  };

  config = mkIf (targetCfg.enable && config.rum-ext.programs.bat.enable) {
    xdg.config.files = mapAttrs' (
      themeName: theme:
      let
        colors = (base16-lib.mkSchemeAttrs theme.colors).override { };
      in
      nameValuePair "hjem/themes/${themeName}/bat.tmTheme" {
        source = colors {
          template = ./base16-stylix.tmTheme.mustache;
          extension = ".tmTheme";
        };
      }
    ) cfg.themes;

    rum-ext.programs.bat.settings.theme = "hjem";
  };
}
