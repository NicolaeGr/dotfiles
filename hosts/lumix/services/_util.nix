{ lib, ... }:
let
  deployUID = 1002;
  deployGID = 100;
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
      localAddress = ip;
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

          imports = [ serviceConfig ];
        };
    };
}
