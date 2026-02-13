{ pkgs, ... }:
let
  baseDir = "/storage/jellyfin";
in
{
  config = {
    hardware.graphics.enable = true;

    hardware.graphics.extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libvdpau-va-gl
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

    services.cloudflare-dyndns.domains = [ "jf.electrolit.biz" ];

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
    };
  };
}
