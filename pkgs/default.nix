{ pkgs ? import <nixpkgs> { } }: rec {
  gabarito-fonts = pkgs.callPackage ./gabarito-fonts.nix { };
}
