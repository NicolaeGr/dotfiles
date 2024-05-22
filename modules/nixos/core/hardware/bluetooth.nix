{ options, config, lib, ... }: {
  options = {
    bluetooth.enable = lib.mkEnableOption {
      default = false;
      description = "Enable Bluetooth";
    };
  };

  config = lib.mkIf config.bluetooth.enable {
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
  };
}
