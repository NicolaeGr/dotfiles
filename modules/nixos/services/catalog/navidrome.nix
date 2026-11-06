{
  local.platform.services.navidrome = {
    host = "lumix";
    address = "192.168.100.13";
    ports.http = 4533;

    ingress.http."music.electrolit.biz" = {
      port = "http";
      proxyWebsockets = true;
    };

    container = {
      mounts."/storage" = {
        hostPath = "/storage";
        isReadOnly = true;
      };

      module =
        { svc, ... }:
        {
          services.navidrome = {
            enable = true;
            openFirewall = true;

            user = "deploy";
            group = "users";

            settings = {
              Address = "0.0.0.0";
              Port = svc.ports.http;
              MusicFolder = "/storage/media/music";
            };
          };
        };
    };
  };
}
