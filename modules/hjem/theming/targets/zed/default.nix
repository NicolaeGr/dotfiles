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
  name = "zed";
  inherit config;

  condition = config.local.dev.enable && config.local.gui.enable;

  templates = {
    "zed.json" = ./zed.json.tpl;
    "zed-theme-name" = ./zed-theme-name.tpl;
  };

  switcherScript = ''
    dir="$HOME/.config/zed/themes"
    mkdir -p "$dir"
    ln -sfn "$HT_THEME_DIR/zed.json" "$dir/ht.json"

    theme_name=$(<"$HT_THEME_DIR/zed-theme-name")
    ${pkgs.python3}/bin/python3 ${./set-theme.py} "$HOME/.config/zed/settings.json" "$theme_name"
    ${pkgs.coreutils}/bin/touch "$HOME/.config/zed/settings.json"
  '';
}
