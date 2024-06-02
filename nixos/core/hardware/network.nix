{ options, config, lib, hostName, ... }: {

  options = {
    network.enable = lib.mkEnableOption {
      default = false;
      description = "Enable networking";
    };
  };

  config = lib.mkIf config.network.enable {
    networking = {
      inherit hostName;

      networkmanager = {
        enable = true;
        wifi.powersave = true;
      };

      firewall = {
        enable = true;
        allowPing = true;
        allowedTCPPorts = [ 22 80 443 53 3000 8000 8080 5500 4173 4174 4175 ];
        allowedUDPPorts = [ 53 ];
      };

      nftables.enable = true;
    };
  };
}
