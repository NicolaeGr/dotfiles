{ lib, pkgs, ... }: {
  imports = [
    ./audio.nix
    ./bluetooth.nix
    ./network.nix
    ./nvidia.nix
  ];

  audio.enable = lib.mkDefault true;
  bluetooth.enable = lib.mkDefault true;
  network.enable = lib.mkDefault true;

  environment.systemPackages = with pkgs; [
    wsdd # for network discovery
  ];
}
