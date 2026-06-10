{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
{
  options = {
    extra.hyprland.awww.enable = lib.mkEnableOption {
      default = false;
      description = "Enable awww";
    };
  };

  config = lib.mkIf config.extra.hyprland.awww.enable {
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
      awww
    ];

    wayland.windowManager.hyprland.extraConfig = lib.mkAfter ''
      hl.on("hyprland.start", function()
          hl.exec_cmd("awww-daemon &")
          hl.exec_cmd("awww img ${config.home.homeDirectory}/.config/hypr/backgrounds/galaxy.jpg")
      end)
    '';
  };
}
