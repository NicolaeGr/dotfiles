{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
{
  options.local.gui.enable = lib.mkEnableOption "Enable GUI";

  config = lib.mkIf config.local.gui.enable {
    packages = with pkgs; [
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
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

      firefox
      obsidian
      obs-studio
    ];
  };
}
