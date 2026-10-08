{ containerLib, ... }:
let
  ip = "192.168.100.23";
in
{
  containers.soju = containerLib.mkServiceContainer {
    inherit ip;

    module = {
      services.soju = {
        enable = true;

        listen = [
          "http://${ip}:8080"
        ];

        httpOrigins = [ "https://sj.electrolit.biz" ];
      };

      networking.firewall.allowedTCPPorts = [ 8080 ];
    };
  };

  services.nginx.virtualHosts."sj.electrolit.biz" = containerLib.withPrivateAccess {
    forceSSL = true;
    useACMEHost = "electrolit.biz";

    locations."/" = {
      proxyPass = "http://${ip}:8080";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
      '';
    };
  };
}
