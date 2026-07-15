{
  inputs,
  ...
}:
{
  imports = [
    inputs.hardware.nixosModules.common-cpu-amd-pstate
    inputs.hardware.nixosModules.common-gpu-nvidia
    inputs.hardware.nixosModules.common-pc-ssd
  ];

  local.hw.audio.enable = true;

  local.hw.splitKb = true;

  hardware.nvidia = {
    open = true;
    modesetting.enable = true;

    nvidiaSettings = true;

    powerManagement.enable = true;
    powerManagement.finegrained = false;
  };

  services.hardware.openrgb = {
    enable = true;
    package = pkgs.openrgb-with-all-plugins;
    motherboard = "amd";
    server.port = 6742;
  };
}
