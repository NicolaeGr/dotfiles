{
  lib,
  pkgs,
  ...
}:
let
  containerLib = import ./_util.nix { inherit pkgs lib; };
  ip = "192.168.100.13";
in
{
  containers.navidrome = containerLib.mkServiceContainer {
    ip = ip;

    mounts = {
      "/storage" = {
        hostPath = "/storage";
        isReadOnly = true;
      };
    };

    module = {
      services.navidrome = {
        enable = true;

        openFirewall = true;

        user = "deploy";
        group = "users";

        settings = {
          Address = "0.0.0.0";
          Port = 4533;

          MusicFolder = "/storage/media/music";
        };
      };
    };
  };

  services.nginx.virtualHosts."music.electrolit.biz" = containerLib.withPrivateAccess {
    forceSSL = true;
    useACMEHost = "electrolit.biz";

    locations."/" = {
      proxyPass = "http://${ip}:4533";

      proxyWebsockets = true;

      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
      '';
    };
  };
}
