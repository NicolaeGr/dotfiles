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
  name = "kvantum";
  inherit config;
  switcherScript = ''
    mkdir -p "$HOME/.config/Kvantum/HjemTheme"
    ln -sfn "$ACTIVE_DIR/HjemTheme.kvconfig" "$HOME/.config/Kvantum/HjemTheme/HjemTheme.kvconfig"
    ln -sfn "$ACTIVE_DIR/HjemTheme.svg" "$HOME/.config/Kvantum/HjemTheme/HjemTheme.svg"

    cat <<EOF > "$HOME/.config/Kvantum/kvantum.kvconfig"
    [General]
    theme=HjemTheme
    dark_theme=$(if [ "$VARIANT" = "dark" ]; then echo "true"; else echo "false"; fi)
    EOF

    touch "$HOME/.config/Kvantum/kvantum.kvconfig"
  '';
  targetConfig = {
    xdg.config.files = lib.foldl' (
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
    ) { } (lib.attrNames cfg.themes);

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
