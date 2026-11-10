{ lib, configVars, ... }:
{
  networking.networkmanager.enable = lib.mkForce false;

  local.platform.router = true;

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

    netdevs."br-svc" = {
      netdevConfig = {
        Name = "br-svc";
        Kind = "bridge";
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
      address = [ "${configVars.net.lan.serverIp}/24" ];
      gateway = [ configVars.net.gateway ];
      dns = [ "1.1.1.1" ];
    };

    networks."20-br-svc" = {
      matchConfig.Name = "br-svc";
      address = [ "${configVars.net.svc.serverIp}/24" ];
    };
  };

  networking.firewall = {
    enable = true;

    trustedInterfaces = [ "br0" ];
  };
}
