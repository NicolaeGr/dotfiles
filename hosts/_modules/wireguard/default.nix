{
  config,
  lib,
  ...
}:
{
  options.local.wireguard = {
    enable = lib.mkEnableOption {
      description = "Enable Wireguard support";
      default = false;
    };

    listenPort = lib.mkOption {
      type = lib.types.int;
      default = 25566;
      description = "The UDP port Wireguard should listen on.";
    };
  };

  config = lib.mkIf config.local.wireguard.enable {
    boot.kernel.sysctl = {
      "net.ipv4.conf.all.rp_filter" = lib.mkDefault 0;
      "net.ipv4.conf.default.rp_filter" = lib.mkDefault 0;
    };
  };
}
