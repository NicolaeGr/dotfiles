{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.local.theming;

  themeVariants = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: theme: ''
      "${name}")
        VARIANT="${theme.variant}"
        ;;
    '') cfg.themes
  );

  switcherScript = pkgs.writeShellScriptBin "hjem-theme" ''
    THEME=$1
    if [ -z "$THEME" ]; then
      echo "Usage: hjem-theme <theme-name>"
      echo "Available themes: ${lib.concatStringsSep ", " (lib.attrNames cfg.themes)}"
      exit 1
    fi

    case "$THEME" in
      ${themeVariants}
      *)
        echo "Error: Theme '$THEME' not found."
        exit 1
        ;;
    esac

    ACTIVE_DIR="$HOME/.config/hjem/themes/active"

    ln -sfn "$HOME/.config/hjem/themes/$THEME" "$ACTIVE_DIR"

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

    mkdir -p "$HOME/.config/Kvantum/HjemTheme"
    ln -sfn "$ACTIVE_DIR/HjemTheme.kvconfig" "$HOME/.config/Kvantum/HjemTheme/HjemTheme.kvconfig"
    ln -sfn "$ACTIVE_DIR/HjemTheme.svg" "$HOME/.config/Kvantum/HjemTheme/HjemTheme.svg"

    touch "$HOME/.config/Kvantum/kvantum.kvconfig"

    if [ -S /tmp/kitty ]; then
      ${pkgs.kitty}/bin/kitty @ --to unix:/tmp/kitty set-colors -a -c "$ACTIVE_DIR/kitty.conf" || true
      ${pkgs.kitty}/bin/kitty @ --to unix:/tmp/kitty load-config "$HOME/.config/kitty/kitty.conf" || true
    fi

    echo "Successfully switched to $THEME ($VARIANT)"
  '';
in
{
  config = lib.mkIf cfg.enable {
    environment.sessionVariables = {
      QT_QPA_PLATFORMTHEME = "qt5ct";
      QT_STYLE_OVERRIDE = "kvantum";
    };

    packages = [
      switcherScript
      pkgs.libsForQt5.qtstyleplugin-kvantum
      pkgs.qt6Packages.qtstyleplugin-kvantum
    ];
  };
}
