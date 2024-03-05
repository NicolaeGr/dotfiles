{ pkgs, ... }:
let
  gabarito = pkgs.callPackage ./gabarito.nix { };
in
{
  fonts.fontDir.enable = true;

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji

    fira-code
    fira-code-symbols

    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })

    material-symbols

    gabarito
  ];
}
