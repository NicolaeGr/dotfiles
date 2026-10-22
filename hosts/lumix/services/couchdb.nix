{
  containerLib,
  ...
}:
let
  ip = "192.168.100.24";
  domain = "electrolit.biz";
  subdomain = "obsidian.${domain}";

  stateDir = "/storage/appdata/couchdb";
in
{
  containers.couchdb = containerLib.mkServiceContainer {
    inherit ip;

    mounts = {
      "/var/lib/couchdb" = {
        hostPath = stateDir;
        isReadOnly = false;
      };
    };

    module = {
      services.couchdb = {
        enable = true;
        bindAddress = "0.0.0.0";
      };

      networking.firewall.allowedTCPPorts = [ 5984 ];
    };
  };

  services.nginx.virtualHosts."${subdomain}" = {
    forceSSL = true;
    useACMEHost = domain;

    locations."/" = {
      proxyPass = "http://${ip}:5984";
      proxyWebsockets = true;
      extraConfig = ''
        client_max_body_size 100M;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
      '';
    };

    locations."/_utils/" = containerLib.withPrivateAccess {
      proxyPass = "http://${ip}:5984/_utils/";
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
      '';
    };
  };
}
