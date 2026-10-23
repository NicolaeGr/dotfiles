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
  name = "hyprland";
  inherit config;

  templates = {
    "hyprland.lua" = ./hyprland.lua.tpl;
  };

  switcherScript = ''
    if [ -n "''${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
      ${pkgs.hyprland}/bin/hyprctl setcursor ${lib.escapeShellArg cfg.cursorTheme.name} ${toString cfg.cursorTheme.size} >/dev/null 2>&1 || true
      ${pkgs.hyprland}/bin/hyprctl reload >/dev/null 2>&1 || true
    fi
  '';

  targetConfig = {
    files.".config/hypr/hyprland.lua".text = lib.mkAfter ''
      hl.env("HYPRCURSOR_THEME", "${cfg.cursorTheme.name}")
      hl.env("HYPRCURSOR_SIZE", "${toString cfg.cursorTheme.size}")
      hl.env("XCURSOR_THEME", "${cfg.cursorTheme.name}")
      hl.env("XCURSOR_SIZE", "${toString cfg.cursorTheme.size}")
    '';
  };
}
