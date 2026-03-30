{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    extra.hyprland.hyprlock.enable = lib.mkEnableOption {
      default = false;
      description = "Enable hyprlock";
    };
  };

  config = lib.mkIf config.extra.hyprland.hyprlock.enable {
    home.packages = [ pkgs.hyprlock ];

    home.file = {
      "hyprlock-hyprlock.conf" = {
        target = ".config/hypr/hyprlock.conf";
        source = ./hyprlock.conf;
      };

      "hyprlock-status.sh" = {
        target = ".config/hypr/hyprlock/status.sh";
        source = ./status.sh;
        executable = true;
      };
    };
  };
}
