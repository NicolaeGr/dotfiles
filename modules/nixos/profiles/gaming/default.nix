{ options, config, lib, pkgs, ... }: {
  imports = [
    ./steam
  ];

  options = {
    profiles.gaming.enable = lib.mkEnableOption "Enable gaming profile";
  };

  config = lib.mkIf config.profiles.gaming.enable {
    profiles.gaming.apps.steam.enable = true;

    environment.systemPackages = with pkgs; [
      heroic
    ];
  };
}
