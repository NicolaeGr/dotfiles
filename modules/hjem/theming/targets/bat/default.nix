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
  name = "bat";
  inherit config;
  condition = config.rum-ext.programs.bat.enable;

  switcherScript = ''
    mkdir -p "$HOME/.config/bat/themes"
    ln -sfn "$ACTIVE_DIR/bat.tmTheme" "$HOME/.config/bat/themes/hjem.tmTheme"
    ${pkgs.bat}/bin/bat cache --build > /dev/null 2>&1 || true
  '';

  targetConfig = {
    xdg.config.files = lib.mapAttrs' (
      themeName: theme:
      let
        colors = (base16-lib.mkSchemeAttrs theme.colors).override { };
      in
      lib.nameValuePair "hjem/themes/${themeName}/bat.tmTheme" {
        source = colors {
          template = ./base16-stylix.tmTheme.mustache;
          extension = ".tmTheme";
        };
      }
    ) cfg.themes;

    rum-ext.programs.bat.settings.theme = "hjem";
  };
}
