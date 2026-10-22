{ containerLib, configVars, ... }:
{
  services.nginx.virtualHosts."electrolit.biz" = containerLib.withPrivateAccess {
    forceSSL = true;
    useACMEHost = "electrolit.biz";
    serverAliases = [
      "www.electrolit.biz"
      configVars.net.lan.serverIp
      configVars.net.wg.serverIp
    ];

    locations."/" = {
      root = builtins.dirOf ./index.html;
      index = "index.html";

      extraConfig = ''
        default_type text/html;
      '';
    };
  };
}
