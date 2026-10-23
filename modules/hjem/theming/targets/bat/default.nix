{
  lib,
  pkgs,
  config,
  ...
}:
let
  mkTarget = import ../../mkTarget.nix { inherit lib; };
in
mkTarget {
  name = "bat";
  inherit config;

  condition = config.rum-ext.programs.bat.enable;

  templates = {
    "bat.tmTheme" = ./bat.tmTheme.tpl;
  };

  switcherScript = ''
    mkdir -p "$HOME/.config/bat/themes"
    ln -sfn "$HT_THEME_DIR/bat.tmTheme" "$HOME/.config/bat/themes/ht.tmTheme"
    ${pkgs.bat}/bin/bat cache --build >/dev/null 2>&1 || true
  '';

  targetConfig = {
    rum-ext.programs.bat.settings.theme = "ht";
  };
}
