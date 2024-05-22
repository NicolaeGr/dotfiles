{ inputs, outputs, lib, ... }: {
  imports = [
    inputs.home-manager.nixosModules.home-manager

    ./nix.nix
    ./locale.nix
    ./backlight.nix
    ./xdg.nix
    ./fonts.nix
    ./zsh.nix

    ./dev
    ./flatpak
    ./hardware
  ];

  # Activate modules that need to be on by default.
  backlight.enable = lib.mkDefault true;
  xdg.enable = lib.mkDefault true;
  fonts.enable = lib.mkDefault true;

  # Global config #
  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkDefault "us";
    useXkbConfig = true;
  };

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  system.stateVersion = "23.11";
}
