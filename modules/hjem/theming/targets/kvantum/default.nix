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
        colors = (base16-lib.mkSchemeAttrs theme.colors).override {
          variant = theme.variant;
          is_dark = if theme.variant == "dark" then "true" else "false";
        };
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

    # files.".config/Kvantum/kvantum.kvconfig".text = ''
    #   [General]
    #   theme=HjemTheme
    # '';

    files.".config/qt5ct/qt5ct.conf".text = ''
      [Appearance]
      style=kvantum
      custom_palette=false
    '';

    files.".config/qt6ct/qt6ct.conf".text = ''
      [Appearance]
      style=kvantum
      custom_palette=false
    '';

    environment.sessionVariables = {
      QT_QPA_PLATFORMTHEME = "qt5ct";
      # QT_STYLE_OVERRIDE = "kvantum";
    };

    files.".config/hypr/hyprland.lua".text = lib.mkAfter ''
      hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
    '';

    packages = [
      pkgs.qt6Packages.qt6ct
      pkgs.libsForQt5.qt5ct
      pkgs.libsForQt5.qtstyleplugin-kvantum
      pkgs.qt6Packages.qtstyleplugin-kvantum
    ];
  };
}
