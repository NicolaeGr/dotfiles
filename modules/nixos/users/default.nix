{ pkgs, options, config, lib, ... }: {
  imports = [
    ./ghost.nix
    ./nicolae.nix
    ./pruple.nix
  ];

  users.guest.enable = true;

  #users.defaultUserShell = lib.mkMerge [
  #  (lib.mkIf config.zsh.enable pkgs.zsh)
  #  (lib.mkIf (!config.zsh.enable) pkgs.bash)
  #];

  users.defaultUserShell = pkgs.zsh;
}
