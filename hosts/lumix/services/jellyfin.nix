{
  config,
  lib,
  pkgs,
  ...
}:

let
  containerLib = import ./_util.nix { inherit pkgs lib; };
  baseDir = "/storage/appdata/jellyfin";
  ip = "192.168.100.11";
in
{
  containers.jellyfin = containerLib.mkServiceContainer {
    enable = true;
    ip = ip;

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

    module = {
      hardware.graphics = {
        enable = true;

        extraPackages = with pkgs; [
          intel-media-driver
          libvdpau-va-gl
        ];
      };

      services.jellyfin = {
        enable = true;
        openFirewall = true;

        user = "deploy";
        group = "users";

        # TODO: Enable in the next nixos release
        # hardwareAcceleration = {
        #   enable = true;
        #   type = "qsv";
        #   dev = "/dev/dri/renderD128";
        # };

        cacheDir = "${baseDir}/cache";
        configDir = "${baseDir}/config";
        dataDir = "${baseDir}/data";
        logDir = "${baseDir}/log";
      };
    };
  };

  services.nginx.virtualHosts."jf.electrolit.biz" = {
    forceSSL = true;
    enableACME = true;

    extraConfig = ''
      client_max_body_size 20M;

      # Security / XSS Mitigation
      add_header X-Content-Type-Options "nosniff" always;

      # Permissions-Policy
      add_header Permissions-Policy "accelerometer=(), ambient-light-sensor=(), battery=(), bluetooth=(), camera=(), clipboard-read=(), display-capture=(), document-domain=(), encrypted-media=(), gamepad=(), geolocation=(), gyroscope=(), hid=(), idle-detection=(), interest-cohort=(), keyboard-map=(), local-fonts=(), magnetometer=(), microphone=(), payment=(), publickey-credentials-get=(), serial=(), sync-xhr=(), usb=(), xr-spatial-tracking=()" always;

      # CSP
      add_header Content-Security-Policy "default-src https: data: blob:; img-src 'self' https://*; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline' https://www.gstatic.com https://www.youtube.com blob:; worker-src 'self' blob:; connect-src 'self'; object-src 'none'; frame-ancestors 'self'; font-src 'self';" always;

      set $jellyfin "${ip}";

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
    '';
  };
}
