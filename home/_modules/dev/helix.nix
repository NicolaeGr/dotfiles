{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.local.dev.enable {
    rum.programs.helix = {
      enable = true;
    };

    environment.sessionVariables.EDITOR = lib.mkDefault "hx";
  };
}
