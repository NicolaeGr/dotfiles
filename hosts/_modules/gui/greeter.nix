{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.local.gui;
in
{
  options.local.gui.sessionWrapper = lib.mkOption {
    type = lib.types.package;
  };

  config = mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          user = "greeter";

          command = lib.concatStringsSep " " [
            "${pkgs.tuigreet}/bin/tuigreet"
            "--time"
            "--asterisks"

            "--remember"
            "--remember-user-session"

            "--sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions:${config.services.displayManager.sessionData.desktops}/share/xsessions"
          ];
        };
      };
    };

    systemd.services.greetd.serviceConfig = {
      Type = "idle";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal";
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
    };
  };
}
