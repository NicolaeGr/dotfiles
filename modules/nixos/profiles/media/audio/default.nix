{ options, config, lib, pkgs, ... }: {
  options = {
    profiles.media.audio.enable = lib.mkEnableOption {
      default = false;
      description = "Enable audio production tools";
    };
  };

  config = lib.mkIf config.profiles.media.audio.enable {
    environment.systemPackages = with pkgs; [
      spotify
      spicetify-cli
    ];
  };
}
