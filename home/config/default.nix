{ ... }: {
  nixpkgs.config = {
    allowUnfree = true;
  };

  imports = [
    ./xdg.nix
    ./zsh
    ./theme

    # ./flatpak
  ];
}

