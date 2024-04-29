{ config, ... }: {
  nixpkgs.config = {
    allowUnfree = true;
  };

  imports = [
    ./xdg.nix
    ./zsh
    ./theme
    ./git.nix
  ];

  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.dataHome}/gnupg";
  };
}

