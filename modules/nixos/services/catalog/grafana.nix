{
  local.platform.services.grafana = {
    host = "lumix";
    ports.http = 8101;

    ingress.http."grafana.electrolit.biz" = {
      port = "http";
      access = "private";
      proxyWebsockets = true;
    };
  };
}
