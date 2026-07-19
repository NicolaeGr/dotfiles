{ hostName, ... }: {
  services.resolved.enable = false;

  networking = {
    inherit hostName;
    enableIPv6 = false;
    networkmanager.enable = true;
    networkmanager.wifi.powersave = true;
    nftables.enable = true;

    firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };

  services.openssh = {
    enable = true;
    openFirewall = true;

    ports = [
      22
      1044
    ];

    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      GatewayPorts = "yes";
      AllowTcpForwarding = "yes";
    };
  };
}
