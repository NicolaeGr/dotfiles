{inputs, pkgs, config, ...}:
{
  environment.systemPackages = with pkgs; [
    # Editors
    vim
    neovim
    vscodium

    # Tools
    glow
    fd
    ripgrep
    bat
    fzf
    eza
    tldr
    tokei
    ngrok
    
    # Languages
    gcc
    rustup
    nodejs
    python3
    go

    # DevOps
    docker

    # Databases
    sqlite

    # Networking
    nmap
    
    # Security
    hashcat
    john
    burpsuite
    ncrack

    # Web
    chromium
    insomnia
  ];
}