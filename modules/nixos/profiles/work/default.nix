{ options, config, lib, pkgs, ... }: {
  options.profiles.work.enable = lib.mkEnableOption "Enable Work Profile";

  config = lib.mkIf config.profiles.work.enable {
    environment.systemPackages = with pkgs;  [
      teams-for-linux
      slack

      unstable.jetbrains.dataspell
      unstable.jetbrains.idea-community
      unstable.geckodriver
    ];
  };
}

