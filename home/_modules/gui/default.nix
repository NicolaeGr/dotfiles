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

      gimp

      discord
      fluffychat
      signal-desktop
      stable.telegram-desktop

      obsidian
      obs-studio
      jellyfin-desktop

      kitty
    ];

    environment.sessionVariables = {
      TERMINAL = "kitty";
    };
  };
}
