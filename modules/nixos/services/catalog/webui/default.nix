{ configVars, ... }:
{
  local.platform.services.webui = {
    host = "lumix";
    ingress.http."electrolit.biz" = {
      port = null;
      aliases = [
        "www.electrolit.biz"
        configVars.net.lan.serverIp
        configVars.net.wg.serverIp
      ];
      vhost.locations."/" = {
        root = ./.;
        index = "index.html";
        extraConfig = ''
          default_type text/html;
        '';
      };
    };
  };
}
