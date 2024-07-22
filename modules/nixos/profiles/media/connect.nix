{ options, config, lib, pkgs, ... }: {
  options = {
    profiles.media.connect.enable = lib.mkEnableOption {
      default = false;
      description = "Enable media connect profile";
    };
  };

  # this file contains tools and utility for managing media over the network

  config = lib.mkIf config.profiles.media.connect.enable {
    programs.kdeconnect.enable = true;

    environment.systemPackages = with pkgs;[
      jellyfin
    ];
  };
}
