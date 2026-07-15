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
      firefox
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

      gnome-calendar
      gnome-contacts
      gnome-calculator

      loupe
      cheese
      baobab
      nautilus

      vlc
      mpv
      libreoffice

      discord
      fluffychat
      signal-desktop
      telegram-desktop

      obsidian
      obs-studio
      jellyfin-media-player

      kitty
    ];
  };
}
