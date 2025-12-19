{ config, lib, ... }:
{
  options = {
    extra.wireguard.enable = lib.mkEnableOption {
      description = "Enable Wireguard support";
      default = false;
    };
  };

  config = lib.mkIf config.extra.wireguard.enable {
    networking.firewall.allowedUDPPorts = [ 8017 ];

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
