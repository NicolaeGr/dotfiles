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
        "desktop" = {
          id = "6HVSF2N-BYUZHEF-WHYBMIX-BPSWNVU-GERW35S-PQZBIFV-L4H3UP7-JR5VTQD";
        };
        "laptop" = {
          id = "ALQ2CZD-UBK7SN6-BM5ULTC-FPMTCCD-KZ2D4JD-RNIV3CE-XRX3FRA-LBB67A2";
        };
      };

      folders = {
        "ludusavi-sync" = {
          path = "/home/nicolae/Public/LudusaviBackup";
          devices = [
            "desktop"
            "laptop"
          ];
          versioning = {
            type = "simple";
            params.keep = "5";
          };
        };
      };
    };
  };
}
