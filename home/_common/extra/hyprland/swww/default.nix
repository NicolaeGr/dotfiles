{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
{
  options = {
    extra.hyprland.swww.enable = lib.mkEnableOption {
      default = false;
      description = "Enable swww";
    };
  };

  config = lib.mkIf config.extra.hyprland.swww.enable {
    home.file."bg.jpg" = {
      target = ".config/hypr/backgrounds/bg.jpg";
      source = ./bg.jpg;
    };

    home.file."bg2.jpg" = {
      target = ".config/hypr/backgrounds/bg2.jpg";
      source = ./bg2.jpg;
    };

    home.file."rain.gif" = {
      target = ".config/hypr/backgrounds/rain.gif";
      source = ./rain.gif;
    };

    home.file."galaxy.jpg" = {
      target = ".config/hypr/backgrounds/galaxy.jpg";
      source = ./galaxy.jpg;
    };

    home.packages = with pkgs; [
      swww
    ];

    wayland.windowManager.hyprland.settings.exec-once = [
      "swww-daemon &"
      "swww img ${config.home.homeDirectory}/.config/hypr/backgrounds/galaxy.jpg"
    ];
  };
}
