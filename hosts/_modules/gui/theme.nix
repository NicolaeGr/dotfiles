{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ inputs.stylix.nixosModules.stylix ];

  config = lib.mkIf config.local.gui.enable {
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
        package = pkgs.rose-pine-hyprcursor;
        size = 24;
      };

      base16Scheme = ./theme.yaml;

      targets.qt.enable = true;
    };
  };
}
