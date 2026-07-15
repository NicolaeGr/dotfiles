{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.mkIf config.local.dev.enable {
    rum.programs.helix = {
      enable = true;
    };
  };
}
