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

    # Lookup variant based on Nix configuration
    case "$THEME" in
      ${themeVariants}
      *)
        echo "Error: Theme '$THEME' not found."
        exit 1
        ;;
    esac

    ACTIVE_DIR="$HOME/.config/hjem/themes/active"

    # 1. Update the primary active symlink
    ln -sfn "$HOME/.config/hjem/themes/$THEME" "$ACTIVE_DIR"

    # 2. Update Kvantum symlink
    # (Kvantum requires the folder name to match the theme name exactly)
    mkdir -p "$HOME/.config/Kvantum"
    ln -sfn "$ACTIVE_DIR" "$HOME/.config/Kvantum/HjemTheme"

    # 3. Broadcast Variant via GSettings
    # GTK and modern Qt (via Kvantum) respect this on the fly
    if [ "$VARIANT" = "dark" ]; then
      ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    else
      ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme 'default'
    fi

    # 4. IPC Reload Signals

    # Trigger Kvantum redraw, and make sure that our files are symlinked correctly to ~/.config/Kvantum/
    ln -sfn "$ACTIVE_DIR/HjemTheme.kvconfig" "$HOME/.config/Kvantum/HjemTheme.kvconfig"
    ln -sfn "$ACTIVE_DIR/HjemTheme.svg" "$HOME/.config/Kvantum/HjemTheme.svg"

    # Trigger Kitty redraw (Requires IPC enabled in kitty.conf)
    if [ -S /tmp/kitty ]; then
      kitty @ --to unix:/tmp/kitty set-colors -a -c "$ACTIVE_DIR/kitty.conf" || true
    fi

    echo "Successfully switched to $THEME ($VARIANT)"
  '';
in
{
  config = lib.mkIf cfg.enable {
    environment.sessionVariables = {
      GTK_THEME = "HjemTheme";

      QT_QPA_PLATFORMTHEME = "qt5ct";
      QT_STYLE_OVERRIDE = "kvantum";
    };

    packages = [
      switcherScript
    ];
  };
}
