{ options, config, lib, ... }: {

  config = lib.mkIf (config.hyprlock.enable) {
    home.file = {
      "hyprlock-hyprlock.conf" = {
        target = ".config/hypr/hyprlock.conf";
        source = ./hyprlock.conf;
      };

      "hyprlock-status.sh" = {
        target = ".config/hypr/hyprlock/status.sh";
        source = ./status.sh;
      };
    };
  };
}
