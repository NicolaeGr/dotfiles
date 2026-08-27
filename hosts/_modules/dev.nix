{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.local.dev.enable = lib.mkEnableOption "Enable dev tools";

  config = lib.mkIf config.local.dev.enable {
    hjem.extraModules = [
      {
        local.dev.enable = true;

        rum.programs.zsh.initConfig = lib.mkAfter "eval \"$(${lib.meta.getExe pkgs.devenv} hook zsh)\"";
      }
    ];

    environment.systemPackages = with pkgs; [
      android-tools
      devenv
    ];
  };
}
