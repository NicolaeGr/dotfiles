{ lib, ... }:
{
  networking.networkmanager.enable = lib.mkForce false;

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.bridge.bridge-nf-call-iptables" = 1;
    "net.bridge.bridge-nf-call-ip6tables" = 1;
  };

  networking.useNetworkd = true;
  systemd.network = {
    enable = true;

    netdevs."br0" = {
      netdevConfig = {
        Name = "br0";
        Kind = "bridge";
        MACAddress = "68:05:ca:7d:dc:66";
      };
    };

    networks."10-enp2s0" = {
      matchConfig.Name = "enp2s0";
      networkConfig.Bridge = "br0";
    };

    networks."11-enp3s0" = {
      matchConfig.Name = "enp3s0";
      networkConfig.Bridge = "br0";
    };

    networks."20-br0" = {
      matchConfig.Name = "br0";
      address = [ "192.168.100.10/24" ];
      gateway = [ "192.168.100.1" ];
      dns = [ "1.1.1.1" ];
    };
  };

  networking.firewall = {
    enable = true;

    trustedInterfaces = [
      "br0"
      "wg0"
    ];
  };
}
