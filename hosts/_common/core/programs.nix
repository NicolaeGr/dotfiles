{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Nix Essentials
    nixfmt-rfc-style
    nil
    nixpkgs-fmt

    # System
    fastfetch
    pciutils
    btop
    htop

    # Utils
    e2fsprogs
    file
    lshw
    jq
    tree
    wget
    curl
    unzip
    zip
    gzip
    bzip2
    xz
    gnutar
    rsync
    glances
    nethogs
    dua
    samba
  ];
}
