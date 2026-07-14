{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.local.gui.enable = lib.mkEnableOption "Enable GUI";

  config = lib.mkIf config.local.gui.enable {
    packages = with pkgs; [
      gnome-calculator
      gnome-calendar
      gnome-contacts
      nautilus
      cheese
      baobab
      loupe
      libreoffice

      telegram-desktop
      signal-desktop
      fluffychat

      obsidian
      obs-studio
    ];
  };
}
