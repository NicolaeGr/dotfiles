{
  # home.file."custom.rasi" = {
  #   source = ./custom.rasi;
  #   target = ".config/rofi/themes/custom.rasi";
  # };

  programs.rofi = {
    enable = true;
    # theme = builtins.readFile ./custom.rasi;
  };
}
