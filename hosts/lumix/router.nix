{ ... }:
{
  # Configure enp2s0 as LAN interface with static IP
  networking.interfaces.enp2s0 = {
    useDHCP = false;
    ipv4.addresses = [
      {
        address = "192.168.1.1";
        prefixLength = 24;
      }
    ];
  };

  # Enable IP forwarding (required for routing)
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 0;
  };

  # Configure NAT to route traffic from enp2s0 through enp3s0
  networking.nat = {
    enable = true;
    externalInterface = "enp3s0"; # WAN interface (has internet)
    internalInterfaces = [ "enp2s0" ]; # LAN interface
    internalIPs = [ "192.168.1.0/24" ];
  };

  # Open firewall for forwarding traffic between interfaces
  networking.firewall = {
    trustedInterfaces = [ "enp2s0" ];
  };

  # Optional: DHCP server for devices connecting to enp2s0
  services.kea = {
    dhcp4 = {
      enable = true;
      settings = {
        interfaces-config = {
          interfaces = [ "enp2s0" ];
        };
        lease-database = {
          type = "memfile";
          persist = true;
          name = "/var/lib/kea/dhcp4.leases";
        };
        subnet4 = [
          {
            subnet = "192.168.1.0/24";
            pools = [
              {
                pool = "192.168.1.100 - 192.168.1.200";
              }
            ];
            option-data = [
              {
                name = "routers";
                data = "192.168.1.1";
              }
              {
                name = "domain-name-servers";
                data = "192.168.1.1, 8.8.8.8, 1.1.1.1";
              }
            ];
          }
        ];
      };
    };
  };

  # Optional: DNS forwarding for LAN clients
  services.dnsmasq = {
    enable = true;
    settings = {
      interface = "enp2s0";
      bind-interfaces = true;
      domain-needed = true;
      bogus-priv = true;
      no-resolv = true;
      server = [
        "8.8.8.8"
        "1.1.1.1"
      ];
      listen-address = "192.168.1.1";
    };
  };

  # Open DNS port on the LAN interface
  networking.firewall.interfaces.enp2s0 = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [
      53
      67
    ];
  };
}
