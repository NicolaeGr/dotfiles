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
    networking.firewall.allowedUDPPorts = [ config.extra.wireguard.listenPort ];
    networking.firewall.trustedInterfaces = [ "wg0" ];
    networking.firewall.checkReversePath = false;

    boot.kernel.sysctl = {
      "net.ipv4.conf.all.rp_filter" = 0;
      "net.ipv4.conf.default.rp_filter" = 0;
      "net.ipv4.conf.wg0.rp_filter" = 0;
    };
  };
}
