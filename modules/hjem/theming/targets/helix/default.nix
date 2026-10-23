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
  name = "helix";
  inherit config;

  condition = config.rum.programs.helix.enable;

  templates = {
    "helix.toml" = ./helix.toml.tpl;
  };

  switcherScript = ''
    mkdir -p "$HOME/.config/helix/themes"
    ln -sfn "$HT_THEME_DIR/helix.toml" "$HOME/.config/helix/themes/ht.toml"
  '';

  targetConfig = {
    rum.programs.helix.settings.theme = "ht";
  };
}
