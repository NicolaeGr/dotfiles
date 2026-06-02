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
        "zoln" = {
          id = "X6SS352-33QWTNI-ZSWABTW-RSNSUMY-WPC35RO-H6P62O2-THMT74N-AO5CPA6";
        };
        "odin" = {
          id = "BGUTY2D-CKZAKTA-G3PD2HO-CXT47QL-RXAW4SO-KU33ZFS-VAZLKQA-SCCOBQG";
        };
      };

      folders = {
        "ludusavi-backup" = {
          path = "/home/nicolae/Public/LudusaviBackup";
          devices = [
            "zoln"
            "odin"
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
