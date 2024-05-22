{ options, config, lib, ... }: {
  config = lib.mkIf config.hyprland.enable {
    programs.rofi = {
      enable = true;
      # theme = builtins.readFile ./custom.rasi;
    };
  };
}
