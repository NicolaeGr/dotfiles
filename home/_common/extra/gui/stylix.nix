{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ inputs.stylix.homeModules.stylix ];

  config = lib.mkIf config.extra.gui.enable {
    stylix = {
      enable = true;
      autoEnable = true;
      polarity = "dark";

      icons = {
        enable = true;
        dark = "kora";
        light = "kora";
        package = pkgs.kora-icon-theme;
      };

      cursor = {
        name = "hyprcursor-rose-pine";
        package = inputs.rose-pine-hyprcursor.packages.${pkgs.stdenv.hostPlatform.system}.default;
        size = 24;
      };

      base16Scheme = ./theme.yaml;

      targets.qt.enable = true;
      targets.vscode.enable = lib.mkDefault false;
      targets.firefox.enable = true;
      targets.firefox.colorTheme.enable = true;
      targets.firefox.profileNames = [ "firefox.default" ];
      targets.neovim.enable = false;
    };
  };
}
