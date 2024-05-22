{ options, config, lib, hostName, ... }: {

  options = {
    network.enable = lib.mkEnableOption {
      default = false;
      description = "Enable networking";
    };
  };

  config = lib.mkIf config.network.enable {
    networking = {
      networkmanager = {
        enable = true;
        wifi.powersave = true;
      };
      inherit hostName;
    };
  };
}
