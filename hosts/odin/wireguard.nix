{
  self,
  config,
  ...
}:
let
  cfg = config.local.wireguard;
in
{
  local.wireguard.enable = true;

  sops.secrets.odin_wg_private_key = {
    sopsFile = (self + "/secrets/wireguard.yaml");
    format = "yaml";
  };

  networking.wg-quick.interfaces.wg0 = {
    dns = [ "10.100.0.1" ];
    address = [ "10.100.0.2/24" ];

    privateKeyFile = config.sops.secrets.odin_wg_private_key.path;

    peers = [
      {
        publicKey = "uT3bM9N2xsDmlMMmIf4mS6PysWUxEcwAfTv3j7x1unc=";
        endpoint = "electrolit.biz:${toString cfg.listenPort}";
        allowedIPs = [ "10.100.0.0/24" ];

        persistentKeepalive = 25;
      }
    ];
  };
}
