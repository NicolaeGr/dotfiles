{ pkgs, ... }: {
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji

    fira-code
    fira-code-symbols

    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];
}
