{
  local.platform.services.jellyfin = {
    host = "lumix";
    address = "10.200.0.11";
    ports.http = 8096;

    ingress.http."jf.electrolit.biz" = {
      port = "http";
      access = "public";
      extraConfig = ''
        client_max_body_size 20M;

        # Security / XSS Mitigation
        add_header X-Content-Type-Options "nosniff" always;

        # Permissions-Policy
        add_header Permissions-Policy "accelerometer=(), ambient-light-sensor=(), battery=(), bluetooth=(), camera=(), clipboard-read=(), display-capture=(), document-domain=(), encrypted-media=(), gamepad=(), geolocation=(), gyroscope=(), hid=(), idle-detection=(), interest-cohort=(), keyboard-map=(), local-fonts=(), magnetometer=(), microphone=(), payment=(), publickey-credentials-get=(), serial=(), sync-xhr=(), usb=(), xr-spatial-tracking=()" always;

        # CSP
        add_header Content-Security-Policy "default-src https: data: blob:; img-src 'self' https://*; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline' https://www.gstatic.com https://www.youtube.com blob:; worker-src 'self' blob:; connect-src 'self'; object-src 'none'; frame-ancestors 'self'; font-src 'self';" always;
      '';
      proxyExtraConfig = ''
        proxy_set_header X-Forwarded-Protocol $scheme;
        proxy_set_header X-Forwarded-Host $http_host;
        proxy_buffering off;
      '';
      paths."/socket" = {
        extraConfig = ''
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
          proxy_set_header X-Forwarded-Protocol $scheme;
          proxy_set_header X-Forwarded-Host $http_host;
        '';
      };
    };

    container = {
      mounts = {
        "/storage" = {
          hostPath = "/storage";
          isReadOnly = false;
        };
        "/dev/dri" = {
          hostPath = "/dev/dri";
          isReadOnly = false;
        };
      };

      module =
        { pkgs, ... }:
        {
          hardware.graphics = {
            enable = true;

            extraPackages = with pkgs; [
              intel-media-driver
              intel-compute-runtime
              vpl-gpu-rt
              libvdpau-va-gl
              libva-utils
            ];
          };

          services.jellyfin = {
            enable = true;
            openFirewall = true;

            user = "deploy";
            group = "users";

            cacheDir = "/storage/appdata/jellyfin/cache";
            configDir = "/storage/appdata/jellyfin/config";
            dataDir = "/storage/appdata/jellyfin/data";
            logDir = "/storage/appdata/jellyfin/log";
          };
        };
    };
  };
}
