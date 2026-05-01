{
  pkgs,
  lib,
  hostName,
  ...
}:
let
  baseDir = "/storage/jellyfin";
  landingPage = builtins.readFile ./page.html;
in
{
  config = {
    hardware.graphics.enable = true;
    services.cloudflare-dyndns.domains = [
      "jf.electrolit.biz"
      "komga.electrolit.biz"
      "colibri.electrolit.biz"
    ];

    hardware.graphics.extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libvdpau-va-gl
    ];

    environment.systemPackages = with pkgs; [
      mpv
      unstable.seanime
    ];

    services.jellyfin = {
      enable = true;
      package = pkgs.unstable.jellyfin;

      dataDir = "${baseDir}/jellyfin";
    };

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

    services.lidarr = {
      enable = true;
      openFirewall = true;

      dataDir = "${baseDir}/lidarr";

      user = "deploy";
      group = "users";
    };

    services.navidrome = {
      enable = false;
      openFirewall = true;

      settings = {
        Address = "0.0.0.0";
        Port = 4533;
        MusicFolder = "/storage/media/music";
        DataFolder = "${baseDir}/navidrome";
      };

      user = "deploy";
      group = "users";
    };

    services.prowlarr = {
      enable = true;
      openFirewall = true;
    };

    services.bazarr = {
      enable = true;
      openFirewall = true;

      user = "deploy";
      group = "users";
    };

    services.qbittorrent = {
      enable = true;

      user = "deploy";
      group = "users";

      profileDir = "${baseDir}/qbittorrent";
      webuiPort = 8020;
      openFirewall = true;
      serverConfig = {
        LegalNotice.Accepted = true;
        Preferences = {
          General.Locale = "en";
          WebUI.CSRFProtection = false;
          WebUI.HostHeaderValidation = true;
          WebUI.Username = "user";
          WebUI.Password_PBKDF2 = "@ByteArray(6/PxK1oTs3CuJ92zB2gzxg==:Efg0yQ8y9Jp3M1Y/IEA8G/DYWge3QwnHWhrwW/5tZbu5nVHuLQfJY7Bb2EwjOfJc9a044juSiKNgjZby+1wR3g==)";
        };
      };
    };

    systemd.services.seanime = {
      description = "Seanime WebServer";

      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      path = [
        pkgs.mpv
        pkgs.bash
        pkgs.coreutils
      ];

      serviceConfig = {
        Type = "simple";

        ExecStartPre = "${pkgs.coreutils}/bin/sleep 10";
        ExecStart = "${pkgs.unstable.seanime}/bin/seanime";

        Environment = "PATH=${pkgs.mpv}/bin:${pkgs.bash}/bin:${pkgs.coreutils}/bin";

        User = "deploy";
        Group = "users";

        Restart = "on-failure";
      };
    };

    networking.firewall.allowedTCPPorts = [ 43211 ];

    services.komga = {
      enable = true;
      stateDir = "${baseDir}/komga";
      user = "deploy";
      group = "users";
      settings.server.port = 25600;
    };

    systemd.services.komga.serviceConfig.ExecStart = lib.mkForce (lib.getExe pkgs.unstable.komga);

    services.nginx = {
      virtualHosts."jf.electrolit.biz" = {
        forceSSL = true;
        enableACME = true;

        extraConfig = ''
          client_max_body_size 20M;

          # Security / XSS Mitigation
          add_header X-Content-Type-Options "nosniff" always;

          # Permissions-Policy (reduce fingerprinting)
          add_header Permissions-Policy "accelerometer=(), ambient-light-sensor=(), battery=(), bluetooth=(), camera=(), clipboard-read=(), display-capture=(), document-domain=(), encrypted-media=(), gamepad=(), geolocation=(), gyroscope=(), hid=(), idle-detection=(), interest-cohort=(), keyboard-map=(), local-fonts=(), magnetometer=(), microphone=(), payment=(), publickey-credentials-get=(), serial=(), sync-xhr=(), usb=(), xr-spatial-tracking=()" always;

          # Content Security Policy
          add_header Content-Security-Policy "default-src https: data: blob:; img-src 'self' https://*; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline' https://www.gstatic.com https://www.youtube.com blob:; worker-src 'self' blob:; connect-src 'self'; object-src 'none'; frame-ancestors 'self'; font-src 'self';" always;

          # Proxy settings
          set $jellyfin 127.0.0.1;

          location / {
            proxy_pass http://$jellyfin:8096;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Protocol $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_buffering off;
          }

          location /socket {
            proxy_pass http://$jellyfin:8096;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Protocol $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
          }

          # access_log /var/log/nginx/access.log stripsecrets;
        '';
      };

      virtualHosts."${hostName}.local" = {
        serverAliases = [ "10.100.0.1" ];

        locations."/" = {
          return = "200 '${landingPage}'";
          extraConfig = ''
            default_type text/html;
          '';
        };
      };

      virtualHosts."komga.electrolit.biz" = {
        forceSSL = true;
        enableACME = true;

        extraConfig = ''
          set $komga 127.0.0.1;
          client_max_body_size 20000m;

          location / {
            proxy_pass http://$komga:25600;
            proxy_http_version 1.1;
            proxy_redirect off;
            proxy_buffer_size 128k;
            proxy_buffers 4 256k;
            proxy_busy_buffers_size 256k;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          }
        '';
      };

      virtualHosts."colibri.electrolit.biz" = {
        forceSSL = true;
        enableACME = true;

        locations."/" = {
          return = ''200 '<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Site Unavailable</title><style>body{margin:0;height:100vh;display:flex;align-items:center;justify-content:center;background:linear-gradient(135deg,#460000,#190000);color:#f8d7da;font-family:system-ui,-apple-system,BlinkMacSystemFont,Segoe UI,Roboto,Ubuntu,sans-serif;text-align:center;} .card{max-width:720px;padding:3rem 2rem;border:1px solid rgba(255,255,255,.08);border-radius:24px;background:rgba(0,0,0,.25);box-shadow:0 24px 80px rgba(0,0,0,.35);} h1{font-size:clamp(2rem,4vw,4rem);margin:0 0 1rem;} p{font-size:1.1rem;line-height:1.7;margin:0;} </style></head><body><div class="card"><h1>Site is down</h1><p>Our site is currently unavailable for technical reasons. Please check back later.</p></div></body></html>' '';
          extraConfig = ''
            default_type text/html;
          '';
        };
      };
    };
  };
}
