{
  local.platform.services.komga = {
    host = "lumix";
    address = "192.168.100.12";
    ports.http = 25600;

    ingress.http."komga.electrolit.biz" = {
      port = "http";
      access = "public";
      extraConfig = "client_max_body_size 20000m;";
      proxyExtraConfig = ''
        proxy_http_version 1.1;
        proxy_redirect off;
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        proxy_busy_buffers_size 256k;
      '';
    };

    container = {
      mounts."/storage" = {
        hostPath = "/storage";
        isReadOnly = false;
      };

      module =
        { svc, ... }:
        {
          services.komga = {
            enable = true;
            openFirewall = true;

            stateDir = "/storage/appdata/komga";
            settings.server.port = svc.ports.http;

            user = "deploy";
            group = "users";
          };
        };
    };
  };
}
