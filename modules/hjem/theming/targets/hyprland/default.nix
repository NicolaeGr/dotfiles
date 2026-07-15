{ lib, ... }:
let
  cfg = config.local.theming;
in
{
  files.".config/hypr/hyprland.lua".text = lib.mkAfter ''
    hl.env("HYPRCURSOR_THEME", "${cfg.cursorTheme.name}")
    hl.env("HYPRCURSOR_SIZE", "${toString cfg.cursorTheme.size}")
  '';
}
