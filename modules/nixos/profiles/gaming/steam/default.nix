{ options, config, lib, pkgs, ... }: {
  options.profiles.gaming.apps.steam.enable = lib.mkEnableOption "Enable Steam";

  config = lib.mkIf config.profiles.gaming.apps.steam.enable {
    programs.steam = {
      enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];

      localNetworkGameTransfers.openFirewall = true;

      # protontricks.enable = true;
      gamescopeSession.enable = true;
    };

    hardware.xpadneo.enable = true;

    environment.systemPackages = with pkgs; [
      gamemode
      mangohud
    ];
  };
}

