{ config, pkgs, ... }:
{
  extra.wireguard.enable = true;

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.2/24" ];

    privateKeyFile = config.sops.secrets.odin_wg_private_key.path;

    peers = [
      {
        publicKey = "uT3bM9N2xsDmlMMmIf4mS6PysWUxEcwAfTv3j7x1unc=";
        endpoint = "electrolit.biz:25566";

        allowedIPs = [
          "10.100.0.0/24"
        ];

        persistentKeepalive = 25;
      }
    ];
  };
}
