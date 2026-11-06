{
  lib,
  pkgs,
  platformOwns,
  ...
}:
{
  config = lib.mkMerge [
    {
      local.platform.services.expense = {
        host = "lumix";
        ports.http = 9000;

        ingress.http."expense.electrolit.biz" = {
          port = "http";
          access = "public";
          extraConfig = ''
            client_max_body_size 20M;

            # Basic security headers
            add_header X-Content-Type-Options "nosniff" always;
            add_header X-Frame-Options "SAMEORIGIN" always;
            add_header Referrer-Policy "strict-origin-when-cross-origin" always;
          '';
          proxyExtraConfig = ''
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_buffering off;
          '';
        };
      };
    }

    (lib.mkIf (platformOwns "expense") {
      systemd.services.expensetracker = {
        description = "ExpenseTracker Docker Compose";
        after = [
          "network.target"
          "docker.service"
        ];
        wants = [ "docker.service" ];

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          WorkingDirectory = "/shared/ExpenseTracker";
          ExecStart = "${pkgs.docker}/bin/docker compose -f docker-compose.yml up -d";
          ExecStop = "${pkgs.docker}/bin/docker compose -f docker-compose.yml down";
        };

        wantedBy = [ "multi-user.target" ];
      };
    })
  ];
}
