{
  lib,
  config,
  configLib,
  ...
}:
{
  config = lib.mkIf config.local.gui.hypr.enable {
    rum.programs.hyprlock.enable = true;

    files = {
      ".config/hypr/hyprlock.conf" = {
        source = configLib.outOfStorePath ./hyprlock.conf;
      };
      ".config/hypr/scripts/hyprlock_status.sh" = {
        source = configLib.outOfStorePath ./status.sh;
      };
    };
  };
}
