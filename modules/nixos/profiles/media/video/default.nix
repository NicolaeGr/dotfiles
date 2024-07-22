{ options, config, lib, pkgs, ... }: {
  options = {
    profiles.media.video.enable = lib.mkEnableOption {
      default = false;
      description = "Enable video production tools";
    };
  };

  config = lib.mkIf config.profiles.media.video.enable {
    environment.systemPackages = with pkgs; [
      vls
      mpv
      ffmpeg

      obs-studio
    ];
  };
}
