{ containerLib, ... }:
let
  ip = "192.168.100.23";

  domain = "electrolit.biz";
  subdomain = "sj.${domain}";
in
{
  containers.soju = containerLib.mkServiceContainer {
    inherit ip;

    module = {
      services.soju = {
        enable = true;
        hostName = subdomain;

        listen = [
          "http+insecure://${ip}:8080"
          "irc+insecure://${ip}:6667"
        ];

        httpOrigins = [ "https://${subdomain}" ];

        extraConfig = ''
          accept-proxy-ip ${containerLib.homeIpRange}
        '';
      };

      networking.firewall.allowedTCPPorts = [
        8080
        6667
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 6697 ];

  services.nginx = {
    virtualHosts."${subdomain}" = containerLib.withPrivateAccess {
      forceSSL = true;
      useACMEHost = domain;

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

    streamConfig = ''
      server {
        listen 6697 ssl;
        proxy_pass ${ip}:6667;

        proxy_protocol on;

        ssl_certificate /var/lib/acme/${domain}/fullchain.pem;
        ssl_certificate_key /var/lib/acme/${domain}/key.pem;
        ssl_trusted_certificate /var/lib/acme/${domain}/chain.pem;

        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 10m;
      }
    '';
  };
}
