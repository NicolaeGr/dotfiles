{
  lib,
  pkgs,
  containerLib,
  ...
}:
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

      services.lidarr =
        let
          lidarrNightly = pkgs.stdenv.mkDerivation {
            pname = "lidarr";
            version = "nightly-3.1.3.4987";

            src = pkgs.fetchurl {
              name = "lidarr-nightly.tar.gz";
              url = "https://lidarr.servarr.com/v1/update/nightly/updatefile?os=linux&arch=x64&runtime=netcore";
              hash = "sha256-5ScoNmV91YCQIXW3Cwi6Y/onpk1YXE4EbandXFPf5BM=";
            };

            dontBuild = true;
            dontConfigure = true;

            nativeBuildInputs = [
              pkgs.autoPatchelfHook
              pkgs.makeWrapper
            ];

            buildInputs = [
              pkgs.dotnetCorePackages.aspnetcore_8_0
              pkgs.sqlite
              pkgs.zlib
              pkgs.icu
              pkgs.openssl
              pkgs.krb5
              pkgs.libunwind
              pkgs.stdenv.cc.cc.lib
              pkgs.lttng-ust_2_12
            ];

            installPhase = ''
              runHook preInstall
              mkdir -p $out/share/lidarr $out/bin
              cp -a . $out/share/lidarr/

              makeWrapper $out/share/lidarr/Lidarr $out/bin/Lidarr \
                --set DOTNET_ROOT ${pkgs.dotnetCorePackages.aspnetcore_8_0} \
                --prefix LD_LIBRARY_PATH : ${
                  pkgs.lib.makeLibraryPath [
                    pkgs.icu
                    pkgs.openssl
                    pkgs.krb5
                    pkgs.libunwind
                    pkgs.sqlite
                    pkgs.zlib
                    pkgs.stdenv.cc.cc.lib
                  ]
                }
              runHook postInstall
            '';
          };
        in
        {
          enable = true;
          openFirewall = true;
          package = lidarrNightly;
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
            port = 5030;
          };
        };
      };

      systemd.services.slskd.serviceConfig.Environment = lib.mkAfter [ "APP_DIR=${baseDir}/slskd" ];
      networking.firewall.allowedUDPPorts = [ 5030 ];
      networking.firewall.allowedTCPPorts = [ 5030 ];

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
