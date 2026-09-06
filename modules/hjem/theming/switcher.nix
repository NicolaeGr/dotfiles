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

  targetFragments = lib.concatStringsSep "\n\n" (
    lib.mapAttrsToList (name: target: ''
      # ${name}
      ${target.switcherScript or ""}
    '') (lib.filterAttrs (_: target: target.enable) cfg.targets)
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

    ${targetFragments}

    echo "Successfully switched to $THEME ($VARIANT)"
  '';
in
{
  config = lib.mkIf cfg.enable {
    packages = [ switcherScript ];
  };
}
