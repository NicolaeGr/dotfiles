{ config, lib, ... }:
{
  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.1/24" ];
    listenPort = 8017;

    privateKeyFile = config.sops.secrets.lumix_wg_private_key.path;

    peers = [
      {
        publicKey = "DoB3CnXKA7eo+YR7FHzdk9SBzDde4mZBRWWubrSxfTU=";
        allowedIPs = [ "10.100.0.2/32" ];
      }
    ];
  };

}
