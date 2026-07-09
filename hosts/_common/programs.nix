{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    nixfmt
    nil
    nixpkgs-fmt
    fastfetch
    pciutils
    btop
    htop
    jq
    tree
    wget
    curl
    unzip
    zip
    rsync
  ];
}
