{ lib, config, ... }:
let
  mkTarget = import ../../mkTarget.nix { inherit lib; };
  cfg = config.local.theming;
in
mkTarget {
  name = "hyprland";
  inherit config;
  switcherScript = "";
  targetConfig = {
    files.".config/hypr/hyprland.lua".text = lib.mkAfter ''
      hl.env("HYPRCURSOR_THEME", "${cfg.cursorTheme.name}")
      hl.env("HYPRCURSOR_SIZE", "${toString cfg.cursorTheme.size}")
    '';
  };
}
