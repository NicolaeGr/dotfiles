{ ... }:
{
  networking.networkmanager.unmanaged = [
    "enp2s0"
    "enp3s0"
  ];

  networking.bridges = {
    "br0" = {
      interfaces = [
        "enp2s0"
        "enp3s0"
      ];
    };
  };

  networking.interfaces.br0 = {
    useDHCP = true;
  };

  networking.interfaces.enp2s0.useDHCP = false;
  networking.interfaces.enp3s0.useDHCP = false;

  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "br0" ];
  };
}
