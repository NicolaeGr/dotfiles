{ pkgs, containerLib, ... }:
let
  ip = "192.168.100.21";
  baseDir = "/storage/appdata";
in
{
  containers.arr = containerLib.mkServiceContainer {
    inherit ip;

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

    module = {
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
        package = pkgs.lidarr;

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

        settings = {
          directories.app = "${baseDir}/slskd";

          downloads.completed = "/storage/downloads/slskd/completed";
          downloads.incomplete = "/storage/downloads/slskd/incomplete";
        };
      };

      systemd.tmpfiles.rules = [
        "d ${baseDir}/soularr 0755 deploy users -"
      ];

      environment.etc."soularr/config.ini".text = ''
        [Lidarr]
        host_url = http://127.0.0.1:8686
        api_key = $LIDARR_API_KEY
        download_dir = /storage/downloads/slskd/completed

        [Slskd]
        host_url = http://127.0.0.1:5030
        api_key = $SLSKD_API_KEY
        download_dir = /storage/downloads/slskd/completed

        [Settings]
        script_interval = 300
        search_type = incrementing_page
        number_of_albums_to_grab = 5
        allowed_filetypes = flac, mp3 320, mp3
        album_prepend_artist = True
      '';

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

          EnvironmentFile = "-${baseDir}/soularr/secrets.env";

          ExecStartPre = "${pkgs.coreutils}/bin/ln -sf /etc/soularr/config.ini ${baseDir}/soularr/config.ini";
          ExecStart = "${pkgs.soularr}/bin/soularr";

          Restart = "on-failure";
          RestartSec = "10s";
        };
      };
    };
  };

  # ---------------------------------------------------------------------------
  # Nginx Reverse Proxy Domains
  # ---------------------------------------------------------------------------
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
      "slskd.electrolit.biz" = makeDomainConfig 5030;
    };
}
