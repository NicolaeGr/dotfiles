{ config, pkgs, username, ... }: {
  imports = [ ./../config ./../config/hyprland ];

  home.username = "pruple";
  home.homeDirectory = "/home/pruple";

  home.packages = with pkgs; [
    steam
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    NIXOS_OZONE_WL = "1";
    WLD_NO_HARDWARE_CURSORS = "1";
  };

  home.file = { };
}
