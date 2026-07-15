{ ... }: {
  imports = [
    ./power.nix
  ];

  services.fwupd.enable = true;
  programs.partition-manager.enable = true;
  hardware.enableRedistributableFirmware = true;
}
