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
      enable,
      ip,
      mounts,
      serviceConfig,
    }:
    lib.mkIf enable {
      autoStart = true;
      privateNetwork = true;
      hostBridge = "br0";
      bindMounts = mounts;

      config =
        { ... }:
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

          imports = [ serviceConfig ];
        };
    };
}
