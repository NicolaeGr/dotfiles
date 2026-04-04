{
  pkgs ? import <nixpkgs> { },
}:
{
  cd-gitroot = pkgs.callPackage ./cd-gitroot { };
  zhooks = pkgs.callPackage ./zhooks { };
  zsh-term-title = pkgs.callPackage ./zsh-term-title { };

  gabarito-fonts = pkgs.callPackage ./gabarito-fonts.nix { };
  kfrgb = pkgs.callPackage ./kfrgb.nix { };
}
