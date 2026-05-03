{ pkgs, lib, ... }:
let
  deployUID = 1002;
  deployGID = 100;
in
{
  mkServiceContainer =
    {
      name,
      ip,
      ports,
      mounts,
      serviceConfig,
    }:
    {
      autoStart = true;
      privateNetwork = true;
      hostBridge = "br0";
      localAddress = "${ip}/24";

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

          networking.firewall.allowedTCPPorts = ports;
          networking.defaultGateway = "10.200.0.1";
          networking.nameservers = [ "1.1.1.1" ];

          imports = [ serviceConfig ];
        };
    };
}
