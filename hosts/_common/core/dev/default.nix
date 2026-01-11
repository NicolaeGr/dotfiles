{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Editors
    vim

    # Tools
    uget
    glow
    fd
    ripgrep
    bat
    fzf
    eza
    tldr
    tokei
    ngrok
    gnumake
    nodePackages.prettier # can be moved to some extra config

    # Languages
    gcc
    rustup
    nodejs
    python3
    go

    # Package Managers
    nodePackages.pnpm
    nodePackages.yarn

    # Networking
    nmap
    avahi
  ];
}
