{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.extra.media.video = {
    enable = lib.mkEnableOption "Enable media video tools";
  };

  config = lib.mkIf config.extra.media.video.enable {
    environment.systemPackages = with pkgs; [
      vlc
      mpv
      ffmpeg

      obs-studio
    ];
  };
}
