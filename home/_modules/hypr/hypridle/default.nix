{
  lib,
  config,
  configLib,
  ...
}:
{
  config = lib.mkIf config.local.gui.hypr.enable {
    files = {
      ".config/hypr/hypridle.conf" = {
        source = configLib.outOfStorePath ./hypridle.conf;
      };
      ".config/hypr/scripts/global-brightness.sh" = {
        source = configLib.outOfStorePath ./global-brightness.sh;
      };
    };
  };
}
