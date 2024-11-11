{ pkgs, outputs, lib, ... }: {

  imports = [
    ./zsh
    ./git
    ./themes

    ./xdg.nix
  ];

  themes.enable = lib.mkDefault true;
  git.enable = lib.mkDefault true;

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };
}
