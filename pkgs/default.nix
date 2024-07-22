# You can build these directly using 'nix build .#example'
{ pkgs ? import <nixpkgs> { } }: rec {

  # Packages yet to be added to the nixpkgs repository
  gabarito-fonts = pkgs.callPackage ./gabarito-fonts.nix { };
}
