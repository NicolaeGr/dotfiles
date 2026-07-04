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

  services.adguardhome = {
    enable = true;

    settings = {
      http = {
        address = "10.100.0.1:3000";
      };
      dns = {
        bind_addresses = [ "10.100.0.1" ];
        port = 53;

        upstream_dns = [
          "https://dns.adguard-dns.com/dns-query"
          "https://freedns.controld.com/p2"
          "https://dnsforge.de/dns-query"
          "https://doh.libredns.gr/noads"
          "https://doh.mullvad.net/dns-query"
        ];

        bootstrap_dns = [
          "9.9.9.9"
          "1.1.1.1"
        ];

        protection_enabled = true;
        filtering_enabled = true;
      };

      users = [ ];
    };
  };

  networking.wg-quick.interfaces.wg0 = {
    address = [ "10.100.0.1/24" ];
    listenPort = config.extra.wireguard.listenPort;

    privateKeyFile = config.sops.secrets.lumix_wg_private_key.path;

    postUp = ''
      ${pkgs.iptables}/bin/iptables -A INPUT -i wg0 -p udp --dport 53 -j ACCEPT

      # Allow forwarding between WireGuard and the Bridge
      ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -o br0 -j ACCEPT
      ${pkgs.iptables}/bin/iptables -A FORWARD -i br0 -o wg0 -j ACCEPT

      # NAT traffic going from WireGuard to the Bridge so containers can reply
      ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o br0 -j MASQUERADE
    '';

    preDown = ''
      ${pkgs.iptables}/bin/iptables -D INPUT -i wg0 -p udp --dport 53 -j ACCEPT

      # Clean up forwarding rules
      ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -o br0 -j ACCEPT
      ${pkgs.iptables}/bin/iptables -D FORWARD -i br0 -o wg0 -j ACCEPT

      # Clean up NAT rule
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o br0 -j MASQUERADE
    '';

    peers = [
      {
        publicKey = "DoB3CnXKA7eo+YR7FHzdk9SBzDde4mZBRWWubrSxfTU=";
        allowedIPs = [ "10.100.0.2/32" ];
      }
      {
        publicKey = "vaX2WLPn8thbGr+EEpBLpIMlqybc5uokUnhD0e1NmhA=";
        allowedIPs = [ "10.100.0.3/32" ];
      }
      {
        publicKey = "9rMvLrNfoIBT18kycuIpZhNmtjYraJ5ihUahDd5PdSs=";
        allowedIPs = [ "10.100.0.4/32" ];
      }
    ];
  };

  networking.firewall.interfaces."wg0".allowedUDPPorts = [ 53 ];
  networking.firewall.interfaces."wg0".allowedTCPPorts = [
    53

    3000
  ];
}
