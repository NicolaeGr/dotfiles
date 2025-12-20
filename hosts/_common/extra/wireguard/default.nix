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

    sops.secrets.lumix_wg_private_key = {
      sopsFile = (configLib.relativeToRoot "secrets/wireguard.yaml");
      format = "yaml";
    };
    sops.secrets.odin_wg_private_key = {
      sopsFile = (configLib.relativeToRoot "secrets/wireguard.yaml");
      format = "yaml";
    };
  };
}
