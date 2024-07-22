{ options, config, lib, pkgs, ... }: {
  imports = [
    ./audio
    ./video

    ./connect.nix
  ];

  options = {
    profiles.media.enable = lib.mkEnableOption {
      default = false;
      description = "Enable media profiles";
    };
  };

  config = lib.mkIf config.profiles.media.enable {

    profiles.media = {
      audio.enable = true;
      video.enable = true;

      connect.enable = true;
    };
  };
}
