{ ... }: {
  imports = [
    ./power.nix
  ];

  services.fwupd.enable = true;

  hardware.enableRedistributableFirmware = true;
}
