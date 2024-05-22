{ lib, ... }: {
  imports = [
    ./audio.nix
    ./bluetooth.nix
    ./network.nix
    ./nvidia.nix
  ];

  audio.enable = lib.mkDefault true;
  bluetooth.enable = lib.mkDefault true;
  network.enable = lib.mkDefault true;
}
