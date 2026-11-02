{
  lib,
  pkgs,
  config,
  configLib,
  ...
}:
{
  config = lib.mkIf config.local.gui.hypr.enable {
    systemd.services.hypridle = {
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      script = "${pkgs.hypridle}/bin/hypridle";
      serviceConfig.Restart = "on-failure";
      enableDefaultPath = false;
    };

    files = {
      ".config/hypr/hypridle.conf" = {
        source = configLib.outOfStorePath ./hypridle.conf;
      };
    };
  };
}
