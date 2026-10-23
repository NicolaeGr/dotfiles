{
  lib,
  pkgs,
  config,
  configLib,
  ...
}:
{
  config = lib.mkIf config.local.gui.hypr.enable {
    packages = with pkgs; [
      awww
    ];

    files.".config/hypr/backgrounds" = {
      source = configLib.outOfStorePath ./bgs;
    };

    local.theming = {
      enable = true;
      default = "catppuccin-mocha";

      targets.hyprland.enable = true;

      iconTheme = {
        name = "kora";
        package = pkgs.kora-icon-theme;
      };

      cursorTheme = {
        name = "rose-pine-hyprcursor";
        package = pkgs.rose-pine-hyprcursor;
        size = 24;
      };

      fonts = {
        sansSerif = "Noto Sans";
        monospace = "JetBrainsMono Nerd Font";
        emoji = "Noto Color Emoji";
        sansSize = 10;
        monospaceSize = 11;
      };
    };
  };
}
