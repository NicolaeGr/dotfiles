{ hostName, ... }:
{
  services.openssh.settings = {
    GatewayPorts = "yes";
    AllowTcpForwarding = "yes";
  };

  networking = {
    inherit hostName;
    enableIPv6 = false;

    networkmanager = {
      enable = true;
      wifi.powersave = true;
    };

    firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [
        22
        80
        443
        53
        3000
        8000
        8080
        5500
        4173
        4174
        4175
      ];
      allowedUDPPorts = [
        53
        67
        68
      ];
    };

    nftables.enable = true;
  };
}
