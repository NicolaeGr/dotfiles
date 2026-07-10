{
  lib,
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
        terminal = {
          vt = 1;
          switch = false;
        };
        default_session = {
          user = "greeter";
        };
      };
      useTextGreeter = true;
    };

    systemd.services.greetd.serviceConfig = {
      Restart = lib.mkForce "always";
      RestartSec = "3";
    };
  };
}
