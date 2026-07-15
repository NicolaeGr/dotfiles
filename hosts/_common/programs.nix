{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    vim
    neovim

    nixfmt
    nil
    nixpkgs-fmt

    fastfetch
    pciutils
    btop
    htop
    dua

    jq
    tree

    wget
    curl

    unzip
    zip
    rsync

    ffmpeg
  ];
}
