{ containerLib, ... }:
{
  services.nginx.virtualHosts."electrolit.biz" = containerLib.withPrivateAccess {
    forceSSL = true;
    useACMEHost = "electrolit.biz";
    serverAliases = [
      "192.168.100.10"
      "10.100.0.1"
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
