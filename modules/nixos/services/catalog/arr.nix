{ lib, ... }:
let
  ports = {
    radarr = 7878;
    sonarr = 8989;
    bazarr = 6767;
    lidarr = 8686;
    prowlarr = 9696;
    slskd = 5030;
  };

  proxyExtraConfig = ''
    proxy_set_header   X-Forwarded-Host $host;
    proxy_set_header   Upgrade $http_upgrade;
    proxy_set_header   Connection $http_connection;

    proxy_redirect     off;
    proxy_http_version 1.1;
  '';

  baseDir = "/storage/appdata";
in
{
  local.platform.services.arr = {
    host = "lumix";
    address = "192.168.100.21";
    inherit ports;

    ingress.http = lib.mapAttrs' (
      name: _:
      lib.nameValuePair "${name}.electrolit.biz" {
        port = name;
        inherit proxyExtraConfig;
      }
    ) ports;

    container = {
      mounts = {
        "/storage" = {
          hostPath = "/storage";
          isReadOnly = false;
        };
        "/var/lib" = {
          hostPath = "/var/lib";
          isReadOnly = false;
        };
      };

      module =
        {
          lib,
          pkgs,
          svc,
          ...
        }:
        {
          services.radarr = {
            enable = true;
            openFirewall = true;
            package = pkgs.radarr;

            dataDir = "${baseDir}/radarr";

            user = "deploy";
            group = "users";
          };

          services.sonarr = {
            enable = true;
            openFirewall = true;
            package = pkgs.sonarr;

            dataDir = "${baseDir}/sonarr";

            user = "deploy";
            group = "users";
          };

          services.bazarr = {
            enable = true;
            openFirewall = true;
            package = pkgs.bazarr;

            user = "deploy";
            group = "users";
          };

          services.lidarr = {
            enable = true;
            openFirewall = true;
            package = pkgs.lidarr-nightly;
            dataDir = "${baseDir}/lidarr";
            user = "deploy";
            group = "users";
          };

          services.prowlarr = {
            enable = true;
            openFirewall = true;
            package = pkgs.prowlarr;
          };

          services.slskd = {
            enable = true;
            openFirewall = true;

            user = "deploy";
            group = "users";

            environmentFile = "${baseDir}/slskd/slskd.env";

            settings = {
              directories.incomplete = "${baseDir}/slskd/incomplete";
              directories.downloads = "${baseDir}/slskd/downloads";

              web = {
                host = "0.0.0.0";
                port = svc.ports.slskd;
              };
            };
          };

          systemd.services.slskd.serviceConfig.Environment = lib.mkAfter [
            "APP_DIR=${baseDir}/slskd"
          ];
          networking.firewall.allowedUDPPorts = [ svc.ports.slskd ];
          networking.firewall.allowedTCPPorts = [ svc.ports.slskd ];

          systemd.services.soularr = {
            description = "Soularr - Lidarr & Slskd Sync Service";
            after = [
              "network.target"
              "lidarr.service"
              "slskd.service"
            ];
            wantedBy = [ "multi-user.target" ];

            serviceConfig = {
              Type = "simple";
              User = "deploy";
              Group = "users";
              WorkingDirectory = "${baseDir}/soularr";

              ExecStart = "${pkgs.soularr}/bin/soularr --config-dir ${baseDir}/soularr";

              Restart = "on-failure";
              RestartSec = "10s";
            };
          };
        };
    };
  };
}
