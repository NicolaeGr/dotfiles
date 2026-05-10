{ pkgs, ... }:
{
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.bridge.bridge-nf-call-iptables" = 0;
  };
  networking = {
    networkmanager.unmanaged = [
      "enp2s0"
      "enp3s0"
    ];

    bridges."br0" = {
      interfaces = [
        "enp2s0"
        "enp3s0"
      ];
    };

    interfaces.enp2s0.useDHCP = false;
    interfaces.enp3s0.useDHCP = false;
    interfaces.br0 = {
      useDHCP = true;
      macAddress = "68:05:ca:7d:dc:66";
    };

    firewall = {
      enable = true;
      trustedInterfaces = [
        "br0"
      ];
    };
  };
}
