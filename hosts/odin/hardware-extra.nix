{
  pkgs,
  inputs,
  config,
  ...
}:
{
  imports = [
    inputs.hardware.nixosModules.lenovo-ideapad-15arh05
  ];

  local.hw.audio.enable = true;
  local.hw.bluetooth.enable = true;

  local.hw.splitKb = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  boot.kernelPackages = pkgs.linuxPackages_7_2;

  boot.kernelModules = [ "acpi_call" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

  boot.kernelParams = [
    "amdgpu.backlight=0"
    "nvidia_drm.fbdev=1"
  ];
}
