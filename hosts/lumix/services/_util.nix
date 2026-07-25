{ lib, config, ... }:
let
  deployUID = 1002;
  deployGID = 100;

  stateVersion = config.system.stateVersion;
in
{
  mkServiceContainer =
    {
      enable ? true,
      ip,
      mounts ? { },
      module ? { },
    }:
    lib.mkIf enable {
      autoStart = true;

      privateNetwork = true;
      hostBridge = "br0";

      bindMounts = mounts;

      config =
        {
          config,
          pkgs,
          lib,
          ...
        }:
        lib.mkMerge [
          {
            users.users.deploy = {
              isSystemUser = true;
              uid = deployUID;
              group = "users";
              extraGroups = [
                "render"
                "video"
              ];
            };

            users.groups.users.gid = deployGID;

            networking.useHostResolvConf = lib.mkForce false;

            networking.nameservers = [ "1.1.1.1" ];
            networking.defaultGateway = "192.168.100.1";

            networking.interfaces.eth0 = {
              ipv4.addresses = [
                {
                  address = ip;
                  prefixLength = 24;
                }
              ];
            };

            system.stateVersion = stateVersion;
          }

          module
        ];
    };

  withPrivateAccess =
    cfg:
    cfg
    // {
      extraConfig = (cfg.extraConfig or "") + ''
        allow 192.168.100.0/24;
        allow 10.100.0.0/24;
        allow 188.138.145.187;
        deny all;
      '';
    };
}
