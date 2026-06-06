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
    prettier

    # Languages
    gcc
    rustup
    nodejs
    python3
    go

    # Package Managers
    pnpm
    yarn

    # Networking
    nmap
    avahi
  ];
}
