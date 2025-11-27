{ pkgs, ... }:
{
  home.file."screenshot_utils.sh" = {
    target = ".config/hypr/scripts/screenshot_utils.sh";
    source = ./screenshot_utils.sh;
    executable = true;
  };

  home.file."screenshot.png" = {
    target = ".config/hypr/icons/screenshot.png";
    source = ./screenshot.png;
  };

  home.packages = with pkgs; [
    hyprshot
    satty
    libnotify
  ];
}
