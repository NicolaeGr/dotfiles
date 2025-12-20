{
  config,
  configLib,
  ...
}:
{
  extra.wireguard.enable = true;

  sops.secrets.odin_wg_private_key = {
    sopsFile = (configLib.relativeToRoot "secrets/wireguard.yaml");
    format = "yaml";
  };

  networking.wg-quick.interfaces.wg0 = {
    address = [ "10.100.0.2/24" ];

    privateKeyFile = config.sops.secrets.odin_wg_private_key.path;

    postUp = ''
      sysctl -w net.ipv4.conf.all.rp_filter=0
      sysctl -w net.ipv4.conf.default.rp_filter=0
      sysctl -w net.ipv4.conf.wg0.rp_filter=0
    '';

    postDown = ''
      sysctl -w net.ipv4.conf.wg0.rp_filter=2
    '';

    peers = [
      {
        publicKey = "uT3bM9N2xsDmlMMmIf4mS6PysWUxEcwAfTv3j7x1unc=";
        endpoint = "electrolit.biz:${toString config.extra.wireguard.listenPort}";
        allowedIPs = [ "10.100.0.0/24" ];
        persistentKeepalive = 25;
      }
    ];
  };

  # networking.wireguard.interfaces.wg0 = {
  #   ips = [ "10.100.0.2/24" ];

  #   privateKeyFile = config.sops.secrets.odin_wg_private_key.path;

  #   peers = [
  #     {
  #       publicKey = "uT3bM9N2xsDmlMMmIf4mS6PysWUxEcwAfTv3j7x1unc=";
  #       endpoint = "electrolit.biz:${toString config.extra.wireguard.listenPort}";

  #       allowedIPs = [
  #         "10.100.0.0/24"
  #       ];

  #       persistentKeepalive = 25;
  #     }
  #   ];
  # };
}
