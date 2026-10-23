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
  name = "hyprlock";
  inherit config;

  condition = config.local.gui.hypr.enable;

  templates = {
    "hyprlock.conf" = ./hyprlock.conf.tpl;
  };

  switcherScript = ''
    dest="$HOME/.config/hypr/hyprlock.conf"
    mkdir -p "$(dirname "$dest")"

    tmp="$dest.tmp.$$"
    {
      printf '$font_family = %s\n' ${lib.escapeShellArg config.local.theming.fonts.sansSerif}
      printf '$font_family_clock = %s\n' ${lib.escapeShellArg config.local.theming.fonts.sansSerif}
      printf '$font_material_symbols = %s\n' "Material Symbols Rounded"
      cat "$HT_THEME_DIR/hyprlock.conf"
    } >"$tmp"
    mv -f "$tmp" "$dest"
  '';
}
