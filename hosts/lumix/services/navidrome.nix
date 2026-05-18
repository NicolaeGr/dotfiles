{
  lib,
  pkgs,
  ...
}:
let
  containerLib = import ./_util.nix { inherit pkgs lib; };
  ip = "192.168.100.13";
in
{
  containers.navidrome = containerLib.mkServiceContainer {
    ip = ip;

    mounts = {
      "/storage" = {
        hostPath = "/storage";
        isReadOnly = true;
      };
    };

    module = {
      services.navidrome = {
        enable = true;

        openFirewall = true;

        user = "deploy";
        group = "users";

        settings = {
          Address = "0.0.0.0";
          Port = 4533;

          MusicFolder = "/storage/media/music";
        };
      };
    };
  };
}
