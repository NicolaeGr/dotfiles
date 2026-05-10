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
  services.cloudflare-dyndns.domains = [
    "*.electrolit.biz"
  ];

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      "~^(?<subdomain>.+arr)\.electrolit\.biz$" = containerLib.withPrivateAccess {
        useACMEHost = "electrolit.biz";

        locations."/" = {
          proxyPass = "http://192.168.100.21:80";
          proxyWebsockets = true;

          extraConfig = ''
            proxy_set_header Host $host;
          '';
        };
      };
    };
  };

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
