{ lib, pkgs, ... }:
let
  containerLib = import ./_util.nix { inherit pkgs lib; };
  baseDir = "/storage/appdata";

  ip = "192.168.100.21";
in
{
  containers.arr = containerLib.mkServiceContainer {
    ip = ip;

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
    module = {
      services.radarr = {
        enable = true;
        openFirewall = true;

        dataDir = "${baseDir}/radarr";

        user = "deploy";
        group = "users";
      };

      services.sonarr = {
        enable = true;
        openFirewall = true;

        dataDir = "${baseDir}/sonarr";

        user = "deploy";
        group = "users";
      };

      services.bazarr = {
        enable = true;
        openFirewall = true;
        user = "deploy";
        group = "users";
      };

      services.lidarr = {
        enable = true;
        openFirewall = true;

        dataDir = "${baseDir}/lidarr";

        user = "deploy";
        group = "users";
      };

      services.prowlarr = {
        enable = true;
        openFirewall = true;
      };
    };
  };

  services.nginx.virtualHosts =
    let
      makeDomainConfig =
        port:
        containerLib.withPrivateAccess {
          forceSSL = true;
          useACMEHost = "electrolit.biz";

          locations."/" = {
            proxyPass = "http://${ip}:${toString port}";

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
      "radarr.electrolit.biz" = makeDomainConfig 7878;
      "sonarr.electrolit.biz" = makeDomainConfig 8989;
      "bazarr.electrolit.biz" = makeDomainConfig 6767;
      "lidarr.electrolit.biz" = makeDomainConfig 8686;
      "prowlarr.electrolit.biz" = makeDomainConfig 9696;
    };
}
