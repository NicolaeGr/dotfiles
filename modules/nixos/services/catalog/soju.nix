{ configVars, ... }:
let
  net = configVars.net;
  domain = "sj.electrolit.biz";
in
{
  local.platform.services.soju = {
    host = "lumix";
    address = "192.168.100.23";
    ports = {
      http = 8080;
      irc = 6667;
    };

    ingress = {
      http.${domain} = {
        port = "http";
        proxyWebsockets = true;
      };
      stream.irc = {
        listen = 6697;
        port = "irc";
        proxyProtocol = true;
        access = [
          net.lan.subnet
          net.wg.subnet
        ];
        extraConfig = ''
          ssl_ciphers HIGH:!aNULL:!MD5;
          ssl_session_cache shared:SSL:10m;
          ssl_session_timeout 10m;
        '';
      };
    };

    container.module =
      { svc, configVars, ... }:
      {
        services.soju = {
          enable = true;
          hostName = domain;

          listen = [
            "http+insecure://${svc.address}:${toString svc.ports.http}"
            "irc+insecure://${svc.address}:${toString svc.ports.irc}"
          ];

          httpOrigins = [ "https://${domain}" ];
          acceptProxyIP = [ configVars.net.lan.subnet ];
        };

        networking.firewall.allowedTCPPorts = [
          svc.ports.http
          svc.ports.irc
        ];
      };
  };
}
