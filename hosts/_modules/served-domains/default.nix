{
  config,
  lib,
  ...
}:
let
  isIpv4 = host: builtins.match "[0-9]{1,3}(\\.[0-9]{1,3}){3}" host != null;

  isDomain = host: lib.hasInfix "." host && !(isIpv4 host);

  domains = lib.pipe config.services.nginx.virtualHosts [
    (lib.mapAttrsToList (
      name: vhost:
      [ (if vhost.serverName != null then vhost.serverName else name) ] ++ vhost.serverAliases
    ))
    lib.flatten
    (map (lib.removePrefix "*."))
    (builtins.filter isDomain)
    lib.unique
    (lib.sort lib.lessThan)
  ];
in
{
  options.local.servedDomains = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    readOnly = true;
    description = ''
      FQDN host names served by nginx on this host, derived from
      `services.nginx.virtualHosts`. The catch-all `_` host and IP aliases are
      excluded. Empty when nginx is not configured.
    '';
  };

  config.local.servedDomains = domains;
}
