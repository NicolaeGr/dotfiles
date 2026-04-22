{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./stylix.nix
    ./dev.nix
  ];

  options.extra.gui.enable = lib.mkEnableOption {
    default = true;
    description = "Enable GUI features";
  };

  config = lib.mkIf config.extra.gui.enable {
    programs.firefox.enable = true;
    programs.firefox.profiles."firefox.default".extensions.force = true;

    home.packages = with pkgs; [
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

      obsidian
    ];
  };
}
