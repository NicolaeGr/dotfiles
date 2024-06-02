{ lib, ... }: {
  imports = [
    ./core
    ./hyprland

    ./nvim
    ./firefox
  ];

  hyprland.enable = lib.mkDefault true;
}
