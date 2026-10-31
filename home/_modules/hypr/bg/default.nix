{
  lib,
  config,
  pkgs,
  configLib,
  ...
}:
{
  config = lib.mkIf config.local.gui.hypr.enable {
    packages = [ pkgs.awww ];

    files."Media/images/Wallpapers" = {
      source = configLib.outOfStorePath ./images;
    };

    systemd.services.awww-daemon = {
      description = "awww wallpaper daemon";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";
      path = [ pkgs.awww ];
      serviceConfig = {
        ExecStart = "${pkgs.awww}/bin/awww-daemon";
        Restart = "on-failure";
        RestartSec = 1;
      };
    };
  };
}
