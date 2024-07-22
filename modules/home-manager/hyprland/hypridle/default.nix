{ options, config, lib, pkgs, ... }: {

  options = {
    hyprland.hypridle.enable = lib.mkEnableOption {
      default = false;
      description = "Enable Hyprland's idle daemon";
    };
  };

  config = lib.mkIf config.hyprland.hypridle.enable {
    home.file = {
      "hypridle.conf" = {
        target = ".config/hypr/hypridle.conf";
        source = ./hypridle.conf;
      };
    };

    systemd.user.services.hypridle = {
      Unit = {
        Description = "Hyprland's idle daemon";
        Documentation = "https://wiki.hyprland.org/Hypr-Ecosystem/hypridle";
        PartOf = "hyprland-session.target";
        After = [ "hyprland-session.target" ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.unstable.hypridle}/bin/hypridle";
        Restart = "on-failure";
      };

      Install = {
        WantedBy = [ "hyprland-session.target" ];
      };
    };

  };
}
