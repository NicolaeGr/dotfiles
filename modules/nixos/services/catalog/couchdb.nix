{
  local.platform.services.couchdb = {
    host = "lumix";
    address = "10.200.0.24";
    ports.http = 5984;

    ingress.http."obsidian.electrolit.biz" = {
      port = "http";
      access = "public";
      proxyWebsockets = true;
      proxyExtraConfig = "client_max_body_size 100M;";
      paths."/_utils/" = {
        access = "private";
      };
    };

    container = {
      mounts."/var/lib/couchdb" = {
        hostPath = "/storage/appdata/couchdb";
        isReadOnly = false;
      };

      module = {
        services.couchdb = {
          enable = true;
          bindAddress = "0.0.0.0";
        };

        networking.firewall.allowedTCPPorts = [ 5984 ];
      };
    };
  };
}
