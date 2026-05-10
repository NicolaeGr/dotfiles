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
  imports = [
    ./webui
  ];

  services.cloudflare-dyndns.domains = [
    "*.electrolit.biz"
  ];

  services.nginx.virtualHosts =
    let
      makeDomainConfig =
        port:
        containerLib.withPrivateAccess {
          forceSSL = true;
          useACMEHost = "electrolit.biz";

          locations."/" = {
            proxyPass = "http://192.168.100.21:${toString port}";

            extraConfig = ''
              proxy_set_header   Host $host;
              proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header   X-Forwarded-Host $host;
              proxy_set_header   X-Forwarded-Proto $scheme;
              proxy_set_header   Upgrade $http_upgrade;
              proxy_set_header   Connection $http_connection;

              proxy_redirect     off;
              proxy_http_version 1.1;
            '';
          };
        };
    in
    {
      "_" = {
        default = true;
        addSSL = true;
        useACMEHost = "electrolit.biz";

        locations."/" = {
          return = "403";
        };
      };

      "radarr.electrolit.biz" = makeDomainConfig 7878;
      "sonarr.electrolit.biz" = makeDomainConfig 8989;
      "bazarr.electrolit.biz" = makeDomainConfig 6767;
      "lidarr.electrolit.biz" = makeDomainConfig 8686;
      "prowlarr.electrolit.biz" = makeDomainConfig 9696;
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
      "/var/lib" = {
        hostPath = "/var/lib";
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
