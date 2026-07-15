{
  lib,
  config,
  base16-lib,
  ...
}:
with lib;
let
  cfg = config.local.theming;
  targetCfg = config.local.theming.targets.kvantum;
in
{
  options.local.theming.targets.kvantum = {
    enable = mkOption {
      type = types.bool;
      default = cfg.enable;
    };
  };

  config = mkIf targetCfg.enable {
    xdg.config.files = foldl' (
      acc: themeName:
      let
        theme = cfg.themes.${themeName};
        colors = (base16-lib.mkSchemeAttrs theme.colors).override { };
      in
      acc
      // {
        "hjem/themes/${themeName}/HjemTheme.kvconfig" = {
          source = colors {
            template = ./kvconfig.mustache;
            extension = ".kvconfig";
          };
        };

        "hjem/themes/${themeName}/HjemTheme.svg" = {
          source = colors {
            template = ./kvantum.svg.mustache;
            extension = ".svg";
          };
        };
      }
    ) { } (attrNames cfg.themes);

    files.".config/Kvantum/kvantum.kvconfig".text = ''
      [General]
      theme=HjemTheme
    '';
  };
}
