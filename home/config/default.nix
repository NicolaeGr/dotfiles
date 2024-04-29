{ config, ... }: {
  nixpkgs.config = {
    allowUnfree = true;
  };

  imports = [
    ./xdg.nix
    ./zsh
    ./theme
    ./git.nix

    ./neovim
  ];

  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.dataHome}/gnupg";
  };
}

