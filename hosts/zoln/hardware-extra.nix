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

  hardware.nvidia = {
    open = true;
    modesetting.enable = true;

    nvidiaSettings = true;

    powerManagement.enable = true;
    powerManagement.finegrained = false;
  };
}
