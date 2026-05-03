{ ... }:
{
  networking = {
    networkmanager.unmanaged = [
      "enp2s0"
      "enp3s0"
    ];

    bridges."br0".interfaces = [
      "enp2s0"
      "enp3s0"
    ];

    interfaces.enp2s0.useDHCP = false;
    interfaces.enp3s0.useDHCP = false;
    interfaces.br0.useDHCP = true;

    firewall = {
      enable = true;
      trustedInterfaces = [
        "br0"
      ];
    };
  };
}
