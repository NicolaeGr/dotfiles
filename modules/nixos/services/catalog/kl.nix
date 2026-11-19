{ lib, ... }:
let
  klServices = {
    pve = {
      address = "192.168.100.40";
      port = 8006;
      domain = "pve.electrolit.biz";
      https = true;
      extra = "proxy_buffering off; client_max_body_size 0;";
    };
    box1 = {
      address = "10.250.0.11";
      port = 22;
    };
    svc1 = {
      address = "10.250.0.23";
      port = 8080;
      domain = "svc1.electrolit.biz";
    };
  };

  mk =
    name:
    {
      address,
      port,
      domain ? null,
      https ? false,
      access ? "private",
      extra ? "",
    }:
    {
      host = "lumix";
      inherit address;
      ports.main = port;
      ingress = {
        internal.${name}.port = "main";
      }
      // lib.optionalAttrs (domain != null) {
        http.${domain} = {
          port = "main";
          inherit access;
          proxyWebsockets = true;
          upstreamTls = https;
          proxyExtraConfig = extra;
        };
      };
    };
in
{
  local.platform.services = lib.mapAttrs' (n: v: lib.nameValuePair "kl-${n}" (mk n v)) klServices;
}
