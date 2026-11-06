{
  pkgs,
  containerLib,
  ...
}:
let
  ip = "192.168.100.25";
  stateDir = "/storage/appdata/postgresql";
in
{
  containers.postgresql = containerLib.mkServiceContainer {
    inherit ip;

    mounts = {
      "/var/lib/postgresql" = {
        hostPath = stateDir;
        isReadOnly = false;
      };
    };

    module = {
      services.postgresql = {
        enable = true;

        # stateVersion 26.05 selects 17; pin it so a later bump cannot
        # move the data directory to another major version.
        package = pkgs.postgresql_17;

        enableTCPIP = true;

        authentication = ''
          host all all ${containerLib.homeIpRange} scram-sha-256
          host all all ${containerLib.wgIpRange} scram-sha-256
          host all all ${containerLib.publicIp}/32 scram-sha-256
        '';
      };

      networking.firewall.allowedTCPPorts = [ 5432 ];
    };
  };
}
