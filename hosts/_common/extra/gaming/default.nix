{
  pkgs,
  options,
  config,
  lib,
  ...
}:
{
  imports = [ ./jc.nix ];

  options = {
    extra.gaming.enable = lib.mkEnableOption "Enable essentials for gaming support";
  };

  config = lib.mkIf config.extra.gaming.enable {
    hardware.xone.enable = true; # xbox controller
    hardware.xpadneo.enable = true;

    programs = {
      steam = {
        enable = true;
        protontricks = {
          enable = true;
          package = pkgs.protontricks;
        };
        package = pkgs.steam.override {
          extraPkgs =
            pkgs:
            (builtins.attrValues {
              inherit (pkgs.xorg)
                libXcursor
                libXi
                libXinerama
                libXScrnSaver
                ;

              inherit (pkgs.stdenv.cc.cc) lib;

              inherit (pkgs)
                libpng
                libpulseaudio
                libvorbis
                libkrb5
                keyutils
                gperftools
                ;
            });
        };
        extraCompatPackages = [ pkgs.unstable.proton-ge-bin ];
        localNetworkGameTransfers.openFirewall = true;
        gamescopeSession.enable = true;

      };

      gamescope = {
        enable = true;
        capSysNice = true;
      };

      gamemode = {
        enable = true;
        settings = {
          general = {
            softrealtime = "on";
            inhibit_screensaver = 1;
          };
          gpu = {
            apply_gpu_optimisations = "accept-responsibility";
            gpu_device = 1; # The DRM device number on the system (usually 0), ie. the number in /sys/class/drm/card0/
            amd_performance_level = "high";
          };
          custom = {
            start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
            end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
          };
        };
      };
    };

    environment.systemPackages = with pkgs; [

      winetricks
      wineWowPackages.stable

      mangohud
      prismlauncher
      heroic
      bottles
      lutris
    ];
  };
}
