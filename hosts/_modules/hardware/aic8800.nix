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

    # filp_open() cannot read the zstd-compressed firmware under
    # /run/current-system/firmware, so point at the package's raw tree.
    # aic8800_fdrv reads the same value through get_fw_path().
    boot.extraModprobeConfig = ''
      options aic_load_fw aic_fw_path=${driver}/lib/firmware
    '';

    # The dongle starts as a read-only mass-storage device and exposes its
    # radio interfaces only after that disk is ejected.
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="block", ENV{DEVTYPE}=="disk", KERNEL=="sd*", ATTRS{idVendor}=="a69c", ATTRS{idProduct}=="5721", RUN+="${pkgs.util-linux}/bin/eject /dev/%k"
    '';
  };
}
