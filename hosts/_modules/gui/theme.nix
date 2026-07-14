{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.local.gui.enable {
    environment.systemPackages = with pkgs; [
      kora-icon-theme
    ];
  };
}
