{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.local.dev.enable = lib.mkEnableOption "Enable dev tools";

  config = lib.mkIf config.local.dev.enable {
    hjem.extraModules = [ { local.dev.enable = true; } ];

    environment.systemPackages = with pkgs; [
      android-tools
    ];
  };
}
