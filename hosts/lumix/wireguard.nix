{
  pkgs,
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

  services.coredns = {
    enable = true;
    config = ''
      electrolit.biz {
          rewrite name regex (.*)\.electrolit\.biz electrolit.biz
          hosts {
              10.100.0.1 electrolit.biz
              fallthrough
          }
      }

      . {
          forward . 1.1.1.1 8.8.8.8
          errors
          cache 30
      }
    '';
  };

  networking.wg-quick.interfaces.wg0 = {
    address = [ "10.100.0.1/24" ];
    listenPort = config.extra.wireguard.listenPort;

    privateKeyFile = config.sops.secrets.lumix_wg_private_key.path;

    postUp = ''
      ${pkgs.iptables}/bin/iptables -A INPUT -i wg0 -p udp --dport 53 -j ACCEPT
    '';

    peers = [
      {
        publicKey = "DoB3CnXKA7eo+YR7FHzdk9SBzDde4mZBRWWubrSxfTU=";
        allowedIPs = [ "10.100.0.2/32" ];
      }
      {
        publicKey = "uTFURev9D7AyDyN5mR5VwZbOM4+UPRjZAfGWdCnzOAo=";
        allowedIPs = [ "10.100.0.3/32" ];
      }
      {
        publicKey = "9rMvLrNfoIBT18kycuIpZhNmtjYraJ5ihUahDd5PdSs=";
        allowedIPs = [ "10.100.0.4/32" ];
      }
    ];
  };

  networking.firewall.interfaces."wg0".allowedUDPPorts = [ 53 ];
}
