{
  lib,
  pkgs,
  configVars,
  platformOwns,
  ...
}:
let
  net = configVars.net;
in
{
  config = lib.mkMerge [
    {
      local.platform.services.postgresql = {
        host = "lumix";
        address = "192.168.100.31";
        ports.postgres = 5432;
        ingress.internal.pg.port = "postgres";

        container = {
          mounts."/var/lib/postgresql" = {
            hostPath = "/storage/appdata/postgresql";
            isReadOnly = false;
          };

          module =
            {
              pkgs,
              svc,
              endpoints,
              ...
            }:
            let
              pg = pkgs.postgresql_17;
              ep = endpoints.pg;

              pgNewDb = pkgs.writeShellApplication {
                name = "pg-newdb";
                runtimeInputs = [
                  pg
                  pkgs.openssl
                  pkgs.util-linux
                ];
                text = ''
                  reset=0
                  [ "''${1:-}" = "--reset" ] && { reset=1; shift; }
                  name=''${1:?usage: pg-newdb [--reset] <name>}
                  [[ $name =~ ^[a-z_][a-z0-9_]*$ ]] || { echo "name must match [a-z_][a-z0-9_]*" >&2; exit 1; }

                  exists=$(runuser -u postgres -- psql -d postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='$name'")
                  if [ -n "$exists" ] && [ $reset = 0 ]; then
                    echo "role $name exists; use --reset to rotate its password" >&2; exit 1
                  fi

                  pw=$(openssl rand -hex 16)
                  PW=$pw runuser -u postgres -- psql -v ON_ERROR_STOP=1 -v name="$name" -d postgres <<'SQL'
                  \getenv pw PW
                  SELECT format('CREATE ROLE %I LOGIN', :'name') WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = :'name') \gexec
                  ALTER ROLE :"name" PASSWORD :'pw';
                  SELECT format('CREATE DATABASE %I OWNER %I', :'name', :'name') WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = :'name') \gexec
                  SQL

                  echo "postgres://$name:$pw@${ep.host}:${toString ep.port}/$name"
                '';
              };
            in
            {
              services.postgresql = {
                enable = true;

                package = pg;
                enableTCPIP = true;

                authentication = ''
                  host all all ${net.lan.subnet} scram-sha-256
                  host all all ${net.wg.subnet} scram-sha-256
                  host all all ${net.publicIp}/32 scram-sha-256
                '';
              };

              networking.firewall.allowedTCPPorts = [ svc.ports.postgres ];
              environment.systemPackages = [ pgNewDb ];
            };
        };
      };
    }

    (lib.mkIf (platformOwns "postgresql") {
      environment.systemPackages = [
        (pkgs.writeShellScriptBin "pg-newdb" ''
          exec nixos-container run postgresql -- pg-newdb "$@"
        '')
      ];
    })
  ];
}
