{
  config,
  configLib,
  ...
}:
{
  extra.wireguard.enable = true;

  sops.secrets.lumix_wg_private_key = {
    sopsFile = (configLib.relativeToRoot "secrets/wireguard.yaml");
    format = "yaml";
  };

  networking.wireguard.interfaces.wg0 = {
    listenPort = config.extra.wireguard.listenPort;

    privateKeyFile = config.sops.secrets.lumix_wg_private_key.path;

    peers = [
      {
        publicKey = "DoB3CnXKA7eo+YR7FHzdk9SBzDde4mZBRWWubrSxfTU=";
        allowedIPs = [ "10.100.0.2/32" ];
      }
      {
        publicKey = "EGHSJN6pS4o7Jhx0+yBzOUUwNrDyiGFyJLdrnSYOIRA=";
        allowedIPs = [ "10.100.0.3/32" ];
      }
    ];
  };

}
