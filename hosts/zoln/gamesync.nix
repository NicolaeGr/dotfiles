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
        "lumix" = {
          id = "ICHQARH-ZN7IIUX-3HHHMOB-DKDRM2A-TPBY7LX-LJBOMP3-TQXLTEZ-WJOMMQF";

          addresses = [
            "tcp://192.168.100.10:22000"
            "dynamic"
          ];
        };
      };

      folders = {
        "ludusavi-sync" = {
          path = "/home/nicolae/.config/ludusavi";
          devices = [ "lumix" ];
        };
      };
    };
  };
}
