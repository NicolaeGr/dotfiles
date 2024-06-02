{ inputs, pkgs, options, config, lib, ... }: {

  options = {
    devMode.enable = lib.mkEnableOption {
      default = false;
      description = "Enable development mode";
    };
  };

  config = lib.mkIf config.devMode.enable {
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

      direnv
    ];
  };
}
