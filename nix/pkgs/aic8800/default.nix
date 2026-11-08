# AIC8800D80 WiFi + Bluetooth kernel modules and firmware.
#
# The `legacy-mcu1` branch targets hardware that reports `chip_id=7
# chip_mcu_id=1`. Its aic_load_fw uploads the BT patch table, which makes the
# chip enumerate as a combo device that btusb can bind.
{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
  kernelModuleMakeFlags,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "aic8800-legacy-mcu1";
  version = "unstable-2026-11-02";

  src = fetchFromGitHub {
    owner = "shenmintao";
    repo = "aic8800d80";
    rev = "bbf6cb4015c8da4e7e113a6a6282f191213e0854";
    hash = "sha256-fGuhzbvG9gfcoma+Cgqn4bhZEJVY5/5dKAd7NF4/i0s=";
  };

  hardeningDisable = [
    "pic"
    "format"
  ];

  nativeBuildInputs = kernel.moduleBuildDependencies;

  kdir = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";

  makeFlags = kernelModuleMakeFlags ++ [
    "INSTALL_MOD_PATH=${placeholder "out"}"
    "INSTALL_MOD_DIR=kernel/drivers/net/wireless/aic8800"
  ];

  buildPhase = ''
    runHook preBuild

    make -C ${finalAttrs.kdir} M=$PWD/drivers/aic8800/aic_load_fw \
      $makeFlags modules

    # aic8800_fdrv links against symbols exported by aic_load_fw.
    make -C ${finalAttrs.kdir} M=$PWD/drivers/aic8800/aic8800_fdrv \
      KBUILD_EXTRA_SYMBOLS=$PWD/drivers/aic8800/aic_load_fw/Module.symvers \
      $makeFlags modules

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # modules_install runs the kernel's sign step, which writes the .ko.cer
    # files the module aggregator needs.
    for m in aic_load_fw aic8800_fdrv; do
      make -C ${finalAttrs.kdir} M=$PWD/drivers/aic8800/$m $makeFlags modules_install
    done

    # aic_load_fw looks up <aic_fw_path>/<name>, aic8800_fdrv looks up
    # <aic_fw_path>/aic8800D80/<name>. The links at the top level serve the
    # first lookup and the subdirectory serves the second.
    mkdir -p $out/lib/firmware/aic8800D80
    cp -r fw/aic8800D80/. $out/lib/firmware/aic8800D80/
    for f in fw/aic8800D80/fw_*.bin; do
      ln -sf aic8800D80/''${f##*/} $out/lib/firmware/
    done

    runHook postInstall
  '';

  meta = {
    description = "AIC8800D80 WiFi and Bluetooth driver (legacy-mcu1 profile)";
    homepage = "https://github.com/shenmintao/aic8800d80";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
})
