{ ... }:
{
  services.syncthing = {
    enable = true;
    user = "nicolae";
    dataDir = "/home/nicolae/.config/syncthing";
    configDir = "/home/nicolae/.config/syncthing";

    openDefaultPorts = true;

    settings = {
      devices = {
        "server" = {
          id = "FA5YAJT-IMV3PQY-AUKSOXZ-LTTFBA3-FC6TA7E-JWQAV65-3TCT6I2-2FYPRAQ";
          addresses = [
            "tcp://10.0.0.1:22000"
            "dynamic"
          ];
        };
      };

      folders = {
        "ludusavi-sync" = {
          path = "/home/nicolae/.config/ludusavi";
          devices = [ "server" ];
        };
      };
    };
  };
}
