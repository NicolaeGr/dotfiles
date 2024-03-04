{ config, pkgs, username, ... }: {
  imports = [ ./../config/hyprland ];

  home.username = "nicolae";
  home.homeDirectory = "/home/nicolae";

  home.packages = with pkgs; [
    firefox
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    NIXOS_OZONE_WL = "1";
    WLD_NO_HARDWARE_CURSORS = "1";
  };

  home.file = { };
}
