{ lib, ... }:
let
  deployUID = 1002;
  deployGID = 100;

  ipToMac =
    ip:
    let
      parts = lib.splitString "." ip;

      hex = n: lib.toLower (lib.toHexString (lib.toInt n));
      pad = s: if (lib.stringLength s) == 1 then "0${s}" else s;
    in
    "02:00:00:00:${pad (hex (lib.elemAt parts 2))}:${pad (hex (lib.elemAt parts 3))}";
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
            };

            users.groups.users.gid = deployGID;

            networking.nameservers = [ "1.1.1.1" ];
            networking.defaultGateway = "192.168.100.1";

            networking.useHostResolvConf = lib.mkForce false;

            networking.interfaces.eth0 = {
              macAddress = ipToMac ip;

              ipv4.addresses = [
                {
                  address = ip;
                  prefixLength = 24;
                }
              ];
            };
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
        allow 178.168.37.108;
        deny all;
      '';
    };
}
