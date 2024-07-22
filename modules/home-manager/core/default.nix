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

  # setup keyboard layout to be us with alt being romanian
  # home.keyboard.layout = "us";
  # home.keyboard.variant = "alt-intl";
}
