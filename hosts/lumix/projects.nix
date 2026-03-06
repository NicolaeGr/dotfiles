{
  pkgs,
  ...
}:
{

  services.cloudflare-dyndns.domains = [ "expense.electrolit.biz" ];

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

  services.nginx.virtualHosts."expense.electrolit.biz" = {
    forceSSL = true;
    enableACME = true;

    extraConfig = ''
      client_max_body_size 20M;

      # Basic security headers
      add_header X-Content-Type-Options "nosniff" always;
      add_header X-Frame-Options "SAMEORIGIN" always;
      add_header Referrer-Policy "strict-origin-when-cross-origin" always;

      location / {
        proxy_pass http://127.0.0.1:9000;

        proxy_http_version 1.1;
        proxy_set_header Connection "";

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $http_host;

        proxy_buffering off;
      }
    '';
  };
}
