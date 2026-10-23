{
  lib,
  pkgs,
  config,
  ...
}:
let
  mkTarget = import ../../mkTarget.nix { inherit lib; };
  cfg = config.local.theming;
in
mkTarget {
  name = "kitty";
  inherit config;

  templates = {
    "kitty.conf" = ./kitty.conf.tpl;
  };

  switcherScript = ''
    ${pkgs.procps}/bin/pkill -USR1 -x kitty >/dev/null 2>&1 || true
  '';

  targetConfig = {
    files.".config/kitty/kitty.conf".text = lib.mkAfter ''
      include ${config.directory}/.local/state/ht/active/kitty.conf

      font_family ${cfg.fonts.monospace}
      font_size ${toString cfg.fonts.monospaceSize}
    '';
  };
}
