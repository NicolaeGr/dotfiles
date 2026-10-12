{
  lib,
  config,
  configVars,
  ...
}:
let
  deployUID = 1002;
  deployGID = 100;

  hostStateVersion = config.system.stateVersion;

  publicIp = configVars.net.publicIp;
  homeIpRange = configVars.net.lan.subnet;
  wgIpRange = configVars.net.wg.subnet;
in
{
  _module.args.containerLib = {
    inherit publicIp homeIpRange wgIpRange;

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
              networking.defaultGateway = configVars.net.gateway;

              networking.interfaces.eth0 = {
                ipv4.addresses = [
                  {
                    address = ip;
                    prefixLength = 24;
                  }
                ];
              };

              environment.systemPackages = [ pkgs.kitty ];

              system.stateVersion = hostStateVersion;
            }

            module
          ];
      };

    withPrivateAccess =
      cfg:
      cfg
      // {
        extraConfig = (cfg.extraConfig or "") + ''
          allow ${homeIpRange};
          allow ${wgIpRange};
          allow ${publicIp};
          deny all;
        '';
      };
  };
}
