{
  home.file = {
    "config.rasi" = {
      source = config.rasi;
      target = ".config/rofi/config.rasi";
    };
  };

  programs.rofi = {
    enable = true;
    theme = ".config/rofi/config.rasi";
  };
}