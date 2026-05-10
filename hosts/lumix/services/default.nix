{
  pkgs,
  lib,
  ...
}:
let
  containerLib = import ./_util.nix { inherit pkgs lib; };
  baseDir = "/storage/jellyfin";
in
{
  containers.arr = containerLib.mkServiceContainer {
    enable = true;
    ip = "192.168.100.21";
    mounts = {
      "${baseDir}" = {
        hostPath = "${baseDir}";
        isReadOnly = false;
      };
      "/storage/media" = {
        hostPath = "/storage/media";
        isReadOnly = false;
      };
    };
    serviceConfig = ./arr.nix;
  };

  containers.navidrome = containerLib.mkServiceContainer {
    enable = true;
    ip = "192.168.100.14";
    mounts = {
      "${baseDir}/navidrome" = {
        hostPath = "${baseDir}/navidrome";
        isReadOnly = false;
      };
      "/storage/media/music" = {
        hostPath = "/storage/media/music";
        isReadOnly = true;
      };
    };
    serviceConfig = ./navidrome.nix;
  };
}
