{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.local.gui;
in
{
  config = mkIf cfg.enable {
    security.polkit.enable = true;
    environment.systemPackages = [ pkgs.polkit_gnome ];

    services.gnome.gnome-keyring.enable = true;

    security.pam.services = {
      greetd.enableGnomeKeyring = true;
      login.enableGnomeKeyring = true;
    };

    services.gvfs.enable = true;
    services.tumbler.enable = true;

    services.accounts-daemon.enable = true;

    programs.localsend.enable = true;
    programs.localsend.openFirewall = true;
  };
}
