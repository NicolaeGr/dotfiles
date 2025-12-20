{
  config,
  lib,
  configLib,
  ...
}:
{
  options = {
    extra.wireguard.enable = lib.mkEnableOption {
      description = "Enable Wireguard support";
      default = false;
    };

    extra.wireguard.listenPort = lib.mkOption {
      type = lib.types.int;
      default = 25566;
      description = "The UDP port Wireguard should listen on.";
    };
  };

  config = lib.mkIf config.extra.wireguard.enable {
    networking.wg-quick.interfaces.wg0 = {
      postUp = ''
        sysctl -w net.ipv4.conf.all.rp_filter=0
        sysctl -w net.ipv4.conf.default.rp_filter=0
        sysctl -w net.ipv4.conf.wg0.rp_filter=0
      '';

      postDown = ''
        sysctl -w net.ipv4.conf.wg0.rp_filter=2
      '';
    };
  };
}
