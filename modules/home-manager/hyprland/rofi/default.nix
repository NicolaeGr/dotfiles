{ options, config, lib, ... }: {

  options = {
    hyprland.rofi.enable = lib.mkEnableOption {
      default = false;
      description = "Enable rofi";
    };
  };

  config = lib.mkIf config.hyprland.rofi.enable {
    programs.rofi = {
      enable = true;
      # theme = builtins.readFile ./custom.rasi;
    };
  };
}
