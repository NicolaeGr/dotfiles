{ pkgs, options, config, lib, ... }: {
  imports = [
    ./ghost.nix
    ./nicolae.nix
    ./pruple.nix
  ];

  users.guest.enable = true;

  users.defaultUserShell = pkgs.zsh;
}
