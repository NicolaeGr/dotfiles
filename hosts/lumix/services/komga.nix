{ lib, pkgs, ... }:
let
  containerLib = import ./_util.nix { inherit pkgs lib; };
  stateDir = "/storage/jellyfin/komga";
  ip = "192.168.100.12";
in
{
  containers.komga = containerLib.mkServiceContainer {
    enable = true;
    ip = ip;

    mounts = {
      "/storage/media" = {
        hostPath = "/storage/media";
        isReadOnly = true;
      };
      "${stateDir}" = {
        hostPath = "${stateDir}";
        isReadOnly = false;
      };
    };
    module = {
      services.komga = {
        enable = true;
        openFirewall = true;

        stateDir = stateDir;
        settings.server.port = 25600;

        user = "deploy";
        group = "users";
      };

      # Temporary fix to change package on the existing service
      systemd.services.komga.serviceConfig.ExecStart = lib.mkForce (lib.getExe pkgs.unstable.komga);
    };
  };

  services.nginx.virtualHosts."komga.electrolit.biz" = {
    forceSSL = true;
    enableACME = true;

    extraConfig = ''
      set $komga "${ip}:25600";
      client_max_body_size 20000m;

      location / {
        proxy_pass http://$komga;
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
}
