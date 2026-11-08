{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.local.hw.aic8800;

  driver = config.boot.kernelPackages.callPackage ../../../nix/pkgs/aic8800 { };
in
{
  options.local.hw.aic8800.enable = lib.mkEnableOption ''
    AIC8800D80 USB WiFi + Bluetooth support via the aic_load_fw and
    aic8800_fdrv modules. Bluetooth uses the in-kernel btusb driver.
  '';

  config = lib.mkIf cfg.enable {
    boot.extraModulePackages = [ driver ];
    hardware.firmware = [ driver ];

    boot.kernelModules = [
      "aic_load_fw"
      "aic8800_fdrv"
    ];

    # The WiFi driver reuses the path reported by the loader, so one value has
    # to serve both lookups. See the firmware layout in the package.
    boot.extraModprobeConfig = ''
      options aic_load_fw aic_fw_path=/run/current-system/firmware
    '';

    # The dongle boots as a read-only mass-storage device and only exposes its
    # radio interfaces after that disk is ejected.
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="block", ENV{DEVTYPE}=="disk", KERNEL=="sd*", ATTRS{idVendor}=="a69c", ATTRS{idProduct}=="5721", RUN+="${pkgs.util-linux}/bin/eject /dev/%k"
    '';
  };
}
