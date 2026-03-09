{
  config,
  lib,
  pkgs,
  ...
}:
let
  scriptPath = ".config/hypr/hypridle/global-brightness.sh";
in
{

  options = {
    extra.hyprland.hypridle.enable = lib.mkEnableOption {
      default = false;
      description = "Enable Hyprland's idle daemon";
    };
  };

  config = lib.mkIf config.extra.hyprland.hypridle.enable {
    home.file = {
      "hypridle.conf" = {
        target = ".config/hypr/hypridle.conf";
        source = ./hypridle.conf;
      };

      "global-brightness.sh" = {
        target = scriptPath;
        source = ./global-brightness.sh;
        executable = true;
      };
    };

    systemd.user.services.hypridle = {
      Unit = {
        Description = "Hyprland's idle daemon";
        Documentation = "https://wiki.hyprland.org/Hypr-Ecosystem/hypridle";
        PartOf = "wayland-session@Hyprland.target";
        After = [ "wayland-session@Hyprland.target" ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.unstable.hypridle}/bin/hypridle";
        Restart = "on-failure";
      };

      Install = {
        WantedBy = [ "wayland-session@Hyprland.target" ];
      };
    };

    wayland.windowManager.hyprland.settings.exec-once = lib.mkAfter [
      "${scriptPath} reset"
    ];
  };
}
