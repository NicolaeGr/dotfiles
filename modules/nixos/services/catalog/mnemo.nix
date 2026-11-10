{ inputs, ... }:
{
  local.platform.services.mnemo = {
    host = "lumix";
    address = "10.200.0.26";
    ports.http = 8080;

    ingress.http."mnemo.electrolit.biz" = {
      port = "http";
      access = "public";
    };

    container = {
      mounts."/var/lib/mnemo" = {
        hostPath = "/storage/appdata/mnemo";
        isReadOnly = true;
      };

      module =
        {
          pkgs,
          svc,
          endpoints,
          ...
        }:
        let
          mnemo = inputs.mnemo.packages.${pkgs.stdenv.hostPlatform.system}.default;
        in
        {
          systemd.services.mnemo = {
            description = "mnemo";
            after = [ "network-online.target" ];
            wants = [ "network-online.target" ];
            wantedBy = [ "multi-user.target" ];

            environment = {
              ADDR = "0.0.0.0:${toString svc.ports.http}";
              COOKIE_SECURE = "true";
              PGHOST = endpoints.pg.host;
              PGPORT = toString endpoints.pg.port;
              PGUSER = "mnemo";
              PGDATABASE = "mnemo";
            };

            serviceConfig = {
              User = "deploy";
              Group = "users";

              WorkingDirectory = "${mnemo}/share/mnemo";
              EnvironmentFile = "/var/lib/mnemo/mnemo.env";
              ExecStart = "${mnemo}/bin/server";

              Restart = "on-failure";
              RestartSec = "5s";

              NoNewPrivileges = true;
              PrivateTmp = true;
              ProtectSystem = "strict";
              ProtectHome = true;
            };
          };

          networking.firewall.allowedTCPPorts = [ svc.ports.http ];
        };
    };
  };
}
