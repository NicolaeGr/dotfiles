{ options, config, scripts, pkgs, ... }: {

  config = {
    home.file."bg.jpg" = {
      target = ".config/hypr/backgrounds/bg.jpg";
      source = ./bg.jpg;
    };

    wayland.windowManager.hyprland.settings.exec-once = [ "swww init" "swww img ${config.homePath}/.config/hypr/backgrounds/bg.jpg" ];
  };
}
