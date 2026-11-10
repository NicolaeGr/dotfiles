{
  self,
  config,
  configVars,
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

  sops.templates."wg-nm.env".content = ''
    WG_PRIVATE_KEY=${config.sops.placeholder.odin_wg_private_key}
  '';

  networking.networkmanager.ensureProfiles = {
    environmentFiles = [ config.sops.templates."wg-nm.env".path ];

    profiles.lumix-vpn = {
      connection = {
        id = "lumix-vpn";
        type = "wireguard";
        interface-name = "wg0";
        autoconnect = "true";
      };

      wireguard.private-key = "$WG_PRIVATE_KEY";

      "wireguard-peer.uT3bM9N2xsDmlMMmIf4mS6PysWUxEcwAfTv3j7x1unc=" = {
        endpoint = "${configVars.net.wg.endpoint}:${toString cfg.listenPort}";
        allowed-ips = "${configVars.net.wg.subnet}; ${configVars.net.svc.subnet};";
        persistent-keepalive = "25";
      };

      ipv4 = {
        method = "manual";
        address1 = "10.100.0.2/16";
        dns = "${configVars.net.wg.serverIp};";
      };
      ipv6.method = "disabled";
    };
  };
}
